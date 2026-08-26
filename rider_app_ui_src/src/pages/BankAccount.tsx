import React from 'react';
import { BuildingIcon, CheckIcon, PlusIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { rider } from '../data/rider';

export function BankAccount() {
  return (
    <Screen title="Bank account" subtitle="Where your payouts land" backTo="/profile">
      <div className="space-y-4">
        <section className="rounded-card border-2 border-online bg-surface p-5">
          <div className="flex items-center gap-3">
            <span className="flex h-12 w-12 items-center justify-center rounded-btn bg-online-soft text-online">
              <BuildingIcon className="h-6 w-6" strokeWidth={2.4} />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-[20px] font-extrabold tracking-[-0.02em] text-ink">
                {rider.bank.bankName}
              </p>
              <p className="text-[15px] font-semibold text-ink-muted">{rider.bank.accountName}</p>
            </div>
            <span className="flex items-center gap-1 rounded-md bg-online-soft px-2.5 py-1.5 text-[13px] font-extrabold uppercase text-online">
              <CheckIcon className="h-4 w-4" strokeWidth={3.2} />
              Default
            </span>
          </div>
          <p className="mt-4 border-t border-line pt-4 text-[13px] font-bold uppercase tracking-wide text-ink-faint">
            Account number
          </p>
          <p className="text-[26px] font-extrabold tracking-[-0.02em] text-ink">
            {rider.bank.accountNumber}
          </p>
        </section>

        <p className="text-[15px] font-semibold text-ink-muted">
          Payouts are sent instantly when you withdraw. Changing your account pauses withdrawals for
          24 hours for security.
        </p>

        <Button variant="secondary" size="lg">
          <PlusIcon className="h-6 w-6" strokeWidth={2.8} />
          Add another account
        </Button>
      </div>
    </Screen>);

}