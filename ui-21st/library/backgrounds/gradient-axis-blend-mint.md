---
name: gradient-axis-blend-mint
title: Gradient 'Axis Blend' (linear mint: young willow, green tea)
category: backgrounds
kind: gradient
tags: mint,green,linear,light,health
use_when: Soft light mint linear background for health/eco apps: hero, welcome cards, auth panels; derives a fresh green palette with #2F5D46 as the dark primary
source: SIGIZI Sukomalo, 2026-10-29
hash: 56e32ce42785
added: 2026-10-29
---

# Gradient 'Axis Blend' (linear mint: young willow, green tea)

## Notes

Used as the source of SIGIZI's brand scale (50 #F2FAF5 ... 700 #2F5D46). Pure CSS, no deps. Put dark text (#1A362A) on it; works as a full-bleed hero or inside rounded welcome cards.

## Original prompt (verbatim)

Recreate the "Axis Blend gradient" gradient from 21st.dev (https://21st.dev/community/gradients).

Style: Axis Blend. a straight linear gradient along `angle`, colours placed at their `pos`.
Palette: #C6EFDB (Young willow) @ 0%, #C7DED1 (Mauve) @ 0%, #BEF4CF (Young willow) @ 59%, #EEF6E3 (Green tea) @ 98%

Ready-to-use CSS (apply to any full-bleed element):
```css
.gradient {
  background-color: #C6EFDB;
  background-image: linear-gradient(58deg, #C6EFDB 0%, #C7DED1 0%, #BEF4CF 59%, #EEF6E3 98%);
}
```

If you need to rebuild it from scratch instead of pasting the CSS, use these exact parameters:
```json
{
  "mode": "linear",
  "colors": [
    {
      "id": "c1_35761",
      "hex": "#C6EFDB",
      "pos": 0,
      "name": "Young willow"
    },
    {
      "id": "c2_71522",
      "hex": "#C7DED1",
      "pos": 0,
      "name": "Mauve"
    },
    {
      "id": "c3_7283",
      "hex": "#BEF4CF",
      "pos": 59,
      "name": "Young willow"
    },
    {
      "id": "c4_43044",
      "hex": "#EEF6E3",
      "pos": 98,
      "name": "Green tea"
    }
  ],
  "angle": 58,
  "centerX": 50,
  "centerY": 50,
  "scale": 68,
  "softness": 26,
  "wave": 12,
  "distortion": 28,
  "grain": 0,
  "vignette": 0,
  "count": 6,
  "fade": 40,
  "envelope": "ramp",
  "spread": -20,
  "soften": 0,
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
  "animated": false,
  "speed": 40,
  "motionAmount": 50,
  "motionReverse": false,
  "seed": 1,
  "backdrop": "#2F5D46"
}
