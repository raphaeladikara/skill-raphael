---
name: color-change-cards
title: Grey-to-colour photo cards with rolling letters
category: sections
kind: component
file: color-change-card.tsx
deps: framer-motion,react-icons
tags: cards,photo,hover,letter-animation,grayscale
use_when: Photo cards for services, FAQs or features: image greyscale until hover, zooms and saturates, title letters roll up one by one, corner arrow turns -45deg
source: Petropole.id, 2026-10-20
hash: 584989f22362
added: 2026-10-20
---

# Grey-to-colour photo cards with rolling letters

## Notes

Ported to vanilla in Petropole (parts.mjs photoCards + .cc CSS): each letter is two stacked spans in a 1.15em clip, translateY(-100%) with transition-delay calc(var(--i)*35ms). Greyscale only for hover-capable >=768px; phones stay in colour. Bottom scrim gradient keeps long body text readable; cards without a link drop the arrow. Real photos only, title as sr-only text plus aria-hidden letter spans.

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
color-change-card.tsx
import React from "react";
import { motion, Variants } from "framer-motion";
import { FiArrowRight } from "react-icons/fi";

const ColorChangeCards = () => {
  return (
    <div className="p-4 py-12 md:p-8">
      <div className="mx-auto grid w-full max-w-6xl grid-cols-1 gap-4 md:grid-cols-2 md:gap-8">
        <Card
          heading="Plan"
          description="Lorem ipsum dolor sit amet consectetur adipisicing elit. Cumque, exercitationem."
          imgSrc="https://cdn.21st.dev/assets/mirror/0c/0cc3b668ef22fda106ef841eb4be48b778db39102a491ba73f2204b21207b549.jpg"
        />
        <Card
          heading="Play"
          description="Lorem ipsum dolor sit amet consectetur adipisicing elit. Cumque, exercitationem."
          imgSrc="https://cdn.21st.dev/assets/mirror/f1/f1c5fdf6a772a0fe68b644c520d34a3bbde50699503fdbdd088eec228e24cdbb.jpg"
        />
        <Card
          heading="Connect"
          description="Lorem ipsum dolor sit amet consectetur adipisicing elit. Cumque, exercitationem."
          imgSrc="https://cdn.21st.dev/assets/mirror/8f/8fc0496dbc528cacc508210b9af7dad8af1ae9db59d58321050482026deb6e3f.jpg"
        />
        <Card
          heading="Support"
          description="Lorem ipsum dolor sit amet consectetur adipisicing elit. Cumque, exercitationem."
          imgSrc="https://cdn.21st.dev/assets/mirror/b2/b20c5987b8d52c5750be0d3a25ca90bf83ea9311e9b6da36039b23740f9f35ed.jpg"
        />
      </div>
    </div>
  );
};

// --- Card Component ---
interface CardProps {
  heading: string;
  description: string;
  imgSrc: string;
}

const Card = ({ heading, description, imgSrc }: CardProps) => {
  return (
    <motion.div
      transition={{ staggerChildren: 0.035 }}
      whileHover="hover"
      className="group relative h-64 w-full cursor-pointer overflow-hidden bg-slate-300"
    >
      <div
        className="absolute inset-0 saturate-100 transition-all duration-500 group-hover:scale-110 md:saturate-0 md:group-hover:saturate-100"
        style={{
          backgroundImage: `url(${imgSrc})`,
          backgroundSize: "cover",
          backgroundPosition: "center",
        }}
      />
      <div className="relative z-20 flex h-full flex-col justify-between p-4 text-slate-300 transition-colors duration-500 group-hover:text-white">
        <FiArrowRight className="ml-auto text-3xl transition-transform duration-500 group-hover:-rotate-45" />
        <div>
          <h4>
            {heading.split("").map((letter, index) => (
              <AnimatedLetter letter={letter} key={index} />
            ))}
          </h4>
          <p>{description}</p>
        </div>
      </div>
    </motion.div>
  );
};

// --- AnimatedLetter Helper Component ---
interface AnimatedLetterProps {
  letter: string;
}

const letterVariants: Variants = {
  hover: {
    y: "-50%",
  },
};

const AnimatedLetter = ({ letter }: AnimatedLetterProps) => {
  return (
    <div className="inline-block h-[36px] overflow-hidden font-semibold text-3xl">
      <motion.span
        className="flex min-w-[4px] flex-col"
        style={{ y: "0%" }}
        variants={letterVariants}
        transition={{ duration: 0.5 }}
      >
        <span>{letter}</span>
        <span>{letter}</span>
      </motion.span>
    </div>
  );
};

export default ColorChangeCards;


demo.tsx
import ColorChangeCards from "@/components/ui/color-change-card";

export default function DemoOne() {
  return <ColorChangeCards />;
}

```

Install NPM dependencies:
```bash
react-icons, framer-motion
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
