import React from 'react';
import { CheckIcon, ClockIcon, FileTextIcon, UploadIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { documents } from '../data/rider';

const statusStyles = {
  verified: { chip: 'bg-online-soft text-online', label: 'Verified', Icon: CheckIcon },
  pending: { chip: 'bg-alert-soft text-alert', label: 'In review', Icon: ClockIcon },
  missing: { chip: 'bg-coral-soft text-coral', label: 'Required', Icon: UploadIcon }
} as const;

export function Documents() {
  return (
    <Screen title="Documents" subtitle="Keep these valid to stay online" backTo="/profile">
      <ul className="space-y-2.5">
        {documents.map((doc) => {
          const meta = statusStyles[doc.status];
          return (
            <li key={doc.id} className="rounded-card bg-surface p-4">
              <div className="flex items-center gap-3">
                <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-btn bg-canvas text-ink">
                  <FileTextIcon className="h-6 w-6" strokeWidth={2.4} />
                </span>
                <div className="min-w-0 flex-1">
                  <p className="text-[18px] font-bold text-ink">{doc.label}</p>
                  <p className="text-micro font-semibold text-ink-muted">{doc.detail}</p>
                </div>
                <span
                  className={`flex shrink-0 items-center gap-1 rounded-md px-2.5 py-1.5 text-[13px] font-extrabold uppercase ${meta.chip}`}>
                  
                  <meta.Icon className="h-4 w-4" strokeWidth={3} />
                  {meta.label}
                </span>
              </div>
              {doc.status !== 'verified' &&
              <button
                type="button"
                className="mt-3 h-14 w-full rounded-btn border-2 border-line bg-surface text-[17px] font-extrabold text-ink transition-colors duration-150 ease-swift active:bg-canvas">
                
                  Re-upload document
                </button>
              }
            </li>);

        })}
      </ul>
    </Screen>);

}