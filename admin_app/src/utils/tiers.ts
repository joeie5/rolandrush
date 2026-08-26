import type { RiskTier, Tone } from '../types';

/**
 * The three-tier routing language, defined once and reused by every queue so
 * the same colour always means the same thing across the whole dashboard.
 */
export const TIER_META: Record<
  RiskTier,
  {
    label: string;
    short: string;
    tone: Tone;
    description: string;
    /** Left rail applied to a table row / list item carrying this tier. */
    rail: string;
    dot: string;
  }> =
{
  auto: {
    label: 'Auto-approved',
    short: 'Auto',
    tone: 'ok',
    description: 'Resolved automatically. Visible for the record, no decision needed.',
    rail: 'border-l-2 border-l-transparent',
    dot: 'bg-ok'
  },
  review: {
    label: 'Queued for review',
    short: 'Review',
    tone: 'warn',
    description: 'Waiting on a human decision at the next scheduled review.',
    rail: 'border-l-2 border-l-warn/60',
    dot: 'bg-warn'
  },
  urgent: {
    label: 'Flagged — act now',
    short: 'Flagged',
    tone: 'urgent',
    description: 'High-stakes and time-sensitive. Should be handled immediately.',
    rail: 'border-l-2 border-l-coral',
    dot: 'bg-coral'
  }
};

export const TONE_CLASSES: Record<Tone, string> = {
  ok: 'bg-ok-soft text-ok-ink border-ok-border',
  warn: 'bg-warn-soft text-warn-ink border-warn-border',
  urgent: 'bg-coral-soft text-coral-ink border-coral-border',
  info: 'bg-info-soft text-info border-info-border',
  neutral: 'bg-line-soft text-ink-muted border-line-strong'
};

export const STATUS_TONE: Record<string, Tone> = {
  auto_approved: 'ok',
  auto_removed: 'ok',
  approved: 'ok',
  paid: 'ok',
  delivered: 'ok',
  resolved: 'ok',
  active: 'ok',
  live: 'ok',
  completed: 'ok',
  online: 'ok',
  running: 'ok',

  pending: 'warn',
  waiting: 'warn',
  preparing: 'warn',
  awaiting_rider: 'warn',
  in_transit: 'warn',
  invited: 'warn',
  scheduled: 'warn',
  paused: 'warn',
  open: 'warn',

  rejected: 'urgent',
  removed: 'urgent',
  suspended: 'urgent',
  banned: 'urgent',
  cancelled: 'urgent',
  failed: 'urgent',
  refunded: 'urgent',

  placed: 'info',
  accepted: 'info',
  dismissed: 'neutral',
  disabled: 'neutral',
  expired: 'neutral',
  planned: 'neutral',
  finished: 'neutral',
  offline: 'neutral'
};

export function toneFor(status: string): Tone {
  return STATUS_TONE[status] ?? 'neutral';
}