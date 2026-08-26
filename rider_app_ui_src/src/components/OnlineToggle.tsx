import React from 'react';
import { motion } from 'framer-motion';
import { PowerIcon } from 'lucide-react';
import { useRider } from '../contexts/RiderContext';

export function OnlineToggle() {
  const { isOnline, toggleOnline } = useRider();

  return (
    <button
      type="button"
      role="switch"
      aria-checked={isOnline}
      onClick={toggleOnline}
      className={`flex w-full items-center gap-4 rounded-card px-5 py-5 text-left shadow-float transition-[background-color,transform] duration-200 ease-swift active:scale-[0.99] ${
      isOnline ? 'bg-online text-white' : 'border-2 border-line bg-surface text-ink'}`
      }>
      
      <span
        className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-full ${
        isOnline ? 'bg-white/20 text-white' : 'bg-canvas text-ink-faint'}`
        }>
        
        <PowerIcon className="h-7 w-7" strokeWidth={3} />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block text-[27px] font-extrabold leading-tight tracking-[-0.03em]">
          {isOnline ? "You're online" : "You're offline"}
        </span>
        <span
          className={`block text-[15px] font-semibold ${isOnline ? 'text-white/85' : 'text-ink-muted'}`}>
          
          {isOnline ? 'Tap to stop receiving jobs' : 'Tap to start receiving jobs'}
        </span>
      </span>
      <span
        className={`flex h-[52px] w-[88px] shrink-0 items-center rounded-full p-1.5 ${
        isOnline ? 'justify-end bg-white/25' : 'justify-start bg-line'}`
        }>
        
        <motion.span
          layout
          transition={{ type: 'spring', stiffness: 620, damping: 34 }}
          className={`block h-10 w-10 rounded-full ${isOnline ? 'bg-white' : 'bg-surface shadow-float'}`} />
        
      </span>
    </button>);

}