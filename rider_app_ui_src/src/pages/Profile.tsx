import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  BellIcon,
  BikeIcon,
  BuildingIcon,
  FileTextIcon,
  LifeBuoyIcon,
  LogOutIcon,
  ShieldIcon,
  StarIcon } from
'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Row } from '../components/ui/Row';
import { Button } from '../components/ui/Button';
import { rider } from '../data/rider';
import { useRider } from '../contexts/RiderContext';

export function Profile() {
  const navigate = useNavigate();
  const { isOnline } = useRider();

  return (
    <Screen nav title="Account">
      <div className="space-y-4">
        <section className="flex items-center gap-4 rounded-card bg-surface p-5">
          <span className="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-coral text-[24px] font-extrabold text-white">
            {rider.name.
            split(' ').
            map((part) => part[0]).
            join('')}
          </span>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[22px] font-extrabold tracking-[-0.02em] text-ink">
              {rider.name}
            </p>
            <p className="text-[15px] font-semibold text-ink-muted">{rider.riderId}</p>
          </div>
          <span
            className={`rounded-md px-2.5 py-1 text-[13px] font-extrabold uppercase ${
            isOnline ? 'bg-online-soft text-online' : 'bg-canvas text-ink-faint'}`
            }>
            
            {isOnline ? 'Online' : 'Offline'}
          </span>
        </section>

        <section className="flex divide-x divide-line rounded-card bg-surface px-2 py-4">
          <Stat label="Rating" value={rider.rating.toFixed(1)} star />
          <Stat label="Deliveries" value={rider.totalDeliveries.toLocaleString()} />
          <Stat label="Since" value={rider.joined.split(' ')[1]} />
        </section>

        <div className="space-y-2.5">
          <Row label="Vehicle details" value={rider.vehicle.plate} Icon={BikeIcon} to="/profile/vehicle" />
          <Row
            label="Documents"
            value="1 pending review"
            Icon={FileTextIcon}
            tone="alert"
            to="/profile/documents" />
          
          <Row
            label="Bank account"
            value={`${rider.bank.bankName} · ${rider.bank.masked}`}
            Icon={BuildingIcon}
            to="/profile/bank" />
          
          <Row label="Notifications" Icon={BellIcon} to="/profile/notifications" />
          <Row label="Help & support" Icon={LifeBuoyIcon} to="/profile/support" />
          <Row label="Privacy & security" Icon={ShieldIcon} to="/profile/privacy" />
        </div>

        <Button variant="secondary" size="lg" onClick={() => navigate('/')}>
          <LogOutIcon className="h-6 w-6" strokeWidth={2.5} />
          Log out
        </Button>
      </div>
    </Screen>);

}

function Stat({ label, value, star }: {label: string;value: string;star?: boolean;}) {
  return (
    <div className="flex-1 px-3 text-center">
      <p className="flex items-center justify-center gap-1 text-[24px] font-extrabold tracking-[-0.03em] text-ink">
        {star && <StarIcon className="h-5 w-5 fill-alert text-alert" strokeWidth={2.5} />}
        {value}
      </p>
      <p className="text-[13px] font-bold uppercase tracking-wide text-ink-faint">{label}</p>
    </div>);

}