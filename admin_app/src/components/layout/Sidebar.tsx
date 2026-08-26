import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAdmin } from '../../contexts/AdminContext';
import { NAV_GROUPS } from './navigation';
import { cn } from '../../utils/cn';

export function Sidebar() {
  const { counts } = useAdmin();

  return (
    <nav
      aria-label="Admin sections"
      className="flex h-full w-[232px] shrink-0 flex-col border-r border-line bg-surface">
      
      <div className="flex h-14 items-center gap-2 border-b border-line px-4">
        <span className="flex h-7 w-7 items-center justify-center rounded-md bg-coral text-sm font-bold text-white">
          RR
        </span>
        <div className="leading-tight">
          <p className="text-sm font-semibold text-ink">RolandRush</p>
          <p className="text-2xs uppercase tracking-wider text-ink-faint">
            Admin console
          </p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-2 py-3">
        {NAV_GROUPS.map((group) =>
        <div key={group.label} className="mb-4 last:mb-0">
            <p className="px-2 pb-1.5 text-2xs font-semibold uppercase tracking-wider text-ink-faint">
              {group.label}
            </p>
            <ul className="space-y-0.5">
              {group.items.map((item) => {
              const count = item.countKey ?
              counts[item.countKey] :
              item.staticCount ?? 0;
              return (
                <li key={item.to}>
                    <NavLink
                    to={item.to}
                    end={item.to === '/'}
                    className={({ isActive }) =>
                    cn(
                      'group flex items-center gap-2 rounded-md px-2 py-1.5 text-base transition-colors duration-150 ease-exp',
                      isActive ?
                      'bg-canvas font-medium text-ink' :
                      'text-ink-soft hover:bg-canvas hover:text-ink'
                    )
                    }>
                    
                      {({ isActive }) =>
                    <>
                          <item.icon
                        className={cn(
                          'h-4 w-4 shrink-0',
                          isActive ? 'text-coral' : 'text-ink-faint'
                        )} />
                      
                          <span className="flex-1 truncate">{item.label}</span>
                          {item.phaseTwo ?
                      <span className="rounded border border-line-strong px-1 text-[9px] font-semibold uppercase tracking-wide text-ink-faint">
                              P2
                            </span> :
                      null}
                          {count > 0 ?
                      <span className="tabular inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-md border border-warn-border bg-warn-soft px-1 text-2xs font-semibold text-warn-ink">
                              {count}
                            </span> :
                      null}
                        </>
                    }
                    </NavLink>
                  </li>);

            })}
            </ul>
          </div>
        )}
      </div>

      <div className="border-t border-line px-3 py-2.5">
        <p className="text-2xs text-ink-faint">
          <span className="font-semibold text-ink-muted">P2</span> marks phase-two
          modules, built once the core queues are in daily use.
        </p>
      </div>
    </nav>);

}