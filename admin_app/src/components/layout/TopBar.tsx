import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { CommandIcon, FlagIcon, LogOutIcon, SearchIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { initials } from '../../utils/format';
import { IconButton } from '../ui/Button';

export function TopBar() {
  const { currentAdmin, counts, signOut } = useAdmin();
  const navigate = useNavigate();
  const [query, setQuery] = React.useState('');

  return (
    <header className="flex h-14 shrink-0 items-center gap-4 border-b border-line bg-surface px-5">
      <form
        className="relative w-[380px]"
        onSubmit={(event) => {
          event.preventDefault();
          navigate(`/orders?q=${encodeURIComponent(query)}`);
        }}>
        
        <SearchIcon className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-faint" />
        <input
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search orders, vendors, riders, customers…"
          aria-label="Global search"
          className="h-9 w-full rounded-md border border-line-strong bg-canvas pl-8 pr-14 text-base text-ink placeholder:text-ink-faint transition-colors duration-150 ease-exp hover:border-ink-faint focus:border-ink focus:bg-surface focus:outline-none" />
        
        <span className="pointer-events-none absolute right-2 top-1/2 flex -translate-y-1/2 items-center gap-0.5 rounded border border-line-strong bg-surface px-1 py-0.5 text-2xs text-ink-faint">
          <CommandIcon className="h-2.5 w-2.5" />K
        </span>
      </form>

      <div className="ml-auto flex items-center gap-3">
        {counts.urgent > 0 ?
        <Link
          to="/"
          className="inline-flex items-center gap-1.5 rounded-md border border-coral-border bg-coral-soft px-2 py-1 text-sm font-medium text-coral-ink transition-colors duration-150 ease-exp hover:border-coral">
          
            <FlagIcon className="h-3.5 w-3.5" />
            {counts.urgent} flagged
          </Link> :
        null}
        <div className="h-6 w-px bg-line" />
        <div className="flex items-center gap-2">
          <span className="flex h-7 w-7 items-center justify-center rounded-md bg-ink text-2xs font-semibold text-white">
            {initials(currentAdmin.name)}
          </span>
          <div className="leading-tight">
            <p className="text-sm font-medium text-ink">{currentAdmin.name}</p>
            <p className="text-2xs text-ink-faint">{currentAdmin.role}</p>
          </div>
        </div>
        <IconButton icon={LogOutIcon} label="Sign out" onClick={signOut} />
      </div>
    </header>);

}