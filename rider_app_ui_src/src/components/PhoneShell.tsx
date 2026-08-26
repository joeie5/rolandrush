import React from 'react';
import { Outlet } from 'react-router-dom';
import { BatteryFullIcon, SignalHighIcon, WifiIcon } from 'lucide-react';

export function PhoneShell() {
  return (
    <div className="flex min-h-full w-full items-center justify-center bg-[#f1f1f1] p-0 sm:p-8">
      <div className="relative flex h-[100dvh] w-full max-w-[420px] flex-col overflow-hidden bg-canvas sm:h-[860px] sm:rounded-[40px] sm:shadow-float sm:ring-1 sm:ring-black/5">
        <header className="flex shrink-0 items-center justify-between px-7 pb-1 pt-3 text-[13px] font-bold text-ink">
          <span>9:41</span>
          <div className="flex items-center gap-1.5" aria-hidden="true">
            <SignalHighIcon className="h-4 w-4" strokeWidth={2.5} />
            <WifiIcon className="h-4 w-4" strokeWidth={2.5} />
            <BatteryFullIcon className="h-4 w-4" strokeWidth={2.5} />
          </div>
        </header>
        <div className="relative flex min-h-0 flex-1 flex-col">
          <Outlet />
        </div>
      </div>
    </div>);

}