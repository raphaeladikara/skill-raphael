---
name: orbit-spotlight-gallery
title: Orbit spotlight gallery
category: sections
kind: component
file: orbit-spotlight-gallery.tsx
deps: lucide-react
tags: gallery,orbit,picker,motion,lucide
use_when: Pick one item from a small set (5-10) shown orbiting in an ellipse; click flies it into a spotlight with caption; good for module/course pickers and portfolios
source: SINAPS (Lomba Satu Data), 2026-10-17
hash: 69e8fbe7bc11
added: 2026-10-17
---

# Orbit spotlight gallery

## Notes

Needs shadcn tokens (bg-background, text-muted-foreground, chart-2). Header text 'ORBIT / WORKS' is hard-coded English, translate it. Use real thumbnails (for SINAPS: MRI slice renders).

## Original prompt (verbatim)

You are given a task to integrate an existing React component in the codebase

The codebase should support:
- shadcn project structure  
- Tailwind CSS
- Typescript

If it doesn't, provide instructions on how to setup project via shadcn CLI, install Tailwind or Typescript.

Determine the default path for components and styles. 
If default path for components is not /components/ui, provide instructions on why it's important to create this folder
Copy-paste this component to /components/ui folder:
```tsx
orbit-spotlight-gallery.tsx
"use client";

import * as React from "react";
import { ArrowLeft, ArrowRight, ImageOff, Pause, Play } from "lucide-react";

export interface OrbitSpotlightItem {
  src: string;
  alt?: string;
  title: string;
  meta?: string;
  description?: string;
}

type DivProps = React.ComponentProps<"div">;
export interface OrbitSpotlightGalleryProps extends DivProps {
  items: OrbitSpotlightItem[];
  selected?: number | null;
  defaultSelected?: number | null;
  onSelectedChange?: (index: number | null) => void;
  /** Seconds per orbit, minimum 4. Invalid or nonpositive values use 40. */
  orbitSeconds?: number;
  /** Opt in to orbit motion. Automatic selections belong to the host/demo. */
  autoplay?: boolean;
  title?: string;
  ref?: DivProps["ref"];
}

const TAU = Math.PI * 2;
const FLIGHT_MS = 600;
const EASE = "cubic-bezier(0.22, 1, 0.36, 1)";
const focusRing = "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-4 focus-visible:ring-offset-background";

function validIndex(value: number | null | undefined, total: number) {
  return value != null && Number.isInteger(value) && value >= 0 && value < total ? value : null;
}

function Photograph({ item }: { item: OrbitSpotlightItem }) {
  const [failed, setFailed] = React.useState("");
  return failed === item.src ? (
    <span data-image-fallback className="flex h-full w-full items-center justify-center bg-muted text-muted-foreground" role="img" aria-label={`${item.alt ?? item.title} — image unavailable`}><ImageOff className="size-5" aria-hidden /></span>
  ) : <img src={item.src} alt={item.alt ?? item.title} draggable={false} onError={() => setFailed(item.src)} className="h-full w-full object-cover" />;
}

export function OrbitSpotlightGallery({
  items, selected, defaultSelected = null, onSelectedChange, orbitSeconds = 40,
  autoplay = false, title = "Selected work", className, style, ref, onKeyDown, onClick, ...rest
}: OrbitSpotlightGalleryProps) {
  const total = items.length;
  const [localSelected, setLocalSelected] = React.useState(defaultSelected);
  const active = validIndex(selected === undefined ? localSelected : selected, total);
  const [reduced, setReduced] = React.useState(false);
  const [motionOverride, setMotionOverride] = React.useState(null as boolean | null);
  const [size, setSize] = React.useState({ width: 720, height: 510 });
  const root = React.useRef(null as HTMLDivElement | null);
  const nodes = React.useRef([] as (HTMLDivElement | null)[]);
  const buttons = React.useRef([] as (HTMLButtonElement | null)[]);
  const dots = React.useRef([] as (HTMLButtonElement | null)[]);
  const angle = React.useRef(0);
  const hover = React.useRef(null as number | null);
  const focused = React.useRef(false);
  const repaint = React.useRef(null as (() => void) | null);
  const animations = React.useRef([] as Animation[]);
  const lastLayout = React.useRef("");
  const restoreIndex = React.useRef(0);
  const focusRequested = React.useRef(false);
  const drag = React.useRef(null as { angle: number; accumulated: number; moved: boolean; x: number; y: number } | null);
  const suppressClick = React.useRef(false);
  const seconds = Number.isFinite(orbitSeconds) && orbitSeconds > 0 ? Math.max(4, orbitSeconds) : 40;
  const playing = (motionOverride ?? autoplay) && !reduced;
  const latest = React.useRef({ active, total, selected, onSelectedChange, playing, seconds, reduced });
  latest.current = { active, total, selected, onSelectedChange, playing, seconds, reduced };
  const titleId = React.useId();
  const hintId = React.useId();
  const portrait = size.width < 560;
  const frameWidth = size.width * .7;
  const frameHeight = Math.min(frameWidth * .64, size.height * .44);
  const frameTop = size.height * .14;
  const chosen = active === null ? undefined : items[active];

  React.useImperativeHandle(ref, () => root.current as HTMLDivElement);

  React.useEffect(() => {
    const query = matchMedia("(prefers-reduced-motion: reduce)");
    const update = () => setReduced(query.matches);
    update(); query.addEventListener("change", update);
    return () => query.removeEventListener("change", update);
  }, []);

  React.useLayoutEffect(() => {
    const element = root.current;
    if (!element) return;
    const measure = () => {
      const width = element.clientWidth, height = element.clientHeight;
      setSize(previous => previous.width === width && previous.height === height ? previous : { width, height });
    };
    measure();
    const observer = new ResizeObserver(measure);
    observer.observe(element);
    return () => observer.disconnect();
  }, []);

  const request = React.useCallback((next: number | null, focus = false) => {
    const current = latest.current;
    const index = validIndex(next, current.total);
    if (index === current.active) return;
    if (index !== null) restoreIndex.current = index;
    else if (current.active !== null) restoreIndex.current = current.active;
    focusRequested.current = focus;
    if (current.selected === undefined) setLocalSelected(index);
    current.onSelectedChange?.(index);
  }, []);

  const step = React.useCallback((direction: number, focus = false) => {
    const { active: index, total: count } = latest.current;
    if (!count) return;
    request(index === null ? (direction > 0 ? 0 : count - 1) : (index + direction + count) % count, focus);
  }, [request]);

  // One set of image nodes moves between the orbit, the spotlight and the dot ring.
  // Reading the current rectangles also makes rapid retargets start where they are.
  React.useLayoutEffect(() => {
    const element = root.current;
    if (!element) return;
    const bounds = element.getBoundingClientRect();
    const before = nodes.current.map(node => node ? {
      rect: node.getBoundingClientRect(), filter: getComputedStyle(node).filter,
      radius: getComputedStyle(node).borderRadius,
      imageOpacity: getComputedStyle(node.firstElementChild as Element).opacity,
    } : null);
    animations.current.forEach(animation => animation.cancel());
    animations.current = [];
    // Measuring the container is layout, not a selection flight.
    const key = `${active}:${total}`;
    const changed = lastLayout.current !== "" && lastLayout.current !== key;
    lastLayout.current = key;
    let frame = 0, previousTime = 0, start = performance.now();
    const still = reduced || matchMedia("(prefers-reduced-motion: reduce)").matches;

    const position = (index: number) => {
      if (active === index) return { x: size.width * .15, y: frameTop, width: frameWidth, height: frameHeight, scale: 1, depth: 1, blur: 0 };
      if (active !== null) {
        const a = (index - active) / Math.max(1, total) * TAU - Math.PI / 2;
        return { x: size.width / 2 + Math.cos(a) * 70 - 4, y: size.height * .86 + Math.sin(a) * 30 - 4, width: 8, height: 8, scale: 1, depth: 0, blur: 0 };
      }
      const a = index / Math.max(1, total) * TAU + angle.current - Math.PI / 2;
      const depth = (Math.sin(a) + 1) / 2;
      const scale = .64 + depth * .36 + (hover.current === index ? .16 : 0);
      const width = Math.min(112, size.width * .19), height = width * .76;
      return {
        x: size.width / 2 + Math.cos(a) * size.width * (portrait ? .31 : .355) - width * scale / 2,
        y: size.height * .47 + Math.sin(a) * size.height * (portrait ? .32 : .29) - height * scale / 2,
        width, height, scale, depth, blur: hover.current === index ? 0 : (1 - depth) * .7,
      };
    };

    const paint = (animate: boolean) => nodes.current.forEach((node, index) => {
      if (!node || index >= total) return;
      const p = position(index);
      const transform = `translate3d(${p.x}px, ${p.y}px, 0) scale(${p.scale})`;
      const filter = `blur(${p.blur}px)`;
      const radius = active !== null && active !== index ? "50%" : "6px";
      const opacity = active === null || active === index ? "1" : "0";
      node.style.width = `${p.width}px`; node.style.height = `${p.height}px`;
      node.style.transform = transform; node.style.filter = filter; node.style.borderRadius = radius;
      node.style.zIndex = String(active === index ? 30 : 5 + Math.round(p.depth * 10));
      node.dataset.depth = p.depth.toFixed(3);
      const image = node.firstElementChild as HTMLElement;
      image.style.opacity = opacity;
      const old = before[index];
      if (animate && old && old.rect.width > 0) {
        const from = `translate3d(${old.rect.left - bounds.left}px, ${old.rect.top - bounds.top}px, 0) scale(${old.rect.width / p.width}, ${old.rect.height / p.height})`;
        animations.current.push(node.animate([
          { transform: from, filter: old.filter, borderRadius: old.radius },
          { transform, filter, borderRadius: radius },
        ], { duration: FLIGHT_MS, easing: EASE }));
        animations.current.push(image.animate([{ opacity: old.imageOpacity }, { opacity }], { duration: FLIGHT_MS, easing: EASE }));
      }
    });
    repaint.current = () => paint(false);
    paint(changed && !still);
    const tick = (now: number) => {
      const elapsed = previousTime ? Math.min(now - previousTime, 64) : 0;
      previousTime = now;
      if (active === null && (!changed || now - start >= FLIGHT_MS)) {
        const state = latest.current;
        if (state.playing && !focused.current && !document.hidden) {
          angle.current += elapsed / (state.seconds * 1000) * TAU * (hover.current === null ? 1 : .18);
        }
        paint(false);
      }
      frame = requestAnimationFrame(tick);
    };
    if (!still) frame = requestAnimationFrame(tick);
    return () => { cancelAnimationFrame(frame); repaint.current = null; };
  }, [active, total, size, portrait, frameWidth, frameHeight, frameTop, reduced]);

  React.useEffect(() => () => animations.current.forEach(animation => animation.cancel()), []);

  React.useLayoutEffect(() => {
    if (!focusRequested.current) return;
    focusRequested.current = false;
    (active === null ? buttons.current[restoreIndex.current] : dots.current[active])?.focus({ preventScroll: true });
  }, [active]);

  React.useEffect(() => {
    const element = root.current;
    if (!element) return;
    let accumulated = 0, last = -Infinity;
    const wheel = (event: WheelEvent) => {
      if (!latest.current.total || event.ctrlKey || event.metaKey) return;
      const value = Math.abs(event.deltaY) >= Math.abs(event.deltaX) ? event.deltaY : event.deltaX;
      if (!value) return;
      event.preventDefault();
      const now = performance.now();
      if (now - last < 650) return;
      accumulated += value * (event.deltaMode === 1 ? 16 : event.deltaMode === 2 ? element.clientHeight : 1);
      if (Math.abs(accumulated) < 30) return;
      step(Math.sign(accumulated)); accumulated = 0; last = now;
    };
    element.addEventListener("wheel", wheel, { passive: false });
    return () => element.removeEventListener("wheel", wheel);
  }, [step]);

  const motionStyle = { transitionDuration: reduced ? "0ms" : `${FLIGHT_MS}ms`, transitionTimingFunction: EASE };
  return (
    <div {...rest} ref={root} data-slot="orbit-spotlight-gallery" data-state={active === null ? "orbit" : "spotlight"} data-selected={active ?? ""} data-autoplay={autoplay} data-playing={playing && active === null} data-portrait={portrait} data-reduced={reduced}
      role={rest.role ?? "region"} aria-label={rest["aria-label"] ?? "Orbit spotlight image gallery"} aria-describedby={hintId} tabIndex={rest.tabIndex ?? 0}
      className={`relative isolate w-full overflow-hidden bg-background text-foreground ${focusRing} ${className ?? ""}`} style={{ height: "min(560px, 80svh)", ...style }}
      onFocusCapture={event => { focused.current = (event.target as HTMLElement).hasAttribute("data-orbit-trigger"); }} onBlurCapture={event => { focused.current = event.relatedTarget instanceof HTMLElement && event.relatedTarget.hasAttribute("data-orbit-trigger"); }}
      onKeyDown={event => {
        onKeyDown?.(event); if (event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey) return;
        if (event.key === "ArrowRight" || event.key === "ArrowLeft") { event.preventDefault(); step(event.key === "ArrowRight" ? 1 : -1, true); }
        else if (event.key === "Escape" && active !== null) { event.preventDefault(); request(null, true); }
        else if ((event.key === "Home" || event.key === "End") && total) { event.preventDefault(); request(event.key === "Home" ? 0 : total - 1, true); }
      }}
      onClick={event => { onClick?.(event); if (!event.defaultPrevented && event.target === event.currentTarget && active !== null) request(null, true); }}>
      <div className="pointer-events-none absolute inset-x-5 top-4 z-40 flex items-center justify-between">
        <span className="font-mono text-[10px] tracking-[.2em] text-muted-foreground">ORBIT <span className="mx-2 text-border">/</span> {String(total).padStart(2, "0")} WORKS</span>
        {active !== null ? <button type="button" onClick={() => request(null, true)} className={`pointer-events-auto flex h-9 items-center gap-2 rounded-full px-3 text-xs hover:bg-muted ${focusRing}`}><ArrowLeft className="size-3.5" aria-hidden />Back to orbit</button>
          : !reduced && total > 0 && <button type="button" data-motion-toggle aria-label={playing ? "Pause orbit" : "Play orbit"} aria-pressed={playing} onClick={() => setMotionOverride(!playing)} className={`pointer-events-auto flex size-9 items-center justify-center rounded-full hover:bg-muted ${focusRing}`}>{playing ? <Pause className="size-3.5" aria-hidden /> : <Play className="size-3.5" aria-hidden />}</button>}
      </div>

      <div aria-hidden className="pointer-events-none absolute rounded-[50%] border border-border/70 transition-[opacity,transform] motion-reduce:transition-none" style={{ left: portrait ? "19%" : "14.5%", top: portrait ? "15%" : "18%", width: portrait ? "62%" : "71%", height: portrait ? "64%" : "58%", opacity: active === null ? 1 : 0, transform: active === null ? "scale(1)" : "scale(.2)", ...motionStyle }} />
      <div data-orbit-title aria-hidden={active !== null} className="pointer-events-none absolute left-1/2 top-[47%] w-[50%] -translate-x-1/2 -translate-y-1/2 text-center transition-[opacity,filter,transform] motion-reduce:transition-none" style={{ opacity: active === null ? 1 : 0, filter: active === null ? "blur(0px)" : "blur(8px)", ...motionStyle }}>
        <p className="mb-3 font-mono text-[10px] uppercase tracking-[.24em] text-muted-foreground">A collection in motion</p>
        <h2 id={titleId} className="text-[clamp(1.65rem,5.7cqw,3.25rem)] leading-[.98] font-medium tracking-[-.055em]" style={{ fontSize: Math.min(52, size.width * .066) }}>{title}</h2>
        <p className="mt-4 text-[11px] text-muted-foreground">{total ? "Choose a work to bring it closer" : "Add images to start your collection"}</p>
      </div>

      {items.map((item, index) => <div key={`${index}:${item.src}`} ref={node => { nodes.current[index] = node; }} data-orbit-item={index} data-spotlight={active === index} aria-hidden={active !== null && active !== index}
        className="absolute left-0 top-0 origin-top-left overflow-hidden bg-foreground shadow-lg shadow-foreground/10" style={{ width: 90, height: 68, borderRadius: 6, transform: `translate(${(index + 1) * 10}px, 60px)` }}>
        <div data-photograph className="h-full w-full"><Photograph item={item} /></div>
        <button ref={node => { buttons.current[index] = node; }} type="button" data-orbit-trigger={index} aria-label={`View ${item.title}`} tabIndex={active === null ? 0 : -1} disabled={active !== null}
          onMouseEnter={() => { hover.current = index; repaint.current?.(); }} onMouseLeave={() => { hover.current = null; repaint.current?.(); }}
          onClick={() => request(index, true)} className={`absolute inset-0 rounded-[inherit] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring ${active !== null ? "pointer-events-none" : "cursor-pointer"}`} />
      </div>)}

      {chosen && <div data-caption className="pointer-events-none absolute z-30" style={{ left: "15%", top: frameTop + frameHeight + 16, width: "70%" }}>
        <div className="flex items-baseline justify-between gap-3"><h3 className="truncate text-xl font-medium tracking-tight">{chosen.title}</h3><span data-selection-count className="shrink-0 rounded-full border border-chart-2/30 bg-chart-2/10 px-2 py-0.5 font-mono text-[10px] text-foreground">{String(active! + 1).padStart(2, "0")} / {String(total).padStart(2, "0")}</span></div>
        {chosen.meta && <p className="mt-1 truncate font-mono text-[10px] uppercase tracking-[.12em] text-muted-foreground">{chosen.meta}</p>}
        {chosen.description && <p className="mt-2 line-clamp-2 text-xs leading-relaxed text-muted-foreground">{chosen.description}</p>}
      </div>}

      {active !== null && <div data-dot-ring role="group" aria-label="Choose a work" className="absolute left-1/2 z-40 h-[100px] w-[188px] -translate-x-1/2 -translate-y-1/2 touch-none" style={{ top: "86%" }}
        onPointerDown={event => {
          if (event.button !== 0) return;
          const rect = event.currentTarget.getBoundingClientRect();
          drag.current = { angle: Math.atan2(event.clientY - rect.y - 50, event.clientX - rect.x - 94), accumulated: 0, moved: false, x: event.clientX, y: event.clientY };
          suppressClick.current = false;
        }}
        onPointerMove={event => {
          const state = drag.current; if (!state) return;
          if (!state.moved && Math.hypot(event.clientX - state.x, event.clientY - state.y) < 8) return;
          if (!state.moved) event.currentTarget.setPointerCapture(event.pointerId);
          state.moved = true; suppressClick.current = true;
          const rect = event.currentTarget.getBoundingClientRect();
          const next = Math.atan2(event.clientY - rect.y - 50, event.clientX - rect.x - 94);
          state.accumulated += Math.atan2(Math.sin(next - state.angle), Math.cos(next - state.angle)); state.angle = next;
          if (Math.abs(state.accumulated) >= TAU / Math.max(1, total)) { step(Math.sign(state.accumulated)); state.accumulated = 0; }
        }}
        onPointerUp={() => { drag.current = null; }} onPointerCancel={() => { drag.current = null; }} onLostPointerCapture={() => { drag.current = null; }}>
        <span aria-hidden className="pointer-events-none absolute left-6 top-5 h-[60px] w-[140px] rounded-[50%] border border-border" />
        {items.map((item, index) => {
          const a = (index - active) / Math.max(1, total) * TAU - Math.PI / 2;
          return <button key={index} ref={node => { dots.current[index] = node; }} type="button" data-dot={index} aria-label={`Show ${item.title}`} aria-pressed={index === active} title={item.title}
            onClick={() => { if (!suppressClick.current) request(index, true); suppressClick.current = false; }}
            className={`absolute left-0 top-0 flex size-8 items-center justify-center rounded-full transition-transform motion-reduce:transition-none ${focusRing}`}
            style={{ transform: `translate(${78 + Math.cos(a) * 70}px, ${34 + Math.sin(a) * 30}px)`, ...motionStyle }}>
            <span aria-hidden className={`size-2 rounded-full ${index === active ? "bg-chart-2 ring-1 ring-chart-2 ring-offset-4 ring-offset-background" : "bg-muted-foreground/60"}`} />
          </button>;
        })}
      </div>}

      <div className="pointer-events-none absolute inset-x-5 bottom-4 z-40 flex items-center justify-between gap-2">
        <p id={hintId} className="text-[10px] text-muted-foreground">{active === null ? "Click a work · scroll to explore" : "Drag the dots · Esc to return"}</p>
        <div className="pointer-events-auto flex items-center gap-1">
          <button type="button" aria-label="Previous work" disabled={total < 2 && active !== null || !total} onClick={() => step(-1, true)} className={`flex size-9 items-center justify-center rounded-full hover:bg-muted disabled:opacity-30 ${focusRing}`}><ArrowLeft className="size-4" aria-hidden /></button>
          <button type="button" aria-label="Next work" disabled={total < 2 && active !== null || !total} onClick={() => step(1, true)} className={`flex size-9 items-center justify-center rounded-full hover:bg-muted disabled:opacity-30 ${focusRing}`}><ArrowRight className="size-4" aria-hidden /></button>
        </div>
      </div>
      <span role="status" aria-live="polite" aria-atomic="true" className="sr-only">{chosen ? `${active! + 1} of ${total}: ${chosen.title}${chosen.meta ? `. ${chosen.meta}` : ""}` : `${total} works in orbit`}</span>
    </div>
  );
}

export default OrbitSpotlightGallery;


demo.tsx
"use client";

import * as React from "react";
import { RotateCcw } from "lucide-react";
import { OrbitSpotlightGallery } from "@/components/ui/orbit-spotlight-gallery";
import type { OrbitSpotlightItem } from "@/components/ui/orbit-spotlight-gallery";

export const ORBIT_DEMO_ITEMS: OrbitSpotlightItem[] = [
  { src: "https://cdn.21st.dev/assets/mirror/83/8327bac3ef5a685ef2b2cd64fa710061deb2f249f45665c3089f549b07064ce6.jpg", alt: "Layered black and white building balconies", title: "Between the lines", meta: "2026 · Architecture study", description: "A study of rhythm, repetition and the spaces in between." },
  { src: "https://cdn.21st.dev/assets/mirror/e8/e8eec2cf6dcd16fe26ee7122707db26752b9a928143abc64df74027dde794285.jpg", alt: "A winding road along a forested coastline", title: "A softer edge", meta: "2026 · Landscape study", description: "Following the quiet meeting of land and water." },
  { src: "https://cdn.21st.dev/assets/mirror/b1/b1b6a4cf0f7a3f3ae792e958a4c3aec8178c3e3579450454b26591a6e33a2bb2.jpg", alt: "Curved blue and white architecture against a clear sky", title: "Open to the sky", meta: "2026 · Form study", description: "Two sweeping curves frame a small piece of sky." },
  { src: "https://cdn.21st.dev/assets/mirror/54/54bb33f690b3f29b7c7addd6f7a32f0ec541503c7df9b65e41eebfb1fbf86703.jpg", alt: "Aerial view of rugged ochre mountain ridges", title: "Earth in folds", meta: "2026 · Aerial study", description: "Light finds its way across a landscape of folded contours." },
  { src: "https://cdn.21st.dev/assets/mirror/04/04a9c958e76ccec242b8c99bb1ed8972c7bf17aed9a238cd5e77479f5bd2e9f8.jpg", alt: "Angular white building with a glass facade", title: "Quiet geometry", meta: "2025 · Architecture study", description: "Clean planes and generous space, held in balance." },
  { src: "https://cdn.21st.dev/assets/mirror/6e/6e3dd7582fc90ec27d7a18951bfb9c209012a7d786e39f63ad541dd9e0fbe816.jpg", alt: "A mountain lake reflecting a soft evening sky", title: "After the light", meta: "2025 · Landscape study", description: "A still surface holds the last colors of the day." },
  { src: "https://cdn.21st.dev/assets/mirror/c2/c273b8a45f272cdc2db41bfbcb4319bb2bc178a0fe87e47515e4d392d063799d.jpg", alt: "Sculptural orange building walls under a blue sky", title: "Warm embrace", meta: "2025 · Form study", description: "An open curve brings warmth to a simple silhouette." },
  { src: "https://cdn.21st.dev/assets/mirror/c1/c1816fcaa56ae4e5a3b1604855261f760baef16279e1af5e8f7464ad5b2cc4ae.jpg", alt: "Small green islands in clear turquoise water", title: "Little worlds", meta: "2025 · Aerial study", description: "Islands, paths and the space that connects them." },
];

export default function OrbitSpotlightGalleryDemo({ autoplay = true }: { autoplay?: boolean }) {
  const [selected, setSelected] = React.useState(null as number | null);
  const [interacted, setInteracted] = React.useState(false);
  const [reduced, setReduced] = React.useState(false);
  const [replay, setReplay] = React.useState(0);
  React.useEffect(() => {
    const query = matchMedia("(prefers-reduced-motion: reduce)");
    const update = () => setReduced(query.matches);
    update(); query.addEventListener("change", update);
    return () => query.removeEventListener("change", update);
  }, []);
  React.useEffect(() => {
    if (!autoplay || interacted || reduced || matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const timers = [
      setTimeout(() => setSelected(2), 2400),
      setTimeout(() => setSelected(3), 4000),
      setTimeout(() => setSelected(null), 6400),
    ];
    return () => timers.forEach(clearTimeout);
  }, [autoplay, interacted, reduced, replay]);

  return <main data-orbit-demo className="flex min-h-svh w-full items-center justify-center bg-background p-4 text-foreground">
    <div className="w-full max-w-[840px]">
      <header className="mb-3 flex h-7 items-center justify-between px-1">
        <h1 className="text-xs font-medium tracking-tight">Orbit spotlight</h1>
        <span className="rounded-full border border-border px-2.5 py-1 text-[10px] text-muted-foreground">Sample collection</span>
      </header>
      <div className="overflow-hidden rounded-3xl border border-border" onPointerDownCapture={() => setInteracted(true)} onKeyDownCapture={() => setInteracted(true)} onWheelCapture={() => setInteracted(true)}>
        <OrbitSpotlightGallery key={replay} items={ORBIT_DEMO_ITEMS} selected={selected} onSelectedChange={setSelected} title="Selected work" autoplay={autoplay} style={{ height: "min(560px, calc(100svh - 116px))" }} />
      </div>
      <footer className="mt-3 flex h-6 items-center justify-between gap-3 px-1 text-[10px] text-muted-foreground">
        <p>Eight sample studies in shape, space &amp; light.</p>
        <button type="button" data-replay onClick={() => { setSelected(null); setInteracted(false); setReplay(value => value + 1); }} className="flex shrink-0 items-center gap-1.5 rounded py-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"><RotateCcw className="size-3" aria-hidden />Replay</button>
      </footer>
    </div>
  </main>;
}

```

Install NPM dependencies:
```bash
lucide-react
```

Implementation Guidelines
 1. Analyze the component structure and identify all required dependencies
 2. Review the component's argumens and state
 3. Identify any required context providers or hooks and install them
 4. Questions to Ask
 - What data/props will be passed to this component?
 - Are there any specific state management requirements?
 - Are there any required assets (images, icons, etc.)?
 - What is the expected responsive behavior?
 - What is the best place to use this component in the app?

Steps to integrate
 0. Copy paste all the code above in the correct directories
 1. Install external dependencies
 2. Fill image assets with Unsplash stock images you know exist
 3. Use lucide-react icons for svgs or logos if component requires them
