import React from 'react';
import { NavLink } from 'react-router-dom';
import { HomeIcon, LayersIcon, UserIcon, WalletIcon } from 'lucide-react';

const items = [
{ to: '/home', label: 'Home', Icon: HomeIcon },
{ to: '/jobs', label: 'Jobs', Icon: LayersIcon },
{ to: '/earnings', label: 'Earnings', Icon: WalletIcon },
{ to: '/profile', label: 'Account', Icon: UserIcon }];


export function BottomNav() {
  return (
    <nav
      aria-label="Main"
      className="shrink-0 border-t border-line bg-surface px-2 pb-2 pt-1.5">
      
      <ul className="flex items-stretch">
        {items.map(({ to, label, Icon }) =>
        <li key={to} className="flex-1">
            <NavLink
            to={to}
            className={({ isActive }) =>
            `flex h-[62px] flex-col items-center justify-center gap-1 rounded-btn transition-colors duration-150 ease-swift ${
            isActive ? 'text-coral' : 'text-ink-faint active:bg-canvas'}`

            }>
            
              {({ isActive }) =>
            <>
                  <Icon className="h-7 w-7" strokeWidth={isActive ? 2.6 : 2} />
                  <span className="text-[12px] font-bold">{label}</span>
                </>
            }
            </NavLink>
          </li>
        )}
      </ul>
    </nav>);

}