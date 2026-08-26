import React from 'react';
import { twMerge } from 'tailwind-merge';

type Variant = 'primary' | 'success' | 'alert' | 'secondary' | 'ghost';
type Size = 'md' | 'lg' | 'xl';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  fullWidth?: boolean;
}

const variants: Record<Variant, string> = {
  primary: 'bg-coral text-white active:bg-coral-hover',
  success: 'bg-online text-white active:bg-online-hover',
  alert: 'bg-alert text-white active:bg-alert-hover',
  secondary: 'bg-surface text-ink border-2 border-line active:bg-canvas',
  ghost: 'bg-transparent text-ink-muted active:bg-canvas'
};

const sizes: Record<Size, string> = {
  md: 'h-14 px-5 text-base rounded-btn',
  lg: 'h-16 px-6 text-lg rounded-btn',
  xl: 'h-[72px] px-7 text-xl rounded-btn'
};

export function Button({
  variant = 'primary',
  size = 'lg',
  fullWidth = true,
  className,
  children,
  ...rest
}: ButtonProps) {
  return (
    <button
      {...rest}
      className={twMerge(
        'inline-flex items-center justify-center gap-2.5 font-bold tracking-[-0.01em] transition-[transform,background-color] duration-150 ease-swift active:scale-[0.985] disabled:opacity-40 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-ink/20',
        variants[variant],
        sizes[size],
        fullWidth && 'w-full',
        className
      )}>
      
      {children}
    </button>);

}