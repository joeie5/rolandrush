import React from 'react';
import { BotIcon, CheckIcon, CircleIcon, LoaderIcon, XIcon } from 'lucide-react';
import type { OrderEvent } from '../../types';
import { clockTime, dayMonth } from '../../utils/format';

const STATE_STYLE: Record<
  OrderEvent['state'],
  {ring: string;icon: React.ComponentType<{className?: string;}>;text: string;}> =
{
  done: { ring: 'border-ok bg-ok-soft text-ok', icon: CheckIcon, text: 'text-ink' },
  active: {
    ring: 'border-warn bg-warn-soft text-warn',
    icon: LoaderIcon,
    text: 'text-ink'
  },
  failed: {
    ring: 'border-coral bg-coral-soft text-coral',
    icon: XIcon,
    text: 'text-coral-ink'
  },
  pending: {
    ring: 'border-line-strong bg-surface text-ink-faint',
    icon: CircleIcon,
    text: 'text-ink-faint'
  }
};

export function OrderTimeline({ events }: {events: OrderEvent[];}) {
  return (
    <ol className="relative px-4 py-4">
      <span
        aria-hidden
        className="absolute left-[26px] top-6 bottom-6 w-px bg-line" />
      
      {events.map((event) => {
        const style = STATE_STYLE[event.state];
        const Icon = style.icon;
        return (
          <li key={event.id} className="relative flex gap-3 pb-4 last:pb-0">
            <span
              className={`relative z-10 mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border ${style.ring}`}>
              
              <Icon className="h-3 w-3" />
            </span>
            <div className="min-w-0 flex-1 pb-1">
              <div className="flex flex-wrap items-baseline gap-x-2">
                <p className={`text-base font-medium ${style.text}`}>{event.label}</p>
                {event.at ?
                <span className="tabular text-xs text-ink-faint">
                    {clockTime(event.at)} · {dayMonth(event.at)}
                  </span> :

                <span className="text-xs text-ink-faint">not yet</span>
                }
              </div>
              <p className="mt-0.5 flex items-center gap-1 text-sm text-ink-muted">
                {event.automated ? <BotIcon className="h-3 w-3" /> : null}
                {event.actor}
                {event.detail ? <span className="text-ink-faint">— {event.detail}</span> : null}
              </p>
            </div>
          </li>);

      })}
    </ol>);

}