import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronLeftIcon } from 'lucide-react';
import { BottomNav } from './BottomNav';

interface ScreenProps {
  title?: string;
  subtitle?: string;
  onBack?: () => void;
  backTo?: string;
  action?: React.ReactNode;
  nav?: boolean;
  children: React.ReactNode;
  padded?: boolean;
}

export function Screen({
  title,
  subtitle,
  onBack,
  backTo,
  action,
  nav = false,
  padded = true,
  children
}: ScreenProps) {
  const navigate = useNavigate();
  const showBack = Boolean(onBack || backTo);

  return (
    <div className="flex min-h-0 flex-1 flex-col bg-canvas">
      {(title || showBack || action) &&
      <div className="flex shrink-0 items-center gap-3 px-5 pb-3 pt-2">
          {showBack &&
        <button
          type="button"
          onClick={() => onBack ? onBack() : navigate(backTo as string)}
          aria-label="Go back"
          className="-ml-2 flex h-12 w-12 shrink-0 items-center justify-center rounded-full text-ink transition-colors duration-150 ease-swift active:bg-line">
          
              <ChevronLeftIcon className="h-7 w-7" strokeWidth={2.6} />
            </button>
        }
          <div className="min-w-0 flex-1">
            {title &&
          <h1 className="truncate text-[26px] font-extrabold tracking-[-0.03em] text-ink">
                {title}
              </h1>
          }
            {subtitle && <p className="text-micro font-medium text-ink-muted">{subtitle}</p>}
          </div>
          {action}
        </div>
      }
      <main className={`no-scrollbar min-h-0 flex-1 overflow-y-auto ${padded ? 'px-5 pb-8' : ''}`}>
        {children}
      </main>
      {nav && <BottomNav />}
    </div>);

}