import React from 'react';

interface CodeBoxesProps {
  value: string;
  length?: number;
  tone?: 'coral' | 'ink';
  size?: 'md' | 'lg';
}

export function CodeBoxes({ value, length = 4, tone = 'coral', size = 'lg' }: CodeBoxesProps) {
  return (
    <div className="flex justify-center gap-3" role="group" aria-label={`${length} digit code`}>
      {Array.from({ length }).map((_, index) => {
        const digit = value[index];
        const active = index === value.length;
        return (
          <span
            key={index}
            className={`flex items-center justify-center rounded-card border-2 bg-surface font-extrabold tracking-[-0.03em] transition-colors duration-150 ease-swift ${
            size === 'lg' ? 'h-[84px] w-[68px] text-[40px]' : 'h-[68px] w-[56px] text-[32px]'} ${

            digit ?
            tone === 'coral' ?
            'border-coral text-ink' :
            'border-ink text-ink' :
            active ?
            'border-ink/40 text-ink' :
            'border-line text-ink'}`
            }>
            
            {digit ?? ''}
          </span>);

      })}
    </div>);

}