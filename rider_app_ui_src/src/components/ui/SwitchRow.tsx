import React, { useState } from 'react';
import { motion } from 'framer-motion';

interface SwitchRowProps {
  label: string;
  description?: string;
  defaultOn?: boolean;
}

export function SwitchRow({ label, description, defaultOn = true }: SwitchRowProps) {
  const [on, setOn] = useState(defaultOn);

  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      onClick={() => setOn((prev) => !prev)}
      className="flex w-full items-center gap-4 rounded-card bg-surface px-4 py-4 text-left transition-colors duration-150 ease-swift active:bg-canvas">
      
      <span className="min-w-0 flex-1">
        <span className="block text-[17px] font-bold text-ink">{label}</span>
        {description &&
        <span className="block text-micro font-semibold text-ink-muted">{description}</span>
        }
      </span>
      <span
        className={`flex h-11 w-[68px] shrink-0 items-center rounded-full p-1 transition-colors duration-200 ease-swift ${
        on ? 'justify-end bg-online' : 'justify-start bg-line'}`
        }>
        
        <motion.span
          layout
          transition={{ type: 'spring', stiffness: 620, damping: 34 }}
          className="block h-9 w-9 rounded-full bg-white shadow-float" />
        
      </span>
    </button>);

}