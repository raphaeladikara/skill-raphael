---
name: pricing-cards-art
title: Pricing cards with object art
category: sections
kind: component
file: pricing-section.tsx
deps: framer-motion,lucide-react,@radix-ui/react-slot,class-variance-authority
tags: pricing,cards,hover,spring,rates
use_when: Packages or rate cards as cards: big price, an illustration that springs/tilts on hover, diamond feature list, plus one wide card for custom requests
source: Petropole.id, 2026-10-20
hash: 416c2d47ed7f
added: 2026-10-20
---

# Pricing cards with object art

## Notes

Ported to vanilla in Petropole (parts.mjs priceCard + .pc CSS): spring = cubic-bezier(.34,1.56,.64,1) on transform; art = hand-drawn brand-palette SVGs (small/medium/large dog for room sizes, tub/scissors for grooming tiers) instead of thiings.co stock. Use rows (dl) for weekday/weekend splits and a dotted-leader list for add-ons. Pair with a radio-chip picker that rewrites the price text when the price is a matrix (weight x coat). Apply to every price surface (booking estimate too) for consistency.

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
pricing-section.tsx
import * as React from "react";
import { motion } from "framer-motion";
import { cva, type VariantProps } from "class-variance-authority";
import { Slot } from "@radix-ui/react-slot";
import { Diamond, Sparkles } from "lucide-react";

// cn function
function cn(...inputs: (string | undefined | null | false)[]) {
  return inputs.filter(Boolean).join(" ");
}

// Button
const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = "Button";

// Define the props for the PricingCard component
interface PricingCardProps {
  title: string;
  price?: string;
  priceDescription?: string;
  description: string;
  features?: string[];
  buttonText: string;
  imageSrc?: string;
  imageAlt?: string;
  isUnique?: boolean; // A prop to handle the unique request card style
  className?: string;
  useSparkles?: boolean;
}

// Framer Motion variants for animations
const cardVariants = {
  initial: { scale: 1, y: 0 },
  hover: {
    scale: 1.03,
    y: -5,
    boxShadow: "0px 15px 30px -5px hsl(var(--foreground) / 0.1)",
    transition: { type: "spring", stiffness: 300, damping: 20 },
  },
};

const imageVariants = {
  initial: { scale: 1, rotate: 0 },
  hover: {
    scale: 1.1,
    rotate: -5,
    transition: { type: "spring", stiffness: 300, damping: 20 },
  },
};

const PricingCard = React.forwardRef<HTMLDivElement, PricingCardProps>(
  (
    {
      className,
      title,
      price,
      priceDescription,
      description,
      features,
      buttonText,
      imageSrc,
      imageAlt,
      isUnique = false,
      useSparkles = false,
      ...props
    },
    ref
  ) => {
    return (
      <motion.div
        ref={ref}
        variants={cardVariants}
        initial="initial"
        whileHover="hover"
        className={cn(
          "relative flex flex-col justify-between rounded-lg border bg-card p-6 text-card-foreground shadow-sm transition-shadow duration-300",
          className
        )}
        {...props}
      >
        <div className="flex flex-col space-y-4">
          {/* Card Header with optional image */}
          <div className="flex justify-between items-start">
            <div>
              <h3 className="text-xl font-semibold">{title}</h3>
              {price && (
                <div className="mt-2">
                  <span className="text-4xl font-bold">{price}</span>
                  <p className="text-sm text-muted-foreground">
                    {priceDescription}
                  </p>
                </div>
              )}
            </div>
            {imageSrc && (
              <motion.img
                src={imageSrc}
                alt={imageAlt || title}
                width={80}
                height={80}
                className="select-none"
                variants={imageVariants}
              />
            )}
          </div>

          {/* Card Description */}
          <p className="text-muted-foreground">{description}</p>

          {/* Feature List */}
          {features && (
            <ul className="space-y-2 pt-4">
              {features.map((feature, index) => (
                <li key={index} className="flex items-center gap-2">
                  {useSparkles ? (
                    <Sparkles className="h-4 w-4 text-primary" />
                  ) : (
                    <Diamond className="h-4 w-4 text-primary" />
                  )}
                  <span className="text-sm">{feature}</span>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Card Footer with Button */}
        <div className="mt-6">
          <Button className="w-full">{buttonText}</Button>
        </div>
      </motion.div>
    );
  }
);
PricingCard.displayName = "PricingCard";

export default function PricingDemo() {
  const plans = [
    {
      title: "Starter",
      price: "€500",
      priceDescription: "Starting from",
      description:
        "Perfect for small projects and simple websites that need a professional touch.",
      features: [
        "Experienced Designer",
        "Fast Delivery",
        "Responsive Design",
        "Basic SEO Setup",
      ],
      buttonText: "Let's Talk",
      imageSrc: "https://www.thiings.co/_next/image?url=https%3A%2F%2Flftz25oez4aqbxpq.public.blob.vercel-storage.com%2Fimage-gyoxLFpXzRRzVsgPJOKvB2r4tvzpcy.png&w=320&q=75",
      imageAlt: "Pink cherry blossom tree",
    },
    {
      title: "Professional",
      price: "€1000",
      priceDescription: "Starting from",
      description:
        "Ideal for businesses that need a complete website with advanced features and functionality.",
      features: [
        "Experienced Designer",
        "Fast Delivery",
        "Conversion Focused",
        "Advanced Animations",
      ],
      buttonText: "Let's Talk",
      imageSrc: "https://www.thiings.co/_next/image?url=https%3A%2F%2Flftz25oez4aqbxpq.public.blob.vercel-storage.com%2Fimage-v98BP3EQdx0Yd0NkjHPnWx33WvzwGP.png&w=320&q=75",
      imageAlt: "Yellow autumn tree",
    },
    {
      title: "Enterprise",
      price: "€1500+",
      priceDescription: "Starting from",
      description:
        "For complex projects requiring custom development, integrations, and ongoing support.",
      features: [
        "Dedicated Design Team",
        "Priority Support",
        "Custom Development",
        "Full Design System",
      ],
      buttonText: "Let's Talk",
      imageSrc: "https://www.thiings.co/_next/image?url=https%3A%2F%2Flftz25oez4aqbxpq.public.blob.vercel-storage.com%2Fimage-gyoxLFpXzRRzVsgPJOKvB2r4tvzpcy.png&w=320&q=75",
      imageAlt: "Premium design",
      useSparkles: true,
    },
  ];

  return (
    <div className="flex min-h-screen w-full items-center justify-center bg-background px-4 py-12">
      <div className="w-full max-w-5xl space-y-8">
        {/* Title Section */}
        <div className="text-center">
          <p className="text-sm font-semibold uppercase tracking-wider text-primary">
            Pricing Plans
          </p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">
            Transparent Pricing, No Surprises
          </h1>
        </div>

        {/* Pricing Cards Grid */}
        <div className="grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-3">
          {plans.map((plan) => (
            <PricingCard key={plan.title} {...plan} />
          ))}
        </div>

        {/* Unique Request Card */}
        <div className="rounded-lg border bg-card p-6 text-card-foreground shadow-sm">
           <h3 className="text-xl font-semibold">Unique Request</h3>
           <p className="mt-2 text-muted-foreground">Are you looking for something custom? Don't hesitate to contact us, and we'll help brainstorm your product to success.</p>
           <div className="mt-6">
                <Button className="w-full md:w-auto">Let's Talk</Button>
           </div>
        </div>
      </div>
    </div>
  );
}

demo.tsx
(identical to pricing-section.tsx above — the 21st.dev demo file repeats the whole component)
```

Install NPM dependencies:
```bash
lucide-react, framer-motion, @radix-ui/react-slot, class-variance-authority
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
