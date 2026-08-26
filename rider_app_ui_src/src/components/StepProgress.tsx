import React from 'react';

export const stepLabels = ['En route', 'Pickup', 'Delivering', 'Delivered'] as const;

export function StepProgress({ step }: {step: number;}) {
  return (
    <ol className="flex items-center gap-1.5" aria-label="Delivery progress">
      {stepLabels.map((label, index) => {
        const done = index < step;
        const current = index === step;
        return (
          <li key={label} className="flex-1">
            <span
              className={`block h-2 rounded-full transition-colors duration-200 ease-swift ${
              done ? 'bg-online' : current ? 'bg-coral' : 'bg-line'}`
              } />
            
            <span
              className={`mt-1.5 block text-[12px] font-extrabold uppercase tracking-wide ${
              current ? 'text-coral' : done ? 'text-online' : 'text-ink-faint'}`
              }>
              
              {label}
            </span>
          </li>);

      })}
    </ol>);

}