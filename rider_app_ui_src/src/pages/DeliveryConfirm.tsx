import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { Keypad } from '../components/Keypad';
import { CodeBoxes } from '../components/CodeBoxes';
import { useRider } from '../contexts/RiderContext';

export function DeliveryConfirm() {
  const navigate = useNavigate();
  const { activeJob, advanceStep, completeDelivery } = useRider();
  const [code, setCode] = useState('');

  return (
    <Screen backTo="/delivery/active">
      <div className="flex min-h-full flex-col">
        <p className="text-[15px] font-extrabold uppercase tracking-wide text-online">
          Final step
        </p>
        <h1 className="mt-1 text-[32px] font-extrabold leading-[1.1] tracking-[-0.035em] text-ink">
          Ask {activeJob?.customerName ?? 'the customer'} for their 4-digit code
        </h1>

        <div className="mt-8">
          <CodeBoxes value={code} tone="ink" />
        </div>

        <p className="mt-5 text-center text-[16px] font-semibold text-ink-muted">
          Don’t hand over the order until the code matches.
        </p>

        <div className="mt-auto pt-6">
          <Keypad
            onPress={(digit) => setCode((prev) => prev.length < 4 ? prev + digit : prev)}
            onDelete={() => setCode((prev) => prev.slice(0, -1))} />
          
          <Button
            className="mt-4"
            size="xl"
            variant="success"
            disabled={code.length < 4}
            onClick={() => {
              advanceStep();
              completeDelivery();
              navigate('/delivery/success');
            }}>
            
            Confirm delivery
          </Button>
        </div>
      </div>
    </Screen>);

}