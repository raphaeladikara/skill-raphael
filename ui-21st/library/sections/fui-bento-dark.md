---
name: fui-bento-dark
title: FUI bento grid (dark): big graphic on top, blurred text panel below
category: sections
kind: component
file: bento.tsx
deps: clsx, framer-motion
tags: bento,cards,features,dark,framer-motion
use_when: Feature or stat cards that need a dramatic visual: 6-col bento (3+3 / 2+2+2), each card a large graphic area with a backdrop-blur text panel overlapping its bottom; works recoloured as dark teal on a light page
source: SINAPS (Lomba Satu Data), 2026-10-18
hash: 478309009fac
added: 2026-10-18
---

# FUI bento grid (dark): big graphic on top, blurred text panel below

## Notes

Ported to BentoCard + StatTile (mvp/src/components/ui/bento.tsx): radial teal gradient, inset sage glow, ring white/10, graphic h-[18rem] with live mini visuals (slice canvas, gauges, waffle, chat). Corner rounding per grid position (rounded-tl/tr/bl/br-[2.5rem]). Replace the demo copy entirely; it is satirical.

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
bento.tsx

"use client";
import { clsx } from "clsx";
import { motion } from "framer-motion";

export default function FUIBentoGridDark() {
     return (
          <div className="pt-32 container mx-auto bg-[#] min-w-screen flex flex-col p-10 bg-gray-950/10">
            <h1 className="font-geistMono tracking-tight text-3xl md:text-5xl">
              Sales
            </h1>
            <p className="max-w-3xl text-2xl/8 font-medium tracking-tight mt-2 bg-gradient-to-br from-black/90 to-black/80 bg-clip-text text-transparent 
            from-black to-gray-400/20
            dark:from-white dark:to-white/40">
              Know more about your customers than they do.
            </p>
            <div className="mt-10 grid grid-cols-1 gap-4 sm:mt-16 lg:grid-cols-6 lg:grid-rows-2">
              <BentoCard
                eyebrow="Insight"
                title="Get perfect clarity"
                description="PerkAI uses social engineering to build a detailed financial picture of your leads. Know their budget, compensation package, social security number, and more."
                graphic={
                  <div className="absolute inset-0 bg-[url(https://cdn.21st.dev/assets/mirror/82/8216d38fc7b6e661002e520eceae40f036741db2f2281729f62bc2885f168bff.png)] object-fill" />
                }
                className="max-lg:rounded-t-4xl lg:col-span-3 lg:rounded-tl-4xl"
              />
              <BentoCard
                eyebrow="Analysis"
                title="Undercut your competitors"
                description="With our advanced data mining, you’ll know which companies your leads are talking to and exactly how much they’re being charged."
                graphic={
                  <div className="absolute inset-0 bg-[url(https://cdn.21st.dev/assets/mirror/38/388b12fd04fd758f8af4db4ff90a362fdefabc172e3f532d6595f2ba4a86a76b.png)] object-fill" />
                }
                className="lg:col-span-3 lg:rounded-tr-4xl"
              />
              <BentoCard
                eyebrow="Speed"
                title="Built for power users"
                description="It’s never been faster to cold email your entire contact list using our streamlined keyboard shortcuts."
                graphic={
                  <div className="absolute  inset-0 -top-20 -left-60 bg-[url(https://cdn.21st.dev/assets/mirror/e1/e11e231bc3af40fd287e47edf1ae6caf40f5421f6fadee45b6e10a635ddea8c0.png)] object-scale-down  bg-black" />
                }
                className="lg:col-span-2 lg:rounded-bl-4xl"
              />
              <BentoCard
                eyebrow="Source"
                title="Get the furthest reach"
                description="Bypass those inconvenient privacy laws to source leads from the most unexpected places."
                graphic={
                  <div className="absolute inset-0 bg-[url(https://cdn.21st.dev/assets/mirror/05/05a9718924c99a9e5c6d5a61b9ea8d088c6f2ce2515716d60f69064dc178462f.png)] object-contain" />
                }
                className="lg:col-span-2"
              />
              <BentoCard
                eyebrow="Limitless"
                title="Sell globally"
                description="PerkAI helps you sell in locations currently under international embargo."
                graphic={
                  <div className="absolute inset-0 -top-44 -left-60 bg-[url(https://cdn.21st.dev/assets/mirror/1a/1aa128de57f039b2b380e36a1b540ebbabe497490bb78e07ec6ab8c8cb9383f8.png)] object-contain" />
                }
                className="max-lg:rounded-b-4xl lg:col-span-2 lg:rounded-br-4xl"
              />
            </div>
          </div>
        );
      }
  export function BentoCard({
     dark = false,
     className = "",
     eyebrow,
     title,
     description,
     graphic,
     fade = [],
   }: {
      dark?: boolean;
      className?: string;
      eyebrow: React.ReactNode;
      title: React.ReactNode;
      description: React.ReactNode;
      graphic?: React.ReactNode;
      fade?: ("top" | "bottom")[];
    }) {
        return (
          <motion.div
            initial="idle"
            whileHover="active"
            variants={{ idle: {}, active: {} }}
            data-dark={dark ? "true" : undefined}
            className={clsx(
              className,
              "group relative flex flex-col overflow-hidden rounded-lg ",
              "bg-black dark:bg-transparent transform-gpu dark:[border:1px_solid_rgba(255,255,255,.1)] dark:[box-shadow:0_-20px_80px_-20px_#8686f01f_inset] bg-black   shadow-sm ring-1 ring-white/10",
              "data-[dark]:bg-gray-800 data-[dark]:ring-white/15"
            )}
          >
            <div className="relative h-[29rem] shrink-0 ">
              {graphic}
              {fade.includes("top") && (
                <div className="absolute inset-0 bg-gradient-to-b from-white to-50% group-data-[dark]:from-gray-800 group-data-[dark]:from-[-25%] opacity-25" />
              )}
              {fade.includes("bottom") && (
                <div className="absolute inset-0 bg-gradient-to-t from-white to-50% group-data-[dark]:from-gray-800 group-data-[dark]:from-[-25%] opacity-25 " />
              )}
            </div>
            <div className="relative p-10  z-20 isolate mt-[-110px] h-[14rem] backdrop-blur-xl text-white ">
              <h1>{eyebrow}</h1>
              <p className="mt-1 text-2xl/8 font-medium tracking-tight dark:text-gray-100 text-gray-150 group-data-[dark]:text-white">
                {title}
              </p>
              <p className="mt-2 max-w-[600px] text-sm/6 text-gray-100 dark:text-gray-300 group-data-[dark]:text-gray-400">
                {description}
              </p>
            </div>
          </motion.div>
        );
      }
      

demo.tsx
import FUIBentoGridDark from "@/components/ui/bento";

export default function DemoOne() {
  return <FUIBentoGridDark />;
}

```

Install NPM dependencies:
```bash
clsx, framer-motion
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
