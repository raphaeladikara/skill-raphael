---
name: visualize-booking-calendar
title: Booking calendar with count badges
category: forms
kind: component
file: visualize-booking.tsx
deps: framer-motion,lucide-react
tags: calendar,booking,availability,badge,hover
use_when: Availability or booking calendar: rounded day tiles, a count badge in the corner that grows into the centre on hover, dark weekday pills, a side/under panel describing the hovered or picked date
source: Petropole.id, 2026-10-20
hash: d31ed1782f06
added: 2026-10-20
---

# Booking calendar with count badges

## Notes

Ported to vanilla in Petropole booking.js: badge layoutId swap replaced by one element using container-query units (corner = translate(calc(50cqw - 14px), calc(50cqh - 14px)), hover = translate(0,0) scale(1.9)). Weekend tiles tinted (they price differently), full days hatched, range selection tinted clay. Dropped the Columns/Grid toggle; the Bookings panel became a peek line + slot chips under the grid. Recolour from zinc/black to the app palette. Original DAYS sample data omitted from the saved prompt.

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
visualize-booking.tsx
// component.tsx
import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Columns3, Grid } from 'lucide-react';

export type DayType = {
  day: string;
  classNames: string;
  meetingInfo?: {
    date: string;
    time: string;
    title: string;
    participants: string[];
    location: string;
  }[];
};

interface DayProps {
  classNames: string;
  day: DayType;
  onHover: (day: string | null) => void;
}

const Day: React.FC<DayProps> = ({ classNames, day, onHover }) => {
  const [isHovered, setIsHovered] = useState(false);
  return (
    <>
      <motion.div
        className={`relative flex items-center justify-center py-1 ${classNames}`}
        style={{ height: '4rem', borderRadius: 16 }}
        onMouseEnter={() => {
          setIsHovered(true);
          onHover(day.day);
        }}
        onMouseLeave={() => {
          setIsHovered(false);
          onHover(null);
        }}
        id={`day-${day.day}`}
      >
        <motion.div className="flex flex-col items-center justify-center">
          {!(day.day[0] === '+' || day.day[0] === '-') && (
            <span className="text-sm text-white">{day.day}</span>
          )}
        </motion.div>
        {day.meetingInfo && (
          <motion.div
            className="absolute bottom-1 right-1 flex size-5 items-center justify-center rounded-full bg-zinc-700 p-1 text-[10px] font-bold text-white"
            layoutId={`day-${day.day}-meeting-count`}
            style={{
              borderRadius: 999,
            }}
          >
            {day.meetingInfo.length}
          </motion.div>
        )}

        <AnimatePresence>
          {day.meetingInfo && isHovered && (
            <div className="absolute inset-0 flex size-full items-center justify-center">
              <motion.div
                className="flex size-10 items-center justify-center bg-zinc-700 p-1 text-xs font-bold text-white"
                layoutId={`day-${day.day}-meeting-count`}
                style={{
                  borderRadius: 999,
                }}
              >
                {day.meetingInfo.length}
              </motion.div>
            </div>
          )}
        </AnimatePresence>
      </motion.div>
    </>
  );
};

const CalendarGrid: React.FC<{ onHover: (day: string | null) => void }> = ({
  onHover,
}) => {
  return (
    <div className="grid grid-cols-7 gap-2">
      {DAYS.map((day, index) => (
        <Day
          key={`${day.day}-${index}`}
          classNames={day.classNames}
          day={day}
          onHover={onHover}
        />
      ))}
    </div>
  );
};

const InteractiveCalendar = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  const [moreView, setMoreView] = useState(false);
  const [hoveredDay, setHoveredDay] = useState<string | null>(null);

  const handleDayHover = (day: string | null) => {
    setHoveredDay(day);
  };

  const sortedDays = React.useMemo(() => {
    if (!hoveredDay) return DAYS;
    return [...DAYS].sort((a, b) => {
      if (a.day === hoveredDay) return -1;
      if (b.day === hoveredDay) return 1;
      return 0;
    });
  }, [hoveredDay]);

  return (
    <AnimatePresence mode="wait">
      <motion.div
        ref={ref}
        className="relative mx-auto my-10 flex w-full flex-col items-center justify-center gap-8 lg:flex-row"
        {...props}
      >
        <motion.div layout className="w-full max-w-lg">
          <motion.div
            key="calendar-view"
            className="flex w-full flex-col gap-4"
          >
            <div className="flex w-full items-center justify-between">
              <motion.h2 className="mb-2 text-4xl font-bold tracking-wider text-zinc-300">
                LN <span className="opacity-50">2024</span>
              </motion.h2>
              <motion.button
                className="relative flex items-center gap-3 rounded-lg border border-[#323232] px-1.5 py-1 text-[#323232]"
                onClick={() => setMoreView(!moreView)}
              >
                <Columns3 className="z-[2]" />
                <Grid className="z-[2]" />
                <div
                  className="absolute left-0 top-0 h-[85%] w-7 rounded-md bg-white transition-transform duration-300"
                  style={{
                    top: '50%',
                    transform: moreView
                      ? 'translateY(-50%) translateX(40px)'
                      : 'translateY(-50%) translateX(4px)',
                  }}
                ></div>
              </motion.button>
            </div>
            <div className="grid grid-cols-7 gap-2">
              {daysOfWeek.map((day) => (
                <div
                  key={day}
                  className="px-0/5 rounded-xl bg-[#323232] py-1 text-center text-xs text-white"
                >
                  {day}
                </div>
              ))}
            </div>
            <CalendarGrid onHover={handleDayHover} />
          </motion.div>
        </motion.div>
        {moreView && (
          <motion.div
            className="w-full max-w-lg"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            transition={{ duration: 0.3 }}
          >
            <motion.div
              key="more-view"
              className="mt-4 flex w-full flex-col gap-4"
            >
              <div className="flex w-full flex-col items-start justify-between">
                <motion.h2 className="mb-2 text-4xl font-bold tracking-wider text-zinc-300">
                  Bookings
                </motion.h2>
                <p className="font-medium text-zinc-300/50">
                  See upcoming and past events booked through your event type
                  links.
                </p>
              </div>
              <motion.div
                className="flex h-[620px] flex-col items-start justify-start overflow-hidden overflow-y-scroll rounded-xl border-2 border-[#323232] shadow-md"
                layout
              >
                <AnimatePresence>
                  {sortedDays
                    .filter((day) => day.meetingInfo)
                    .map((day) => (
                      <motion.div
                        key={day.day}
                        className={`w-full border-b-2 border-[#323232] py-0 last:border-b-0`}
                        layout
                      >
                        {day.meetingInfo &&
                          day.meetingInfo.map((meeting, mIndex) => (
                            <motion.div
                              key={mIndex}
                              className="border-b border-[#323232] p-3 last:border-b-0"
                              initial={{ opacity: 0, y: 10 }}
                              animate={{ opacity: 1, y: 0 }}
                              exit={{ opacity: 0, y: -10 }}
                              transition={{
                                duration: 0.2,
                                delay: mIndex * 0.05,
                              }}
                            >
                              <div className="mb-2 flex items-center justify-between">
                                <span className="text-sm text-white">
                                  {meeting.date}
                                </span>
                                <span className="text-sm text-white">
                                  {meeting.time}
                                </span>
                              </div>
                              <h3 className="mb-1 text-lg font-semibold text-white">
                                {meeting.title}
                              </h3>
                              <p className="mb-1 text-sm text-zinc-600">
                                {meeting.participants.join(', ')}
                              </p>
                              <div className="flex items-center text-blue-500">
                                <svg
                                  className="mr-1 h-4 w-4"
                                  fill="none"
                                  stroke="currentColor"
                                  viewBox="0 0 24 24"
                                  xmlns="http://www.w3.org/2000/svg"
                                >
                                  <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    strokeWidth={2}
                                    d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                                  />
                                </svg>
                                <span className="text-sm">
                                  {meeting.location}
                                </span>
                              </div>
                            </motion.div>
                          ))}
                      </motion.div>
                    ))}
                </AnimatePresence>
              </motion.div>
            </motion.div>
          </motion.div>
        )}
      </motion.div>
    </AnimatePresence>
  );
});
InteractiveCalendar.displayName = 'InteractiveCalendar';

export default InteractiveCalendar;

const DAYS: DayType[] = [
  // ... sample month: 31 day entries plus leading/trailing padding days ('-3'..'-1', '+1', '+2').
  // Weekends use 'bg-zinc-700/20', weekdays 'bg-[#1e1e1e]'; days with bookings add
  // 'cursor-pointer' and a meetingInfo array of { date, time, title, participants, location }.
  // (Full sample data omitted when saving: it is placeholder meetings only.)
];

const daysOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

demo.tsx
// demo.tsx
import InteractiveCalendar from '@/components/ui/visualize-booking';

const InteractiveCalendarDemo = () => {
  return (
    <main className="flex min-h-screen w-full flex-col items-center justify-start bg-black px-4 py-10 md:justify-center">
      <InteractiveCalendar />
    </main>
  );
};

export { InteractiveCalendarDemo as DemoOne };
```

Install NPM dependencies:
```bash
lucide-react, framer-motion
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
