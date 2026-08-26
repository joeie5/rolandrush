import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { CheckIcon, ClockIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';

const checks = [
{ label: 'Personal details', done: true },
{ label: "Driver's licence", done: true },
{ label: 'NIN verification', done: true },
{ label: 'Payout account', done: true }];


export function VerificationStatus() {
  const navigate = useNavigate();
  const [approved, setApproved] = useState(false);

  return (
    <Screen>
      <div className="flex min-h-full flex-col pt-8">
        <motion.div
          key={approved ? 'approved' : 'pending'}
          initial={{ scale: 0.96, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.25, ease: [0.23, 1, 0.32, 1] }}
          className={`flex flex-col items-center rounded-card px-6 py-9 text-center ${
          approved ? 'bg-online text-white' : 'bg-alert-soft'}`
          }>
          
          <span
            className={`flex h-20 w-20 items-center justify-center rounded-full ${
            approved ? 'bg-white/20' : 'bg-alert text-white'}`
            }>
            
            {approved ?
            <CheckIcon className="h-11 w-11" strokeWidth={3.2} /> :

            <ClockIcon className="h-10 w-10" strokeWidth={2.6} />
            }
          </span>
          <h1
            className={`mt-5 text-[30px] font-extrabold leading-tight tracking-[-0.03em] ${
            approved ? 'text-white' : 'text-ink'}`
            }>
            
            {approved ? "You're approved!" : 'Under review'}
          </h1>
          <p
            className={`mt-2 text-[16px] font-semibold ${approved ? 'text-white/85' : 'text-ink-muted'}`}>
            
            {approved ?
            'Go online and start accepting jobs in Osogbo.' :
            'We usually approve riders within 24 hours. We’ll text you.'}
          </p>
        </motion.div>

        <ul className="mt-6 space-y-2.5">
          {checks.map((check) =>
          <li
            key={check.label}
            className="flex items-center gap-3 rounded-card bg-surface px-4 py-3.5">
            
              <span className="flex h-9 w-9 items-center justify-center rounded-full bg-online-soft text-online">
                <CheckIcon className="h-5 w-5" strokeWidth={3.2} />
              </span>
              <span className="flex-1 text-[17px] font-bold text-ink">{check.label}</span>
              <span className="text-[15px] font-extrabold text-online">Done</span>
            </li>
          )}
        </ul>

        <div className="mt-auto space-y-2.5 pt-8">
          {approved ?
          <Button size="xl" variant="success" onClick={() => navigate('/home')}>
              Start riding
            </Button> :

          <>
              <Button size="xl" onClick={() => setApproved(true)}>
                Refresh status
              </Button>
              <Button size="md" variant="ghost" onClick={() => navigate('/profile/support')}>
                Contact support
              </Button>
            </>
          }
        </div>
      </div>
    </Screen>);

}