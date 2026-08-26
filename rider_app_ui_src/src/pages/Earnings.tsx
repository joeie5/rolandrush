import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { BikeIcon, ClockIcon, PackageIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { useRider } from '../contexts/RiderContext';
import { todayDeliveries as deliveryRows, weekBars } from '../data/earnings';
import { naira, nairaCompact } from '../utils/format';

type Range = 'Today' | 'Week' | 'Month';
const ranges: Range[] = ['Today', 'Week', 'Month'];

export function Earnings() {
  const navigate = useNavigate();
  const { todayEarnings, todayDeliveries } = useRider();
  const [range, setRange] = useState<Range>('Today');

  const totals: Record<Range, {amount: number;trips: number;km: number;hours: string;}> = {
    Today: { amount: todayEarnings, trips: todayDeliveries, km: 24, hours: '6h 12m' },
    Week: { amount: 97400, trips: 38, km: 186, hours: '41h 30m' },
    Month: { amount: 384200, trips: 152, km: 742, hours: '168h' }
  };
  const total = totals[range];
  const maxBar = Math.max(...weekBars.map((bar) => bar.amount));

  return (
    <Screen nav title="Earnings" subtitle="Osogbo zone">
      <div className="space-y-4">
        <div className="flex gap-2">
          {ranges.map((item) => {
            const active = range === item;
            return (
              <button
                key={item}
                type="button"
                onClick={() => setRange(item)}
                aria-pressed={active}
                className={`h-14 flex-1 rounded-btn text-[16px] font-extrabold transition-colors duration-150 ease-swift ${
                active ? 'bg-ink text-white' : 'bg-surface text-ink-muted active:bg-line'}`
                }>
                
                {item}
              </button>);

          })}
        </div>

        <section className="rounded-card bg-surface p-5">
          <h2 className="text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            {range === 'Today' ? 'Earned today' : `Earned this ${range.toLowerCase()}`}
          </h2>
          <p className="mt-1 text-hero font-extrabold text-online">{naira(total.amount)}</p>

          {range !== 'Today' &&
          <div className="mt-6 flex h-32 items-end gap-2">
              {weekBars.map((bar, index) =>
            <div key={index} className="flex flex-1 flex-col items-center gap-2">
                  <span
                className={`w-full rounded-t-md ${index === weekBars.length - 1 ? 'bg-coral' : 'bg-online'}`}
                style={{ height: `${Math.round(bar.amount / maxBar * 100)}%` }} />
              
                  <span className="text-[13px] font-bold text-ink-faint">{bar.label}</span>
                </div>
            )}
            </div>
          }

          <div className="mt-5 flex divide-x divide-line border-t border-line pt-4">
            <Metric Icon={PackageIcon} label="Trips" value={String(total.trips)} />
            <Metric Icon={BikeIcon} label="Distance" value={`${total.km} km`} />
            <Metric Icon={ClockIcon} label="Online" value={total.hours} />
          </div>
        </section>

        <Button size="lg" onClick={() => navigate('/withdraw')}>
          Withdraw to bank
        </Button>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Recent deliveries
          </h2>
          <ul className="space-y-2.5">
            {deliveryRows.map((row) =>
            <li
              key={row.id}
              className="flex items-center gap-3 rounded-card bg-surface px-4 py-3.5">
              
                <div className="min-w-0 flex-1">
                  <p className="truncate text-[17px] font-bold text-ink">{row.label}</p>
                  <p className="text-micro font-semibold text-ink-muted">
                    {row.area} · {row.time}
                  </p>
                </div>
                <p className="shrink-0 text-[20px] font-extrabold tracking-[-0.02em] text-online">
                  +{naira(row.amount)}
                </p>
              </li>
            )}
          </ul>
          <p className="mt-3 text-center text-micro font-semibold text-ink-faint">
            Weekly average {nairaCompact(13900)} per day
          </p>
        </section>
      </div>
    </Screen>);

}

function Metric({
  Icon,
  label,
  value




}: {Icon: React.ComponentType<{className?: string;strokeWidth?: number;}>;label: string;value: string;}) {
  return (
    <div className="flex-1 px-2 first:pl-0 last:pr-0">
      <p className="flex items-center gap-1.5 text-[21px] font-extrabold tracking-[-0.02em] text-ink">
        <Icon className="h-5 w-5 text-ink-muted" strokeWidth={2.5} />
        {value}
      </p>
      <p className="text-[13px] font-bold uppercase tracking-wide text-ink-faint">{label}</p>
    </div>);

}