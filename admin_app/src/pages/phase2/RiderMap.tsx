import React from 'react';
import { Link } from 'react-router-dom';
import { BikeIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { Dot, StatusBadge } from '../../components/ui/Badge';
import { Select } from '../../components/ui/Field';

/** Schematic zone positions — the production map renders live GPS on Leaflet. */
const ZONE_POSITIONS: Record<string, {x: number;y: number;}> = {
  'Osogbo Central': { x: 52, y: 38 },
  'Ile-Ife': { x: 74, y: 62 },
  Ilesa: { x: 80, y: 34 },
  Ede: { x: 30, y: 52 },
  Ikirun: { x: 46, y: 18 },
  Iwo: { x: 18, y: 74 },
  Ikire: { x: 40, y: 80 },
  Gbongan: { x: 58, y: 74 }
};

export function RiderMap() {
  const { riders } = useAdmin();
  const [zone, setZone] = React.useState('all');

  const visible = riders.filter(
    (rider) => zone === 'all' || rider.zone === zone
  );
  const online = visible.filter((rider) => rider.online);

  return (
    <>
      <PageHeader
        title="Rider map"
        phaseTwo
        subtitle={`${online.length} riders online of ${visible.length} in view. Positions update every 15 seconds from the rider app.`}
        actions={
        <Select
          className="w-[190px]"
          label="Zone"
          value={zone}
          onChange={setZone}
          options={[
          { value: 'all', label: 'All zones' },
          ...Object.keys(ZONE_POSITIONS).map((name) => ({
            value: name,
            label: name
          }))]
          } />

        } />
      

      <div className="grid grid-cols-12 gap-4">
        <Panel className="col-span-12 overflow-hidden xl:col-span-8">
          <PanelHeader title="Osun State — live positions" meta="Schematic view" />
          <div className="relative h-[460px] bg-canvas">
            <svg
              viewBox="0 0 100 100"
              preserveAspectRatio="none"
              className="absolute inset-0 h-full w-full"
              aria-hidden>
              
              {Array.from({ length: 9 }).map((_, index) =>
              <line
                key={`v${index}`}
                x1={(index + 1) * 10}
                y1="0"
                x2={(index + 1) * 10}
                y2="100"
                stroke="#EDEDEE"
                strokeWidth="0.2" />

              )}
              {Array.from({ length: 9 }).map((_, index) =>
              <line
                key={`h${index}`}
                x1="0"
                y1={(index + 1) * 10}
                x2="100"
                y2={(index + 1) * 10}
                stroke="#EDEDEE"
                strokeWidth="0.2" />

              )}
            </svg>

            {Object.entries(ZONE_POSITIONS).
            filter(([name]) => zone === 'all' || name === zone).
            map(([name, position]) =>
            <div
              key={name}
              className="absolute -translate-x-1/2 -translate-y-1/2"
              style={{ left: `${position.x}%`, top: `${position.y}%` }}>
              
                  <span className="block h-16 w-16 rounded-full border border-line-strong bg-surface/70" />
                  <span className="absolute left-1/2 top-full -translate-x-1/2 whitespace-nowrap pt-1 text-2xs font-medium uppercase tracking-wider text-ink-faint">
                    {name}
                  </span>
                </div>
            )}

            {visible.map((rider, index) => {
              const base = ZONE_POSITIONS[rider.zone] ?? { x: 50, y: 50 };
              const offsetX = (index % 3 - 1) * 4.5;
              const offsetY = (index % 2 - 0.5) * 6;
              return (
                <Link
                  key={rider.id}
                  to={`/riders/${rider.id}`}
                  title={`${rider.name} · ${rider.online ? 'online' : 'offline'}`}
                  className="absolute -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-surface transition-transform duration-150 ease-exp hover:scale-110"
                  style={{
                    left: `${base.x + offsetX}%`,
                    top: `${base.y + offsetY}%`
                  }}>
                  
                  <span
                    className={`flex h-6 w-6 items-center justify-center rounded-full ${
                    rider.online ? 'bg-coral text-white' : 'bg-line-strong text-ink-muted'}`
                    }>
                    
                    <BikeIcon className="h-3 w-3" />
                  </span>
                </Link>);

            })}
          </div>
          <div className="flex items-center gap-4 border-t border-line px-4 py-2.5">
            <span className="flex items-center gap-1.5 text-sm text-ink-muted">
              <span className="h-2.5 w-2.5 rounded-full bg-coral" /> Online
            </span>
            <span className="flex items-center gap-1.5 text-sm text-ink-muted">
              <span className="h-2.5 w-2.5 rounded-full bg-line-strong" /> Offline
            </span>
          </div>
        </Panel>

        <Panel className="col-span-12 xl:col-span-4">
          <PanelHeader title="Riders in view" meta="Online first" />
          <ul className="divide-y divide-line">
            {[...visible].
            sort((a, b) => Number(b.online) - Number(a.online)).
            map((rider) =>
            <li key={rider.id}>
                  <Link
                to={`/riders/${rider.id}`}
                className="flex items-center gap-3 px-4 py-2.5 transition-colors duration-150 ease-exp hover:bg-canvas">
                
                    <Dot tone={rider.online ? 'ok' : 'neutral'} />
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-base font-medium text-ink">
                        {rider.name}
                      </p>
                      <p className="text-xs text-ink-faint">{rider.zone}</p>
                    </div>
                    <StatusBadge status={rider.status} />
                  </Link>
                </li>
            )}
          </ul>
        </Panel>
      </div>
    </>);

}