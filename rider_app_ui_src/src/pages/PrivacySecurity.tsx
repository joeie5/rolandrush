import React from 'react';
import { FingerprintIcon, KeyRoundIcon, MapPinIcon, Trash2Icon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Row } from '../components/ui/Row';
import { SwitchRow } from '../components/ui/SwitchRow';

export function PrivacySecurity() {
  return (
    <Screen title="Privacy & security" backTo="/profile">
      <div className="space-y-6">
        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Sign in
          </h2>
          <div className="space-y-2.5">
            <Row label="Change PIN" value="Last updated Jun 2026" Icon={KeyRoundIcon} />
            <SwitchRow label="Fingerprint unlock" description="Open the app without a PIN" />
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Location
          </h2>
          <div className="space-y-2.5">
            <SwitchRow
              label="Share location while online"
              description="Required to receive jobs" />
            
            <SwitchRow
              label="Share location while offline"
              description="Off by default"
              defaultOn={false} />
            
            <Row label="Trip location history" value="Kept for 90 days" Icon={MapPinIcon} />
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Your data
          </h2>
          <div className="space-y-2.5">
            <Row label="Download my data" Icon={FingerprintIcon} />
            <Row label="Delete account" Icon={Trash2Icon} tone="coral" />
          </div>
        </section>
      </div>
    </Screen>);

}