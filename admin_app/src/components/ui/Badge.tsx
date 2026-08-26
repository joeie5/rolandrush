import React from 'react';
import { CheckCircle2Icon, ClockIcon, FlagIcon } from 'lucide-react';
import type { RiskTier, Tone } from '../../types';
import { TIER_META, TONE_CLASSES, toneFor } from '../../utils/tiers';
import { titleCase } from '../../utils/format';
import { cn } from '../../utils/cn';

export function Badge({
  tone = 'neutral',
  children,
  className




}: {tone?: Tone;children: React.ReactNode;className?: string;}) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 whitespace-nowrap rounded-md border px-1.5 py-0.5 text-2xs font-semibold uppercase tracking-wide',
        TONE_CLASSES[tone],
        className
      )}>
      
      {children}
    </span>);

}

export function StatusBadge({
  status,
  className



}: {status: string;className?: string;}) {
  return (
    <Badge tone={toneFor(status)} className={className}>
      {titleCase(status)}
    </Badge>);

}

const TIER_ICON: Record<RiskTier, React.ComponentType<{className?: string;}>> = {
  auto: CheckCircle2Icon,
  review: ClockIcon,
  urgent: FlagIcon
};

export function TierBadge({
  tier,
  withLabel = true,
  className




}: {tier: RiskTier;withLabel?: boolean;className?: string;}) {
  const meta = TIER_META[tier];
  const Icon = TIER_ICON[tier];
  return (
    <Badge tone={meta.tone} className={className}>
      <Icon className="h-3 w-3" />
      {withLabel ? tier === 'auto' ? 'Auto' : meta.short : null}
    </Badge>);

}

export function Dot({ tone = 'neutral' }: {tone?: Tone;}) {
  const map: Record<Tone, string> = {
    ok: 'bg-ok',
    warn: 'bg-warn',
    urgent: 'bg-coral',
    info: 'bg-info',
    neutral: 'bg-ink-faint'
  };
  return <span className={cn('h-1.5 w-1.5 rounded-full', map[tone])} />;
}

export function CountBadge({
  count,
  tone = 'warn'



}: {count: number;tone?: Tone;}) {
  if (!count) return null;
  return (
    <span
      className={cn(
        'tabular inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-md border px-1 text-2xs font-semibold',
        TONE_CLASSES[tone]
      )}>
      
      {count}
    </span>);

}