import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRightIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { Keypad } from '../components/Keypad';

export function PhoneEntry() {
  const navigate = useNavigate();
  const [digits, setDigits] = useState('803442');

  const formatted = digits.replace(/(\d{3})(\d{0,3})(\d{0,4})/, (_m, a, b, c) =>
  [a, b, c].filter(Boolean).join(' ')
  );
  const valid = digits.length === 10;

  return (
    <Screen>
      <div className="flex min-h-full flex-col pt-6">
        <h1 className="text-[34px] font-extrabold leading-[1.1] tracking-[-0.035em] text-ink">
          What's your
          <br />
          phone number?
        </h1>
        <p className="mt-2 text-[16px] font-semibold text-ink-muted">
          We'll text you a code to sign in.
        </p>

        <div className="mt-7 flex items-center gap-3 rounded-card border-2 border-ink bg-surface px-4 py-4">
          <span className="text-[26px] font-extrabold text-ink-muted">+234</span>
          <span className="h-8 w-px bg-line" />
          <span className="flex-1 text-[28px] font-extrabold tracking-[-0.02em] text-ink">
            {formatted || <span className="text-ink-faint">803 000 0000</span>}
          </span>
        </div>

        <div className="mt-auto pt-8">
          <Keypad
            onPress={(digit) => setDigits((prev) => prev.length < 10 ? prev + digit : prev)}
            onDelete={() => setDigits((prev) => prev.slice(0, -1))} />
          
          <Button
            className="mt-4"
            size="xl"
            disabled={!valid}
            onClick={() => navigate('/auth/otp')}>
            
            Continue
            <ArrowRightIcon className="h-6 w-6" strokeWidth={2.8} />
          </Button>
        </div>
      </div>
    </Screen>);

}