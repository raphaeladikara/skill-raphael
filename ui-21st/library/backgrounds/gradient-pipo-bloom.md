---
name: gradient-pipo-bloom
title: Gradient 'Pipo' (Bloom mesh: apricot, sky, paper)
category: backgrounds
kind: gradient
tags: gradient,mesh,animated,light-theme,warm
use_when: Soft warm light-mode background (mesh blobs); calm, friendly, paper-like light theme
source: Caliber 2026 (2026-10-02)
hash: 8b2f67984811
added: 2026-10-17
---

# Gradient 'Pipo' (Bloom mesh: apricot, sky, paper)

## Notes

Caliber: became the LIGHT theme for landing + dashboard (dark theme kept separately).

## Original prompt (verbatim)

Recreate the "Pipo" gradient from 21st.dev (https://21st.dev/community/gradients).

Style: Bloom Field. a mesh gradient: one radial blob per colour anchored at its own point, blended together (CSS layered `radial-gradient`s over a solid backdrop).
Palette: #E6B093 (Apricot) @ 0%, #A3CEFF (Sky blue) @ 10%, #FAF9EF (Paper) @ 73%

Motion: this gradient is animated. Drive it from a requestAnimationFrame loop with an elapsed-seconds clock `t`; let `ph = t * 0.86`, `amt = 0.72`, `dir = 1`, and `spin = ph * dir`. Re-derive the background each frame. Write every modulation so it is exactly 0 at `ph = 0` (use `cos(x) - 1`, or `sin(x + p) - sin(p)`), otherwise the gradient snaps when motion starts. For this type (mesh): give each blob a STATIC per-blob phase `p` (hash of the seed) and add `(sin(ph * 0.55 + p) - sin(p)) * 14 * amt` to its x, `(sin(ph * 0.43 + p2) - sin(p2)) * 14 * amt` to its y. Never animate the seed itself through a `fract(sin(x) * 43758)` hash — that is chaotic, not continuous, and renders as white-noise flicker.
Do not quantise the animated values (no Math.round on the angle, centre or stop positions) — rounding them per frame is what makes the motion visibly step.

Ready-to-use CSS (apply to any full-bleed element):
```css
.gradient {
  /* CSS approximation: the oversized-layer soften blur, the bitmap grain texture require canvas. Export an image for the exact result. */
  background-color: #FAF9EF;
  background-image: url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)' opacity='0.305'/></svg>"), radial-gradient(circle at 68.1% 46.03%, rgba(230, 176, 147, 1) 0%, rgba(230, 176, 147, 0.844) 10.28%, rgba(230, 176, 147, 0.5) 20.55%, rgba(230, 176, 147, 0.156) 30.83%, rgba(230, 176, 147, 0) 41.1%), radial-gradient(circle at 25.17% 75.99%, rgba(163, 206, 255, 1) 0%, rgba(163, 206, 255, 0.844) 11.15%, rgba(163, 206, 255, 0.5) 22.3%, rgba(163, 206, 255, 0.156) 33.45%, rgba(163, 206, 255, 0) 44.6%), radial-gradient(circle at 53.11% 12.71%, rgba(250, 249, 239, 1) 0%, rgba(250, 249, 239, 0.844) 16.66%, rgba(250, 249, 239, 0.5) 33.33%, rgba(250, 249, 239, 0.156) 49.99%, rgba(250, 249, 239, 0) 66.65%);
  background-size: 120px 120px, auto, auto, auto;
  background-blend-mode: overlay, normal, normal, normal;
}
```

If you need to rebuild it from scratch instead of pasting the CSS, use these exact parameters:
```json
{
  "mode": "mesh",
  "colors": [
    {
      "id": "c3_7283",
      "hex": "#E6B093",
      "pos": 0,
      "name": "Apricot"
    },
    {
      "id": "c4_43044",
      "hex": "#A3CEFF",
      "pos": 10,
      "name": "Sky blue"
    },
    {
      "id": "c9_21849",
      "hex": "#FAF9EF",
      "pos": 73,
      "name": "Paper"
    }
  ],
  "angle": 90,
  "centerX": 50,
  "centerY": 50,
  "scale": 68,
  "softness": 26,
  "wave": 12,
  "distortion": 28,
  "grain": 61,
  "vignette": 0,
  "count": 6,
  "fade": 40,
  "envelope": "ramp",
  "spread": -20,
  "soften": 80,
  "pixelCols": 16,
  "pixelRows": 10,
  "pixelAngle": 45,
  "pixelDither": 50,
  "pixelGap": 0,
  "archBase": 70,
  "archHeight": 50,
  "archWidth": 100,
  "archGlow": 55,
  "archEdge": 30,
  "animated": true,
  "speed": 86,
  "motionAmount": 72,
  "motionReverse": false,
  "seed": 1,
  "backdrop": "#FAF8EE"
}
```
