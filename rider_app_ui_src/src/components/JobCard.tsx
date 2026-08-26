import React from 'react';
import { BikeIcon, MapPinIcon, PackageIcon, TimerIcon, ZapIcon } from 'lucide-react';
import { Button } from './ui/Button';
import { naira } from '../utils/format';
import type { Job } from '../types';

interface JobCardProps {
  job: Job;
  onAccept: (job: Job) => void;
}

export function JobCard({ job, onAccept }: JobCardProps) {
  const highPay = job.tags.includes('high-pay');

  return (
    <article className="rounded-card bg-surface p-4">
      <div className="flex items-start gap-3">
        <div className="min-w-0 flex-1">
          {highPay &&
          <span className="mb-1.5 inline-flex items-center gap-1 rounded-md bg-alert-soft px-2 py-1 text-[12px] font-extrabold uppercase tracking-wide text-alert">
              <ZapIcon className="h-3.5 w-3.5" strokeWidth={3} />
              High pay
            </span>
          }
          <h3 className="text-[19px] font-extrabold leading-tight tracking-[-0.02em] text-ink">
            {job.restaurant}
          </h3>
          <p className="mt-0.5 flex items-center gap-1 text-[14px] font-semibold text-ink-muted">
            <MapPinIcon className="h-4 w-4 shrink-0" strokeWidth={2.5} />
            {job.restaurantArea}
          </p>
        </div>
        <p className="shrink-0 text-[28px] font-extrabold leading-none tracking-[-0.03em] text-ink">
          {naira(job.payout)}
        </p>
      </div>

      <div className="mt-3 flex items-center gap-2 rounded-btn bg-canvas px-3 py-2.5">
        <BikeIcon className="h-5 w-5 shrink-0 text-ink" strokeWidth={2.5} />
        <span className="text-[15px] font-bold text-ink">{job.distanceKm} km</span>
        <span className="h-4 w-px bg-line" />
        <TimerIcon className="h-5 w-5 shrink-0 text-ink-muted" strokeWidth={2.5} />
        <span className="text-[15px] font-bold text-ink-muted">{job.minutes} min</span>
        <span className="h-4 w-px bg-line" />
        <PackageIcon className="h-5 w-5 shrink-0 text-ink-muted" strokeWidth={2.5} />
        <span className="text-[15px] font-bold text-ink-muted">{job.items} items</span>
      </div>

      <p className="mt-3 text-[15px] font-semibold text-ink-muted">
        Drop off · <span className="font-bold text-ink">{job.dropoffArea}</span>
      </p>

      <Button className="mt-3" size="lg" onClick={() => onAccept(job)}>
        Accept · {naira(job.payout)}
      </Button>
    </article>);

}