import React, { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { PowerIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { JobCard } from '../components/JobCard';
import { Button } from '../components/ui/Button';
import { useRider } from '../contexts/RiderContext';

type Filter = 'All' | 'Nearby' | 'High-Pay';
const filters: Filter[] = ['All', 'Nearby', 'High-Pay'];

export function Jobs() {
  const navigate = useNavigate();
  const { availableJobs, acceptJob, isOnline, setOnline } = useRider();
  const [filter, setFilter] = useState<Filter>('All');

  const visible = useMemo(() => {
    if (filter === 'Nearby') return availableJobs.filter((j) => j.tags.includes('nearby'));
    if (filter === 'High-Pay') return availableJobs.filter((j) => j.tags.includes('high-pay'));
    return availableJobs;
  }, [availableJobs, filter]);

  return (
    <Screen nav title="Available orders" subtitle={`${visible.length} within 8 km of you`}>
      {!isOnline ?
      <div className="mt-6 rounded-card bg-surface px-5 py-10 text-center">
          <span className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-canvas text-ink-faint">
            <PowerIcon className="h-8 w-8" strokeWidth={2.8} />
          </span>
          <p className="mt-4 text-[24px] font-extrabold tracking-[-0.02em] text-ink">
            You're offline
          </p>
          <p className="mt-1 text-[16px] font-semibold text-ink-muted">
            Go online to see orders around Osogbo.
          </p>
          <Button className="mt-6" variant="success" size="lg" onClick={() => setOnline(true)}>
            Go online
          </Button>
        </div> :

      <>
          <div className="sticky top-0 z-10 -mx-5 mb-3 bg-canvas px-5 pb-3">
            <div className="flex gap-2">
              {filters.map((item) => {
              const active = filter === item;
              return (
                <button
                  key={item}
                  type="button"
                  onClick={() => setFilter(item)}
                  aria-pressed={active}
                  className={`h-14 flex-1 rounded-btn text-[16px] font-extrabold transition-colors duration-150 ease-swift ${
                  active ? 'bg-ink text-white' : 'bg-surface text-ink-muted active:bg-line'}`
                  }>
                  
                    {item}
                  </button>);

            })}
            </div>
          </div>

          <ul className="space-y-3">
            {visible.map((job) =>
          <li key={job.id}>
                <JobCard
              job={job}
              onAccept={(accepted) => {
                acceptJob(accepted);
                navigate('/delivery/active');
              }} />
            
              </li>
          )}
          </ul>

          {visible.length === 0 &&
        <p className="mt-10 text-center text-[18px] font-bold text-ink-muted">
              No orders match this filter yet.
            </p>
        }
        </>
      }
    </Screen>);

}