import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { CheckIcon } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { useRider } from '../contexts/RiderContext';
import { naira } from '../utils/format';

const confetti = [
{ x: -110, y: -40, delay: 0, color: '#FF3B4E' },
{ x: -60, y: -90, delay: 0.04, color: '#F79009' },
{ x: 20, y: -110, delay: 0.08, color: '#12B76A' },
{ x: 90, y: -70, delay: 0.06, color: '#FF3B4E' },
{ x: 125, y: -20, delay: 0.02, color: '#F79009' }];


export function DeliverySuccess() {
  const navigate = useNavigate();
  const { lastCompleted, todayEarnings, todayDeliveries } = useRider();
  const amount = lastCompleted?.amount ?? 0;
  const tip = lastCompleted?.tip ?? 0;

  return (
    <div className="flex min-h-0 flex-1 flex-col bg-online px-6 pb-8 pt-10 text-white">
      <div className="relative flex flex-1 flex-col items-center justify-center text-center">
        {confetti.map((piece, index) =>
        <motion.span
          key={index}
          initial={{ opacity: 0, x: 0, y: 0, scale: 0.6 }}
          animate={{ opacity: [0, 1, 0], x: piece.x, y: piece.y, scale: 1 }}
          transition={{ duration: 0.7, delay: piece.delay, ease: [0.23, 1, 0.32, 1] }}
          style={{ backgroundColor: piece.color }}
          className="absolute h-3 w-3 rounded-sm"
          aria-hidden="true" />

        )}

        <motion.span
          initial={{ scale: 0.96, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.24, ease: [0.23, 1, 0.32, 1] }}
          className="flex h-24 w-24 items-center justify-center rounded-full bg-white">
          
          <CheckIcon className="h-14 w-14 text-online" strokeWidth={3.4} />
        </motion.span>

        <p className="mt-6 text-[22px] font-bold tracking-[-0.02em] text-white/85">
          Delivery complete
        </p>
        <motion.p
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.28, delay: 0.08, ease: [0.23, 1, 0.32, 1] }}
          className="mt-1 text-hero font-extrabold">
          
          +{naira(amount + tip)}
        </motion.p>
        <p className="mt-2 text-[16px] font-semibold text-white/85">
          {naira(amount)} delivery {tip > 0 && `· ${naira(tip)} tip`}
        </p>

        <div className="mt-8 flex w-full items-stretch divide-x divide-white/25 rounded-card bg-white/15 px-2 py-4">
          <Stat label="Earned today" value={naira(todayEarnings)} />
          <Stat label="Deliveries" value={String(todayDeliveries)} />
        </div>
      </div>

      <div className="space-y-2.5">
        <Button
          size="xl"
          className="bg-white text-online active:bg-white/90"
          onClick={() => navigate('/jobs')}>
          
          Find next order
        </Button>
        <Button
          size="md"
          className="bg-transparent text-white active:bg-white/10"
          onClick={() => navigate('/home')}>
          
          Back to dashboard
        </Button>
      </div>
    </div>);

}

function Stat({ label, value }: {label: string;value: string;}) {
  return (
    <div className="flex-1 px-3">
      <p className="text-[24px] font-extrabold tracking-[-0.03em]">{value}</p>
      <p className="text-[13px] font-bold uppercase tracking-wide text-white/75">{label}</p>
    </div>);

}