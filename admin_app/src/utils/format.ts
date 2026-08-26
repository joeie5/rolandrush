import { format, formatDistanceToNowStrict, parseISO } from 'date-fns';

export function naira(amount: number, opts?: {compact?: boolean;}): string {
  if (opts?.compact && Math.abs(amount) >= 1_000_000) {
    return `₦${(amount / 1_000_000).toFixed(1)}M`;
  }
  if (opts?.compact && Math.abs(amount) >= 10_000) {
    return `₦${Math.round(amount / 1000)}k`;
  }
  return `₦${amount.toLocaleString('en-NG')}`;
}

export function dateTime(iso: string): string {
  return format(parseISO(iso), "d MMM yyyy 'at' h:mmaaa");
}

export function shortDateTime(iso: string): string {
  return format(parseISO(iso), 'd MMM, h:mmaaa');
}

export function clockTime(iso: string): string {
  return format(parseISO(iso), 'h:mmaaa');
}

export function dayMonth(iso: string): string {
  return format(parseISO(iso), 'd MMM yyyy');
}

export function ago(iso: string): string {
  return `${formatDistanceToNowStrict(parseISO(iso))} ago`;
}

export function initials(name: string): string {
  return name.
  replace(/[^a-zA-Z ]/g, '').
  split(' ').
  filter(Boolean).
  slice(0, 2).
  map((part) => part[0]?.toUpperCase() ?? '').
  join('');
}

export function maskAccount(accountNumber: string): string {
  return `${'•'.repeat(Math.max(0, accountNumber.length - 4))}${accountNumber.slice(-4)}`;
}

export function titleCase(value: string): string {
  return value.
  replace(/_/g, ' ').
  replace(/\b\w/g, (char) => char.toUpperCase());
}