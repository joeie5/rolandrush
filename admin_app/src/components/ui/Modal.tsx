import React from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { XIcon } from 'lucide-react';
import { IconButton } from './Button';
import { cn } from '../../utils/cn';

export function Modal({
  open,
  onClose,
  title,
  description,
  children,
  footer,
  width = 'max-w-lg',
  accent









}: {open: boolean;onClose: () => void;title: string;description?: React.ReactNode;children?: React.ReactNode;footer?: React.ReactNode;width?: string;accent?: 'coral' | 'ok' | 'neutral';}) {
  React.useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  return (
    <AnimatePresence>
      {open ?
      <div className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto p-6">
          <motion.div
          className="fixed inset-0 bg-ink/25"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.16, ease: [0.23, 1, 0.32, 1] }}
          onClick={onClose} />
        
          <motion.div
          role="dialog"
          aria-modal="true"
          aria-label={title}
          initial={{ opacity: 0, scale: 0.97, y: 8 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.97, y: 8 }}
          transition={{ duration: 0.22, ease: [0.23, 1, 0.32, 1] }}
          className={cn(
            'relative z-10 my-8 w-full overflow-hidden rounded-xl border border-line bg-surface shadow-pop',
            width
          )}>
          
            <header
            className={cn(
              'flex items-start justify-between gap-4 border-b px-4 py-3',
              accent === 'coral' ?
              'border-coral-border bg-coral-soft' :
              accent === 'ok' ?
              'border-ok-border bg-ok-soft' :
              'border-line bg-surface'
            )}>
            
              <div>
                <h2 className="text-md font-semibold text-ink">{title}</h2>
                {description ?
              <p className="mt-0.5 text-sm text-ink-soft">{description}</p> :
              null}
              </div>
              <IconButton icon={XIcon} label="Close" onClick={onClose} />
            </header>
            {children ? <div className="px-4 py-4">{children}</div> : null}
            {footer ?
          <footer className="flex items-center justify-end gap-2 border-t border-line bg-canvas px-4 py-3">
                {footer}
              </footer> :
          null}
          </motion.div>
        </div> :
      null}
    </AnimatePresence>);

}