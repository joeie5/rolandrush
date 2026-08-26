import React from 'react';
import { cn } from '../../utils/cn';

export function Panel({
  children,
  className,
  padded = false




}: {children: React.ReactNode;className?: string;padded?: boolean;}) {
  return (
    <section
      className={cn(
        'rounded-xl border border-line bg-surface shadow-card',
        padded && 'p-4',
        className
      )}>
      
      {children}
    </section>);

}

export function PanelHeader({
  title,
  meta,
  action,
  className





}: {title: React.ReactNode;meta?: React.ReactNode;action?: React.ReactNode;className?: string;}) {
  return (
    <header
      className={cn(
        'flex items-start justify-between gap-4 border-b border-line px-4 py-3',
        className
      )}>
      
      <div className="min-w-0">
        <h2 className="text-md font-semibold text-ink">{title}</h2>
        {meta ? <p className="mt-0.5 text-sm text-ink-muted">{meta}</p> : null}
      </div>
      {action ? <div className="flex shrink-0 items-center gap-2">{action}</div> : null}
    </header>);

}

export function DefinitionList({
  items,
  columns = 1,
  className




}: {items: {label: string;value: React.ReactNode;}[];columns?: 1 | 2 | 3;className?: string;}) {
  return (
    <dl
      className={cn(
        'grid gap-x-6 gap-y-3',
        columns === 1 && 'grid-cols-1',
        columns === 2 && 'grid-cols-2',
        columns === 3 && 'grid-cols-3',
        className
      )}>
      
      {items.map((item) =>
      <div key={item.label} className="min-w-0">
          <dt className="text-2xs font-semibold uppercase tracking-wider text-ink-faint">
            {item.label}
          </dt>
          <dd className="mt-0.5 truncate text-base text-ink">{item.value}</dd>
        </div>
      )}
    </dl>);

}

export function SectionLabel({ children }: {children: React.ReactNode;}) {
  return (
    <h3 className="mb-2 text-2xs font-semibold uppercase tracking-wider text-ink-faint">
      {children}
    </h3>);

}

export function Divider({ className }: {className?: string;}) {
  return <div className={cn('h-px w-full bg-line', className)} />;
}