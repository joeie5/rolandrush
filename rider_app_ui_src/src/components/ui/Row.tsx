import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRightIcon } from 'lucide-react';

interface RowProps {
  label: string;
  value?: string;
  to?: string;
  Icon?: React.ComponentType<{className?: string;strokeWidth?: number;}>;
  tone?: 'default' | 'coral' | 'online' | 'alert';
  right?: React.ReactNode;
  onClick?: () => void;
}

const tones = {
  default: 'bg-canvas text-ink',
  coral: 'bg-coral-soft text-coral',
  online: 'bg-online-soft text-online',
  alert: 'bg-alert-soft text-alert'
};

export function Row({ label, value, to, Icon, tone = 'default', right, onClick }: RowProps) {
  const inner =
  <>
      {Icon &&
    <span
      className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-btn ${tones[tone]}`}>
      
          <Icon className="h-6 w-6" strokeWidth={2.3} />
        </span>
    }
      <span className="min-w-0 flex-1 text-left">
        <span className="block truncate text-[17px] font-bold text-ink">{label}</span>
        {value && <span className="block truncate text-micro font-medium text-ink-muted">{value}</span>}
      </span>
      {right ?? <ChevronRightIcon className="h-6 w-6 shrink-0 text-ink-faint" strokeWidth={2.4} />}
    </>;


  const classes =
  'flex w-full items-center gap-4 rounded-card bg-surface px-4 py-4 text-left transition-colors duration-150 ease-swift active:bg-canvas';

  if (to) {
    return (
      <Link to={to} className={classes}>
        {inner}
      </Link>);

  }
  return (
    <button type="button" onClick={onClick} className={classes}>
      {inner}
    </button>);

}