import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { BuildingIcon, CheckIcon, InfoIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { Keypad } from '../components/Keypad';
import { useRider } from '../contexts/RiderContext';
import { rider } from '../data/rider';
import { withdrawals } from '../data/earnings';
import { naira } from '../utils/format';

const MINIMUM = 2000;

export function Withdraw() {
  const { balance, withdraw } = useRider();
  const [amount, setAmount] = useState('');
  const [done, setDone] = useState(false);

  const value = Number(amount || 0);
  const valid = value >= MINIMUM && value <= balance;

  if (done) {
    return (
      <Screen backTo="/earnings">
        <div className="flex min-h-full flex-col items-center justify-center text-center">
          <motion.span
            initial={{ scale: 0.96, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.24, ease: [0.23, 1, 0.32, 1] }}
            className="flex h-20 w-20 items-center justify-center rounded-full bg-online text-white">
            
            <CheckIcon className="h-11 w-11" strokeWidth={3.2} />
          </motion.span>
          <p className="mt-6 text-[30px] font-extrabold tracking-[-0.03em] text-ink">
            {naira(value)} sent
          </p>
          <p className="mt-2 text-[16px] font-semibold text-ink-muted">
            Arriving in {rider.bank.bankName} {rider.bank.masked} within 10 minutes.
          </p>
          <Button className="mt-8" size="lg" variant="secondary" onClick={() => setDone(false)}>
            Done
          </Button>
        </div>
      </Screen>);

  }

  return (
    <Screen title="Withdraw" backTo="/earnings">
      <div className="flex min-h-full flex-col">
        <section className="rounded-card bg-surface p-5">
          <h2 className="text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Available balance
          </h2>
          <p className="mt-1 text-stat font-extrabold text-ink">{naira(balance)}</p>
        </section>

        <div className="mt-4 rounded-card border-2 border-ink bg-surface px-4 py-4">
          <span className="block text-[13px] font-bold uppercase tracking-wide text-ink-faint">
            Amount to withdraw
          </span>
          <span className="mt-0.5 block text-[38px] font-extrabold tracking-[-0.03em] text-ink">
            {amount ? naira(value) : <span className="text-ink-faint">₦0</span>}
          </span>
        </div>

        <p className="mt-2.5 flex items-center gap-2 text-[15px] font-semibold text-ink-muted">
          <InfoIcon className="h-5 w-5 shrink-0" strokeWidth={2.4} />
          Minimum withdrawal is {naira(MINIMUM)}. No transfer fee.
        </p>

        <div className="mt-4 flex items-center gap-3 rounded-card bg-surface px-4 py-4">
          <span className="flex h-12 w-12 items-center justify-center rounded-btn bg-canvas text-ink">
            <BuildingIcon className="h-6 w-6" strokeWidth={2.4} />
          </span>
          <span className="min-w-0 flex-1">
            <span className="block text-[17px] font-bold text-ink">{rider.bank.bankName}</span>
            <span className="block text-micro font-semibold text-ink-muted">
              {rider.bank.accountName} · {rider.bank.masked}
            </span>
          </span>
          <span className="text-[15px] font-extrabold text-coral">Change</span>
        </div>

        <div className="mt-5">
          <Keypad
            onPress={(digit) => setAmount((prev) => prev.length < 7 ? prev + digit : prev)}
            onDelete={() => setAmount((prev) => prev.slice(0, -1))} />
          
          <Button
            className="mt-4"
            size="xl"
            disabled={!valid}
            onClick={() => {
              withdraw(value);
              setAmount('');
              setDone(true);
            }}>
            
            Withdraw {amount ? naira(value) : ''}
          </Button>
        </div>

        <section className="mt-8">
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Withdrawal history
          </h2>
          <ul className="space-y-2.5">
            {withdrawals.map((row) =>
            <li
              key={row.id}
              className="flex items-center gap-3 rounded-card bg-surface px-4 py-3.5">
              
                <div className="min-w-0 flex-1">
                  <p className="text-[17px] font-bold text-ink">{naira(row.amount)}</p>
                  <p className="text-micro font-semibold text-ink-muted">{row.date}</p>
                </div>
                <span
                className={`rounded-md px-2.5 py-1 text-[13px] font-extrabold uppercase ${
                row.status === 'paid' ? 'bg-online-soft text-online' : 'bg-alert-soft text-alert'}`
                }>
                
                  {row.status}
                </span>
              </li>
            )}
          </ul>
        </section>
      </div>
    </Screen>);

}