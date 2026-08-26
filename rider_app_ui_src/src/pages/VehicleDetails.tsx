import React from 'react';
import { BikeIcon, CheckIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';
import { rider } from '../data/rider';

const fields = [
{ label: 'Vehicle type', value: rider.vehicle.type },
{ label: 'Make & model', value: rider.vehicle.make },
{ label: 'Plate number', value: rider.vehicle.plate },
{ label: 'Colour', value: rider.vehicle.color },
{ label: 'Year', value: rider.vehicle.year }];


export function VehicleDetails() {
  return (
    <Screen title="Vehicle" backTo="/profile">
      <div className="space-y-4">
        <section className="flex items-center gap-4 rounded-card bg-surface p-5">
          <span className="flex h-16 w-16 items-center justify-center rounded-btn bg-coral-soft text-coral">
            <BikeIcon className="h-9 w-9" strokeWidth={2.4} />
          </span>
          <div className="min-w-0 flex-1">
            <p className="text-[22px] font-extrabold tracking-[-0.02em] text-ink">
              {rider.vehicle.make}
            </p>
            <p className="flex items-center gap-1 text-[15px] font-bold text-online">
              <CheckIcon className="h-4 w-4" strokeWidth={3.2} />
              Approved for delivery
            </p>
          </div>
        </section>

        <ul className="space-y-2.5">
          {fields.map((field) =>
          <li key={field.label} className="rounded-card bg-surface px-4 py-3.5">
              <p className="text-[13px] font-bold uppercase tracking-wide text-ink-faint">
                {field.label}
              </p>
              <p className="text-[19px] font-bold tracking-[-0.01em] text-ink">{field.value}</p>
            </li>
          )}
        </ul>

        <Button variant="secondary" size="lg">
          Request a change
        </Button>
      </div>
    </Screen>);

}