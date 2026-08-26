import React from 'react';
import {
  AlertTriangleIcon,
  BikeIcon,
  MessageCircleIcon,
  PhoneIcon,
  WalletIcon } from
'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Row } from '../components/ui/Row';

const topics = [
{ label: 'Problem with an order', value: 'Wrong items, waiting too long', Icon: BikeIcon },
{ label: 'Payment or payout issue', value: 'Missing earnings, failed withdrawal', Icon: WalletIcon },
{ label: 'Account & documents', value: 'Verification, licence updates', Icon: MessageCircleIcon }];


export function HelpSupport() {
  return (
    <Screen title="Help & support" backTo="/profile">
      <div className="space-y-4">
        <a
          href="tel:+2348001234567"
          className="flex items-center gap-4 rounded-card bg-coral px-4 py-5 text-white shadow-float transition-transform duration-150 ease-swift active:scale-[0.99]">
          
          <span className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-white/20">
            <AlertTriangleIcon className="h-7 w-7" strokeWidth={2.6} />
          </span>
          <span className="min-w-0 flex-1">
            <span className="block text-[22px] font-extrabold leading-tight tracking-[-0.02em]">
              Emergency help
            </span>
            <span className="block text-[15px] font-semibold text-white/85">
              Accident, theft or unsafe situation
            </span>
          </span>
        </a>

        <a
          href="tel:+2348001234567"
          className="flex h-[72px] items-center justify-center gap-2.5 rounded-btn border-2 border-line bg-surface text-[19px] font-extrabold text-ink transition-colors duration-150 ease-swift active:bg-canvas">
          
          <PhoneIcon className="h-6 w-6" strokeWidth={2.6} />
          Call rider support
        </a>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Common topics
          </h2>
          <div className="space-y-2.5">
            {topics.map((topic) =>
            <Row key={topic.label} label={topic.label} value={topic.value} Icon={topic.Icon} />
            )}
          </div>
        </section>

        <p className="text-center text-micro font-semibold text-ink-faint">
          Support hours: 7am – 11pm daily · Osogbo hub
        </p>
      </div>
    </Screen>);

}