import React from 'react';
import { Screen } from '../components/ui/Screen';
import { SwitchRow } from '../components/ui/SwitchRow';

export function NotificationSettings() {
  return (
    <Screen title="Notifications" backTo="/profile">
      <div className="space-y-6">
        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            While online
          </h2>
          <div className="space-y-2.5">
            <SwitchRow label="New job alerts" description="Loud sound + vibration" />
            <SwitchRow label="High-pay job alerts" description="Jobs over ₦3,000" />
            <SwitchRow label="Read alerts aloud" description="Hands-free while riding" defaultOn={false} />
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Money
          </h2>
          <div className="space-y-2.5">
            <SwitchRow label="Payout confirmations" />
            <SwitchRow label="Weekly earnings summary" />
            <SwitchRow label="Bonus & incentive offers" defaultOn={false} />
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Other
          </h2>
          <div className="space-y-2.5">
            <SwitchRow label="Customer messages" />
            <SwitchRow label="RolandRush news" defaultOn={false} />
          </div>
        </section>
      </div>
    </Screen>);

}