import React from 'react';
import { Link } from 'react-router-dom';
import { BotIcon, UserIcon } from 'lucide-react';
import { Badge } from './ui/Badge';
import { dateTime, titleCase } from '../utils/format';
import type { AuditEntry } from '../types';

/**
 * Audit entries read as sentences on purpose. Automatic entries are visually
 * quieter than human ones so a reviewer can see who actually decided something.
 */
export function AuditEntryList({
  entries,
  showArea = false



}: {entries: AuditEntry[];showArea?: boolean;}) {
  return (
    <ol className="divide-y divide-line">
      {entries.map((entry) =>
      <li key={entry.id} className="flex gap-3 px-4 py-3">
          <span
          className={`mt-0.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-md border ${
          entry.automated ?
          'border-line bg-canvas text-ink-faint' :
          'border-line-strong bg-surface text-ink'}`
          }>
          
            {entry.automated ?
          <BotIcon className="h-3.5 w-3.5" /> :

          <UserIcon className="h-3.5 w-3.5" />
          }
          </span>
          <div className="min-w-0 flex-1">
            <p className="text-base text-ink-soft">
              <span className="font-medium text-ink">
                {entry.automated ? 'An automatic rule' : entry.actor}
              </span>{' '}
              {entry.sentence}{' '}
              <span className="text-ink-muted">at {dateTime(entry.at)}</span>
              {entry.target?.href ?
            <>
                  {' · '}
                  <Link
                to={entry.target.href}
                className="text-coral underline-offset-2 hover:underline">
                
                    {entry.target.label}
                  </Link>
                </> :
            null}
            </p>
            {entry.reason ?
          <p className="mt-1 border-l-2 border-line pl-2 text-sm text-ink-muted">
                “{entry.reason}”
              </p> :
          null}
          </div>
          <div className="flex shrink-0 items-start gap-1.5">
            {showArea ?
          <Badge tone="neutral">{titleCase(entry.area)}</Badge> :
          null}
            <Badge tone={entry.outcome}>
              {entry.automated ? 'Automatic' : 'Manual'}
            </Badge>
          </div>
        </li>
      )}
    </ol>);

}