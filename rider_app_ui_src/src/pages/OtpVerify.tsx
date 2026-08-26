import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { Keypad } from '../components/Keypad';
import { CodeBoxes } from '../components/CodeBoxes';

export function OtpVerify() {
  const navigate = useNavigate();
  const [code, setCode] = useState('');

  return (
    <Screen backTo="/auth/phone">
      <div className="flex min-h-full flex-col pt-2">
        <h1 className="text-[32px] font-extrabold leading-[1.1] tracking-[-0.035em] text-ink">
          Enter your code
        </h1>
        <p className="mt-2 text-[16px] font-semibold text-ink-muted">
          Sent to <span className="font-bold text-ink">+234 803 442 1170</span>
        </p>

        <div className="mt-8">
          <CodeBoxes value={code} />
        </div>

        <button
          type="button"
          className="mx-auto mt-5 h-12 px-4 text-[16px] font-bold text-coral transition-colors duration-150 ease-swift active:text-coral-hover">
          
          Resend code in 0:24
        </button>

        <div className="mt-auto pt-6">
          <Keypad
            onPress={(digit) => setCode((prev) => prev.length < 4 ? prev + digit : prev)}
            onDelete={() => setCode((prev) => prev.slice(0, -1))} />
          
          <Button
            className="mt-4"
            size="xl"
            disabled={code.length < 4}
            onClick={() => navigate('/auth/signup')}>
            
            Verify
          </Button>
        </div>
      </div>
    </Screen>);

}