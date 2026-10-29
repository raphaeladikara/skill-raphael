---
name: gradient-ribbon-field-blue
title: Gradient '그라데이션' (Ribbon Field: white, sky, ultramarine, iris)
category: backgrounds
kind: gradient
tags: gradient,animated,stripes,blue,canvas
use_when: Animated striped blue/violet background for a hero or app background; cool, techy, bright
source: Caliber 2026 (2026-10-02)
hash: c5154cd9e863
added: 2026-10-17
---

# Gradient '그라데이션' (Ribbon Field: white, sky, ultramarine, iris)

## Notes

Offered as an option for Caliber; ready CSS approximation included, canvas for exact.

## Original prompt (verbatim)

Recreate the "그라데이션" gradient from 21st.dev (https://21st.dev/community/gradients).

Style: Ribbon Field. a canvas stripe field along `angle`: each stripe is sized by its `pos`, edges are feathered by `softness`, and `wave` bends the bands with a cross-axis sine offset of `(wave / 100) * 0.35 * sin(cross * 2.4 * 2π + clock)`. A CSS linear-gradient is exact only when `wave` is zero.
Palette: #FFFFFF (White) @ 18%, #78B8F9 (Sky blue) @ 57%, #5667FF (Ultramarine) @ 60%, #4D2FF9 (Iris) @ 100%

Motion: this gradient is animated. Drive it from a requestAnimationFrame loop with an elapsed-seconds clock `t`; let `ph = t * 1.00`, `amt = 0.00`, `dir = 1`, and `spin = ph * dir`. Re-derive the background each frame. Write every modulation so it is exactly 0 at `ph = 0` (use `cos(x) - 1`, or `sin(x + p) - sin(p)`), otherwise the gradient snaps when motion starts. For this type (stripes): `angle + sin(spin * 0.6) * 28 * amt` — hard bands must sway, not spin. For a curved stripe field, also advance its wave clock from `20.75` to `20.75 + ph * 1.2`.
Do not quantise the animated values (no Math.round on the angle, centre or stop positions) — rounding them per frame is what makes the motion visibly step.

Ready-to-use CSS (apply to any full-bleed element):
```css
.gradient {
  /* CSS approximation: the curved stripe field, the bitmap grain texture require canvas. Export an image for the exact result. */
  background-color: #FFFFFF;
  background-image: url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)' opacity='0.210'/></svg>"), linear-gradient(32deg, #FFFFFF 4.32%, #FFFFFF 33.18%, #78B8F9 37.86%, #78B8F9 58.14%, #5667FF 58.86%, #5667FF 79.64%, #4D2FF9 80%, #4D2FF9 100%);
  background-size: 120px 120px, auto;
  background-blend-mode: overlay, normal;
}
```

If you need to rebuild it from scratch instead of pasting the CSS, use these exact parameters:
```json
{
  "mode": "stripes",
  "colors": [
    {
      "id": "c997_53717",
      "hex": "#FFFFFF",
      "pos": 18,
      "name": "White"
    },
    {
      "id": "c998_89478",
      "hex": "#78B8F9",
      "pos": 57,
      "name": "Sky blue"
    },
    {
      "id": "c999_25239",
      "hex": "#5667FF",
      "pos": 60,
      "name": "Ultramarine"
    },
    {
      "id": "c1000_61000",
      "hex": "#4D2FF9",
      "pos": 100,
      "name": "Iris"
    }
  ],
  "angle": 32,
  "centerX": 50,
  "centerY": 50,
  "scale": 68,
  "softness": 24,
  "wave": 14,
  "distortion": 28,
  "grain": 42,
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
  "animated": true,
  "speed": 100,
  "motionAmount": 0,
  "motionReverse": false,
  "seed": 174074637,
  "backdrop": "#0B1220"
}
