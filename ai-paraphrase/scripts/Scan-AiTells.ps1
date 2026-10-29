<#
.SYNOPSIS
    Scans a project for AI-writing tells and reports them with file:line locations.

.DESCRIPTION
    A spotlight, not a verdict. This script deliberately over-reports: it flags
    candidates so a human (or Claude) can judge them in context. A hit is not
    proof of anything. Density across a passage is the signal; a lone hit is noise.

    Compatible with Windows PowerShell 5.1 and PowerShell 7+.
    Source is deliberately pure ASCII (non-ASCII chars use \uXXXX regex escapes)
    so it parses correctly regardless of how the host reads file encoding.

.PARAMETER Path
    Root directory (or single file) to scan. Defaults to the current directory.

.PARAMETER AllText
    Also scan source-code files, not just prose files. Off by default because
    identifiers legitimately contain words like "robust" or "key".

.PARAMETER MinSeverity
    One of: low, medium, high, definitive. Defaults to low (report everything).

.PARAMETER Format
    table (default), csv, or json.

.PARAMETER Summary
    Print only per-file and per-category counts, no individual hits.
    Use this first on a large project to size the job.

.EXAMPLE
    .\Scan-AiTells.ps1 -Path . -Summary
.EXAMPLE
    .\Scan-AiTells.ps1 -Path docs -MinSeverity high -Format table
.EXAMPLE
    .\Scan-AiTells.ps1 -Path . -AllText -Format csv | Set-Content hits.csv
#>

[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$AllText,
    [ValidateSet("low", "medium", "high", "definitive")]
    [string]$MinSeverity = "low",
    [ValidateSet("table", "csv", "json")]
    [string]$Format = "table",
    [switch]$Summary,
    [int]$MaxFileKB = 2048
)

$ErrorActionPreference = "Stop"

$SevRank = @{ low = 0; medium = 1; high = 2; definitive = 3 }
$MinRank = $SevRank[$MinSeverity]

$ProseExt = @('.md', '.mdx', '.markdown', '.txt', '.rst', '.adoc', '.asciidoc', '.org')
$CodeExt = @('.js', '.jsx', '.ts', '.tsx', '.py', '.rb', '.go', '.rs', '.java', '.kt',
    '.cs', '.php', '.swift', '.c', '.h', '.cpp', '.hpp', '.sh', '.ps1',
    '.html', '.vue', '.svelte', '.astro', '.json', '.yml', '.yaml', '.toml',
    '.ipynb')

$ExcludeDirs = @('node_modules', '.git', '.svn', '.hg', 'dist', 'build', 'out', 'vendor',
    '.next', '.nuxt', '.venv', 'venv', 'env', '__pycache__', 'target',
    'coverage', '.cache', '.turbo', 'bin', 'obj', 'Pods', '.gradle',
    'bower_components', '.terraform', 'site-packages')

$ExcludeFilePatterns = @('*.min.*', '*.lock', '*-lock.json', '*.map', '*.svg',
    'LICENSE*', 'COPYING*', 'NOTICE*', '*.po', '*.mo')

# ---------------------------------------------------------------------------
# Pattern catalog. Mirrors references/ai-tells.md - keep the two in sync.
# This file is deliberately pure ASCII. Non-ASCII chars are written as .NET
# regex \uXXXX escapes so the script parses under any file-encoding assumption:
#   ' straight apostrophe   \u2018 \u2019 curly single quotes
#   \u201C \u201D curly doubles  \u2014 em dash   \u2022 bullet
#   \u3010 lenticular bracket    \u2020 dagger
# ---------------------------------------------------------------------------
$Patterns = @(
    # --- definitive: machine artifacts, cannot come from a human ---
    @{ C = 'artifact-chatgpt'; S = 'definitive'; R = 'contentReference|oaicite|oai_citation|attributableIndex' }
    @{ C = 'artifact-chatgpt'; S = 'definitive'; R = 'turn\d+(search|image|news|file)\d+' }
    @{ C = 'artifact-utm'; S = 'definitive'; R = 'utm_source=(chatgpt\.com|openai|copilot\.com)|referrer=grok\.com' }
    @{ C = 'artifact-grok'; S = 'definitive'; R = 'grok_card|grok_render_citation_card_json|grok-card data-id' }
    @{ C = 'artifact-gemini'; S = 'definitive'; R = '\[cite:\s*\d+|\[span_\d+\]\((start|end)_span\)' }
    @{ C = 'artifact-deepseek'; S = 'definitive'; R = '\u3010\d+\u2020' }
    @{ C = 'artifact-perplexity'; S = 'definitive'; R = '\[attached_file:\d+\]|\[web:\d+\]|ppl-ai-file-upload' }
    @{ C = 'artifact-misc'; S = 'definitive'; R = ':::writing\{' }
    @{ C = 'placeholder'; S = 'definitive'; R = '\[(Your|Insert|Add|Company|Product|Artist|Author)\s+\w+\]|20\d\d-XX-XX|\(Add your [^)]{0,40}here\)' }
    @{ C = 'chat-leakage'; S = 'definitive'; R = '\b(Certainly|Of course|Great question|I hope this helps)\b|\bYou[\u0027\u2019]re absolutely right\b' }
    @{ C = 'chat-leakage'; S = 'definitive'; R = '\bWould you like me to\b|\bLet me know if you\b|\bIs there anything else\b|\bAs an AI (language )?model\b' }
    @{ C = 'knowledge-cutoff'; S = 'definitive'; R = '\b(as of|up to) my (last )?(knowledge|training)( (update|cutoff))?\b|\bbased on (the )?available (information|sources|search results)\b' }

    # --- high: strong prose tells ---
    @{ C = 'significance'; S = 'high'; R = '\b(stands|serves) as (a|an|the)\b|\ba testament to\b|\bis a reminder (of|that)\b' }
    @{ C = 'significance'; S = 'high'; R = '\bplay(s|ed|ing)? (a|an) (crucial|pivotal|vital|significant|key|central|important) role\b' }
    @{ C = 'significance'; S = 'high'; R = '\bunderscor(es|ing|ed) (the|its) (importance|significance|need|role)\b|\bhighlight(s|ing) (the|its) (importance|significance)\b' }
    @{ C = 'significance'; S = 'high'; R = '\breflect(s|ing) (a )?broader\b|\bpart of a broader (movement|trend|shift)\b|\bevolving landscape\b|\bindelible mark\b' }
    @{ C = 'significance'; S = 'high'; R = '\bmark(s|ing|ed) (a|the) (pivotal|significant|key|turning) (moment|point|shift)\b|\brepresent(s|ed|ing) (a|the) (significant |major |fundamental )?shift\b' }
    @{ C = 'significance'; S = 'high'; R = '\bset(s|ting) the stage for\b|\bcement(s|ing|ed) (its|his|her|their) (place|status|legacy)\b|\blasting (impact|impression|legacy)\b' }

    @{ C = 'participial-tail'; S = 'high'; R = ',\s*(highlighting|underscoring|emphasizing|showcasing|reflecting|symbolizing|ensuring|fostering|cultivating|enhancing|solidifying|cementing|contributing to|allowing for)\b' }
    @{ C = 'participial-tail'; S = 'high'; R = '\bthereby (ensuring|enabling|allowing|creating|providing)\b|\bwhile (also )?(ensuring|maintaining|preserving)\b' }

    @{ C = 'copula-avoidance'; S = 'high'; R = '\b(serves|stands|functions|operates|acts) as (a|an|the)\b|\bboasts (a|an|\d|over|more)\b' }
    @{ C = 'copula-avoidance'; S = 'high'; R = '\b(features|offers|provides|maintains|houses|delivers) (a|an|several|multiple|numerous|comprehensive)\b|\bis home to\b' }
    @{ C = 'copula-avoidance'; S = 'high'; R = '\bhold(s) the distinction of\b|\bventured into\b|\bembarked on\b|\bbegan (his|her|their|its) (career|journey) as\b' }

    @{ C = 'vague-attribution'; S = 'high'; R = '\b(experts|analysts|observers|critics|scholars|researchers|commentators) (argue|note|say|believe|have (noted|cited|observed|suggested))\b' }
    @{ C = 'vague-attribution'; S = 'high'; R = '\bis (widely|generally|often|commonly) (regarded|considered|seen|viewed|interpreted|believed)\b|\bit is (widely|generally) (believed|accepted|understood|acknowledged)\b' }
    @{ C = 'vague-attribution'; S = 'high'; R = '\bsome (critics|observers|analysts|experts)\b|\b(industry|market) reports (suggest|indicate|show)\b|\bseveral (sources|publications|outlets)\b' }

    @{ C = 'challenges-formula'; S = 'high'; R = '\bDespite (its|these|the) [\w\s]{0,40}(challenges|limitations|criticisms|setbacks)\b|\bfaces (several|numerous|various|a number of|ongoing) challenges\b' }
    @{ C = 'challenges-formula'; S = 'high'; R = '^#{1,6}\s*(Challenges( and \w+)?|Future (Outlook|Prospects|Directions)|Conclusion|Final Thoughts|Key Takeaways)\s*$' }
    @{ C = 'challenges-formula'; S = 'high'; R = '\b(Looking|Moving) (ahead|forward)\b|\bOnly time will tell\b' }

    @{ C = 'negative-parallel'; S = 'high'; R = '\bnot (just|only|merely|simply) [^.]{0,60}\bbut (also )?\b' }
    @{ C = 'negative-parallel'; S = 'high'; R = '\bit[\u0027\u2019]?s not (just )?[^.,]{1,40}, it[\u0027\u2019]?s\b|\bno \w+, no \w+, just\b' }
    @{ C = 'negative-parallel'; S = 'high'; R = '\brather than (a|an|mere|simply|purely|ideological)\b|\bmore than (just )?(a|an)\b' }

    # --- medium ---
    @{ C = 'puffery'; S = 'medium'; R = '\b(vibrant|bustling|thriving|renowned|prestigious|esteemed|iconic|breathtaking|captivating|compelling)\b' }
    @{ C = 'puffery'; S = 'medium'; R = '\bnestled (in|within|among|between)\b|\bin the heart of\b|\b(rich|diverse) (tapestry|array|heritage|ecosystem)\b' }
    @{ C = 'puffery'; S = 'medium'; R = '\b(groundbreaking|revolutionary|transformative|game[- ]?chang(er|ing)|cutting[- ]edge|state[- ]of[- ]the[- ]art|next[- ]generation|world[- ]class|best[- ]in[- ]class)\b' }
    @{ C = 'puffery'; S = 'medium'; R = '\bcommitment to (excellence|quality|innovation|sustainability)\b|\bunparalleled\b|\bunwavering\b|\bblazing fast\b' }
    @{ C = 'puffery'; S = 'medium'; R = '\b(unlock|unleash|harness|empower|elevate|supercharge|revolutionize) (the|your|its|new)\b|\bmust[- ]visit\b|\bhidden gem\b' }

    @{ C = 'notability-canned'; S = 'medium'; R = '\bindependent coverage\b|\btrade publications\b|\b(local|regional|national) (media )?outlets\b' }
    @{ C = 'notability-canned'; S = 'medium'; R = '\bmaintains (an|a) (active|strong|significant) (social media |digital |online )?presence\b|\b(profiled|featured) in\b' }

    @{ C = 'didactic'; S = 'medium'; R = '\bit[\u0027\u2019]?s (important|crucial|essential|worth) (to note|noting|to remember|to consider)\b|\bit should be noted that\b|\bkeep in mind that\b' }
    @{ C = 'canned-summary'; S = 'medium'; R = '\b(In (summary|conclusion)|To summarize|In essence|Ultimately),' }

    @{ C = 'fmt-bold-list'; S = 'medium'; R = '^\s*[-*\u2022]\s*\*\*[^*]+\*\*\s*[:\u2014-]' }
    @{ C = 'fmt-emoji-heading'; S = 'medium'; R = '^#{1,6}\s*\p{So}|^\s*[-*]\s*\p{So}' }
    @{ C = 'fmt-title-case'; S = 'medium'; R = '^#{1,6}\s+([A-Z][a-z]+\s+){2,}[A-Z][a-z]+\s*$' }

    # --- low: only meaningful in density ---
    @{ C = 'ai-vocab'; S = 'low'; R = '\b(delve|delves|delving|tapestry|testament|intricate|intricacies|meticulous|meticulously|pivotal|bolster(ed|ing)?|garner(ed|ing)?|interplay|myriad|plethora|holistic|multifaceted|nuanced)\b' }
    @{ C = 'ai-vocab'; S = 'low'; R = '\b(underscore(s|d)?|foster(s|ed|ing)?|showcase(s|d)?|leverage(s|d)?|align(s|ed)? with|resonate(s|d)? with)\b' }
    @{ C = 'ai-vocab'; S = 'low'; R = '\b(seamless(ly)?|effortless(ly)?|robust|comprehensive|crucial|vital|profound|paramount|enduring)\b' }
    @{ C = 'punct-em-dash'; S = 'low'; R = '\s\u2014\s' }
    @{ C = 'punct-curly'; S = 'low'; R = '[\u2018\u2019\u201C\u201D]' }
)

# ---------------------------------------------------------------------------

$root = Resolve-Path -LiteralPath $Path
$rootStr = $root.Path

if (Test-Path -LiteralPath $rootStr -PathType Leaf) {
    $files = @(Get-Item -LiteralPath $rootStr)
}
else {
    if ($AllText) { $wanted = $ProseExt + $CodeExt } else { $wanted = $ProseExt }
    $files = Get-ChildItem -LiteralPath $rootStr -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        $rel = $_.FullName.Substring($rootStr.Length).TrimStart('\', '/')
        $parts = $rel -split '[\\/]'
        $inExcluded = $false
        foreach ($p in $parts) { if ($ExcludeDirs -contains $p) { $inExcluded = $true; break } }
        if ($inExcluded) { return $false }
        foreach ($pat in $ExcludeFilePatterns) { if ($_.Name -like $pat) { return $false } }
        if ($_.Length -gt ($MaxFileKB * 1KB)) { return $false }
        # extensionless docs like README / CHANGELOG count as prose
        if ($_.Extension -eq '' -and $_.BaseName -match '^(README|CHANGELOG|CONTRIBUTING|AUTHORS|TODO|NOTES)$') { return $true }
        return ($wanted -contains $_.Extension.ToLower())
    }
}

$hits = New-Object System.Collections.ArrayList
$scanned = 0

$pushed = $false
if (Test-Path -LiteralPath $rootStr -PathType Container) {
    Push-Location -LiteralPath $rootStr; $pushed = $true
}

foreach ($f in $files) {
    $lines = $null
    try { $lines = Get-Content -LiteralPath $f.FullName -Encoding UTF8 -ErrorAction Stop }
    catch { continue }
    if ($null -eq $lines) { continue }
    $scanned++

    # Resolve-Path -Relative handles 8.3 short names and case differences that
    # naive string-prefix stripping gets wrong. Location is pushed once, outside.
    $rel = $f.Name
    try { $rel = (Resolve-Path -LiteralPath $f.FullName -Relative -ErrorAction Stop) -replace '^\.[\\/]', '' }
    catch { $rel = $f.Name }
    if ([string]::IsNullOrEmpty($rel)) { $rel = $f.Name }

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        foreach ($p in $Patterns) {
            if ($SevRank[$p.S] -lt $MinRank) { continue }
            $m = [regex]::Matches($line, $p.R, 'IgnoreCase')
            if ($m.Count -eq 0) { continue }
            $snippet = $line.Trim()
            if ($snippet.Length -gt 110) { $snippet = $snippet.Substring(0, 107) + '...' }
            [void]$hits.Add([PSCustomObject]@{
                    File     = $rel
                    Line     = $i + 1
                    Severity = $p.S
                    Category = $p.C
                    Match    = (($m | ForEach-Object { $_.Value } | Select-Object -Unique) -join ' | ')
                    Text     = $snippet
                })
        }
    }
}

if ($pushed) { Pop-Location }

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

if ($hits.Count -eq 0) {
    Write-Host "Scanned $scanned file(s) under $rootStr - no hits at severity >= $MinSeverity." -ForegroundColor Green
    return
}

if ($Summary) {
    Write-Host ""
    Write-Host "AI-tell scan: $scanned file(s) scanned, $($hits.Count) candidate hit(s)." -ForegroundColor Cyan
    Write-Host "A hit is a candidate, not a verdict. Density is the signal." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "-- by severity --"
    $hits | Group-Object Severity |
    Sort-Object { $SevRank[$_.Name] } -Descending |
    Select-Object @{n = 'Severity'; e = { $_.Name } }, Count | Format-Table -AutoSize
    Write-Host "-- by category --"
    $hits | Group-Object Category | Sort-Object Count -Descending |
    Select-Object @{n = 'Category'; e = { $_.Name } }, Count | Format-Table -AutoSize
    Write-Host "-- worst files --"
    $hits | Group-Object File | Sort-Object Count -Descending | Select-Object -First 25 |
    Select-Object @{n = 'File'; e = { $_.Name } }, Count | Format-Table -AutoSize
    return
}

$sorted = $hits | Sort-Object @{e = { $SevRank[$_.Severity] }; Descending = $true }, File, Line

switch ($Format) {
    'csv' { $sorted | ConvertTo-Csv -NoTypeInformation }
    'json' { $sorted | ConvertTo-Json -Depth 4 }
    default {
        Write-Host ""
        Write-Host "$($hits.Count) candidate hit(s) across $scanned file(s). Judge each in context." -ForegroundColor Cyan
        Write-Host ""
        $sorted | Format-Table -AutoSize -Wrap @{n = 'Sev'; e = { $_.Severity }; w = 10 },
        @{n = 'Category'; e = { $_.Category }; w = 19 },
        @{n = 'Location'; e = { "$($_.File):$($_.Line)" }; w = 34 },
        @{n = 'Match'; e = { $_.Match }; w = 26 },
        @{n = 'Text'; e = { $_.Text } }
    }
}
