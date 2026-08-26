import React from 'react';
import { TIER_META } from '../utils/tiers';
import type { RiskTier } from '../types';

const ORDER: RiskTier[] = ['urgent', 'review', 'auto'];

export function TierLegend({ className }: {className?: string;}) {
  return (
    <ul className={className}>
      {ORDER.map((tier) =>
      <li key={tier} className="flex items-baseline gap-2 py-1">
          <span
          className={`mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full ${TIER_META[tier].dot}`} />
        
          <p className="text-sm text-ink-muted">
            <span className="font-medium text-ink">{TIER_META[tier].label}</span>{' '}
            — {TIER_META[tier].description}
          </p>
        </li>
      )}
    </ul>);

}