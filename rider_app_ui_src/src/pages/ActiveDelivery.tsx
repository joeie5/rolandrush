import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  ChevronDownIcon,
  ChevronUpIcon,
  MapPinIcon,
  NavigationIcon,
  PackageCheckIcon,
  PhoneIcon,
  XIcon } from
'lucide-react';
import { DeliveryMap } from '../components/DeliveryMap';
import { StepProgress, stepLabels } from '../components/StepProgress';
import { Button } from '../components/ui/Button';
import { useRider } from '../contexts/RiderContext';
import { naira } from '../utils/format';

const actions = [
{ label: "I've arrived at pickup", variant: 'alert' as const },
{ label: 'Order picked up', variant: 'primary' as const },
{ label: 'Enter delivery code', variant: 'success' as const }];


export function ActiveDelivery() {
  const navigate = useNavigate();
  const { activeJob, step, advanceStep } = useRider();
  const [expanded, setExpanded] = useState(true);

  if (!activeJob) {
    return (
      <div className="flex min-h-0 flex-1 flex-col items-center justify-center gap-5 bg-canvas px-8 text-center">
        <PackageCheckIcon className="h-14 w-14 text-ink-faint" strokeWidth={2.2} />
        <p className="text-[24px] font-extrabold tracking-[-0.02em] text-ink">No active delivery</p>
        <Button size="lg" onClick={() => navigate('/jobs')}>
          Find an order
        </Button>
      </div>);

  }

  const heading = step <= 1 ? 'Pick up from' : 'Deliver to';
  const placeName = step <= 1 ? activeJob.restaurant : activeJob.customerName;
  const placeArea = step <= 1 ? activeJob.restaurantArea : activeJob.dropoffArea;
  const phone = step <= 1 ? activeJob.restaurantPhone : activeJob.customerPhone;
  const action = actions[Math.min(step, 2)];

  return (
    <div className="relative flex min-h-0 flex-1 flex-col bg-canvas">
      <div className="absolute inset-0">
        <DeliveryMap job={activeJob} step={step} />
      </div>

      <div className="pointer-events-none absolute inset-x-0 top-0 z-[1000] p-4">
        <div className="pointer-events-auto flex items-center gap-3 rounded-card bg-surface/95 px-3 py-3 shadow-float backdrop-blur">
          <button
            type="button"
            onClick={() => navigate('/home')}
            aria-label="Back to home"
            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-btn bg-canvas text-ink transition-colors duration-150 ease-swift active:bg-line">
            
            <XIcon className="h-6 w-6" strokeWidth={2.8} />
          </button>
          <div className="min-w-0 flex-1">
            <StepProgress step={step} />
          </div>
        </div>
      </div>

      <motion.section
        layout
        transition={{ type: 'spring', stiffness: 420, damping: 36 }}
        className="relative z-[1000] mt-auto rounded-t-[24px] bg-surface px-5 pb-6 pt-3 shadow-sheet">
        
        <button
          type="button"
          onClick={() => setExpanded((prev) => !prev)}
          aria-expanded={expanded}
          className="flex w-full items-center justify-between gap-3 pb-2">
          
          <span className="text-left">
            <span className="block text-[13px] font-extrabold uppercase tracking-wide text-alert">
              {stepLabels[step]} · {activeJob.distanceKm} km
            </span>
            <span className="block text-[24px] font-extrabold leading-tight tracking-[-0.03em] text-ink">
              {heading} {placeName}
            </span>
          </span>
          <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-canvas text-ink">
            {expanded ?
            <ChevronDownIcon className="h-6 w-6" strokeWidth={2.8} /> :

            <ChevronUpIcon className="h-6 w-6" strokeWidth={2.8} />
            }
          </span>
        </button>

        {expanded &&
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.2, ease: [0.23, 1, 0.32, 1] }}
          className="space-y-3 pb-4">
          
            <p className="flex items-center gap-1.5 text-[16px] font-semibold text-ink-muted">
              <MapPinIcon className="h-5 w-5 shrink-0" strokeWidth={2.5} />
              {placeArea}
            </p>

            <div className="flex items-center justify-between rounded-card bg-canvas px-4 py-3">
              <span className="text-[15px] font-bold uppercase tracking-wide text-ink-muted">
                You earn
              </span>
              <span className="text-[26px] font-extrabold tracking-[-0.03em] text-online">
                {naira(activeJob.payout)}
              </span>
            </div>

            <div className="flex gap-2.5">
              <a
              href={`tel:${phone.replace(/\s/g, '')}`}
              className="flex h-16 flex-1 items-center justify-center gap-2 rounded-btn border-2 border-line bg-surface text-[17px] font-extrabold text-ink transition-colors duration-150 ease-swift active:bg-canvas">
              
                <PhoneIcon className="h-6 w-6" strokeWidth={2.6} />
                Call {step <= 1 ? 'store' : 'customer'}
              </a>
              <button
              type="button"
              className="flex h-16 w-16 shrink-0 items-center justify-center rounded-btn bg-ink text-white transition-transform duration-150 ease-swift active:scale-[0.97]"
              aria-label="Open navigation">
              
                <NavigationIcon className="h-6 w-6" strokeWidth={2.6} />
              </button>
            </div>
          </motion.div>
        }

        <Button
          size="xl"
          variant={action.variant}
          onClick={() => {
            if (step >= 2) {
              navigate('/delivery/confirm');
              return;
            }
            advanceStep();
          }}>
          
          {action.label}
        </Button>
      </motion.section>
    </div>);

}