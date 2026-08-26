import React from 'react';
import { cn } from '../../utils/cn';

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost' | 'approve';
type Size = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  icon?: React.ComponentType<{className?: string;}>;
  iconRight?: React.ComponentType<{className?: string;}>;
}

const VARIANTS: Record<Variant, string> = {
  primary:
  'bg-coral text-white border-coral hover:bg-coral-hover hover:border-coral-hover',
  secondary:
  'bg-surface text-ink border-line-strong hover:bg-line-soft hover:border-ink-faint',
  danger:
  'bg-surface text-coral-ink border-coral-border hover:bg-coral-soft hover:border-coral',
  approve:
  'bg-surface text-ok-ink border-ok-border hover:bg-ok-soft hover:border-ok',
  ghost:
  'bg-transparent text-ink-muted border-transparent hover:bg-line-soft hover:text-ink'
};

const SIZES: Record<Size, string> = {
  sm: 'h-7 px-2.5 text-xs gap-1.5 rounded-md',
  md: 'h-9 px-3.5 text-base gap-2 rounded-md',
  lg: 'h-10 px-4 text-base gap-2 rounded-lg'
};

export function Button({
  variant = 'secondary',
  size = 'md',
  icon: Icon,
  iconRight: IconRight,
  className,
  children,
  ...rest
}: ButtonProps) {
  return (
    <button
      {...rest}
      className={cn(
        'inline-flex items-center justify-center border font-medium transition-colors duration-150 ease-exp disabled:cursor-not-allowed disabled:opacity-45',
        VARIANTS[variant],
        SIZES[size],
        className
      )}>
      
      {Icon ? <Icon className={size === 'sm' ? 'h-3.5 w-3.5' : 'h-4 w-4'} /> : null}
      {children}
      {IconRight ?
      <IconRight className={size === 'sm' ? 'h-3.5 w-3.5' : 'h-4 w-4'} /> :
      null}
    </button>);

}

export function IconButton({
  icon: Icon,
  label,
  className,
  ...rest



}: React.ButtonHTMLAttributes<HTMLButtonElement> & {icon: React.ComponentType<{className?: string;}>;label: string;}) {
  return (
    <button
      {...rest}
      aria-label={label}
      title={label}
      className={cn(
        'inline-flex h-7 w-7 items-center justify-center rounded-md border border-transparent text-ink-faint transition-colors duration-150 ease-exp hover:border-line-strong hover:bg-line-soft hover:text-ink',
        className
      )}>
      
      <Icon className="h-4 w-4" />
    </button>);

}