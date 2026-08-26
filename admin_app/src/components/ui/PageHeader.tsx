import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronLeftIcon } from 'lucide-react';
import { cn } from '../../utils/cn';

export function PageHeader({
  title,
  subtitle,
  actions,
  backTo,
  backLabel,
  phaseTwo,
  className








}: {title: string;subtitle?: React.ReactNode;actions?: React.ReactNode;backTo?: string;backLabel?: string;phaseTwo?: boolean;className?: string;}) {
  return (
    <div className={cn('mb-5', className)}>
      {backTo ?
      <Link
        to={backTo}
        className="mb-2 inline-flex items-center gap-1 text-sm text-ink-muted transition-colors duration-150 ease-exp hover:text-ink">
        
          <ChevronLeftIcon className="h-3.5 w-3.5" />
          {backLabel ?? 'Back'}
        </Link> :
      null}
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-semibold tracking-[-0.01em] text-ink">
              {title}
            </h1>
            {phaseTwo ?
            <span className="rounded-md border border-line-strong bg-line-soft px-1.5 py-0.5 text-2xs font-semibold uppercase tracking-wide text-ink-muted">
                Phase two
              </span> :
            null}
          </div>
          {subtitle ?
          <p className="mt-1 max-w-3xl text-base text-ink-muted">{subtitle}</p> :
          null}
        </div>
        {actions ?
        <div className="flex shrink-0 items-center gap-2">{actions}</div> :
        null}
      </div>
    </div>);

}