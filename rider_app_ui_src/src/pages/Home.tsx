import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { BellIcon, ChevronRightIcon, NavigationIcon, StarIcon, ZapIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { OnlineToggle } from '../components/OnlineToggle';
import { Button } from '../components/ui/Button';
import { useRider } from '../contexts/RiderContext';
import { rider } from '../data/rider';
import { naira } from '../utils/format';

export function Home() {
  const navigate = useNavigate();
  const { isOnline, todayEarnings, todayDeliveries, onlineHours, availableJobs, activeJob, balance } =
  useRider();

  return (
    <Screen
      nav
      title={`Hi, ${rider.name.split(' ')[0]}`}
      subtitle={rider.area}
      action={
      <Link
        to="/profile/notifications"
        aria-label="Notifications"
        className="flex h-12 w-12 items-center justify-center rounded-full bg-surface text-ink transition-colors duration-150 ease-swift active:bg-line">
        
          <BellIcon className="h-6 w-6" strokeWidth={2.4} />
        </Link>
      }>
      
      <div className="space-y-4">
        <OnlineToggle />

        {activeJob &&
        <button
          type="button"
          onClick={() => navigate('/delivery/active')}
          className="flex w-full items-center gap-3 rounded-card bg-coral px-4 py-4 text-left text-white shadow-float transition-transform duration-150 ease-swift active:scale-[0.99]">
          
            <NavigationIcon className="h-7 w-7 shrink-0" strokeWidth={2.6} />
            <span className="min-w-0 flex-1">
              <span className="block text-[20px] font-extrabold tracking-[-0.02em]">
                Delivery in progress
              </span>
              <span className="block truncate text-[14px] font-semibold text-white/85">
                {activeJob.restaurant} → {activeJob.dropoffArea}
              </span>
            </span>
            <ChevronRightIcon className="h-7 w-7 shrink-0" strokeWidth={2.8} />
          </button>
        }

        <section className="rounded-card bg-surface p-5">
          <div className="flex items-baseline justify-between">
            <h2 className="text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
              Earned today
            </h2>
            <Link
              to="/earnings"
              className="text-[15px] font-extrabold text-coral">
              
              Details
            </Link>
          </div>
          <p className="mt-1 text-hero font-extrabold text-online">{naira(todayEarnings)}</p>
          <div className="mt-4 flex divide-x divide-line border-t border-line pt-4">
            <Metric label="Deliveries" value={String(todayDeliveries)} />
            <Metric label="Online" value={onlineHours} />
            <Metric
              label="Rating"
              value={rider.rating.toFixed(1)}
              icon={<StarIcon className="h-4 w-4 fill-alert text-alert" strokeWidth={2.5} />} />
            
          </div>
        </section>

        {isOnline ?
        <button
          type="button"
          onClick={() => navigate('/jobs')}
          className="flex w-full items-center gap-3 rounded-card bg-alert px-4 py-5 text-left text-white shadow-float transition-transform duration-150 ease-swift active:scale-[0.99]">
          
            <ZapIcon className="h-8 w-8 shrink-0" strokeWidth={2.8} />
            <span className="min-w-0 flex-1">
              <span className="block text-[24px] font-extrabold leading-tight tracking-[-0.02em]">
                {availableJobs.length} jobs nearby
              </span>
              <span className="block text-[15px] font-semibold text-white/85">
                Best pay right now: {naira(Math.max(...availableJobs.map((j) => j.payout), 0))}
              </span>
            </span>
            <ChevronRightIcon className="h-8 w-8 shrink-0" strokeWidth={2.8} />
          </button> :

        <div className="rounded-card border-2 border-dashed border-line bg-surface px-4 py-6 text-center">
            <p className="text-[19px] font-extrabold text-ink">No jobs while offline</p>
            <p className="mt-1 text-[15px] font-semibold text-ink-muted">
              Flip the switch above to see nearby orders.
            </p>
          </div>
        }

        <Button variant="secondary" size="lg" onClick={() => navigate('/withdraw')}>
          Cash out {naira(balance)}
        </Button>
      </div>
    </Screen>);

}

function Metric({
  label,
  value,
  icon




}: {label: string;value: string;icon?: React.ReactNode;}) {
  return (
    <div className="flex-1 px-2 first:pl-0 last:pr-0">
      <p className="flex items-center gap-1 text-[24px] font-extrabold tracking-[-0.03em] text-ink">
        {icon}
        {value}
      </p>
      <p className="text-[13px] font-bold uppercase tracking-wide text-ink-faint">{label}</p>
    </div>);

}