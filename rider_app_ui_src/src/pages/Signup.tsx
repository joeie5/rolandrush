import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { BikeIcon, CarIcon, CheckIcon, FootprintsIcon, UploadIcon } from 'lucide-react';
import { Screen } from '../components/ui/Screen';
import { Button } from '../components/ui/Button';

const vehicles = [
{ id: 'bike', label: 'Motorcycle', Icon: BikeIcon },
{ id: 'car', label: 'Car', Icon: CarIcon },
{ id: 'foot', label: 'On foot', Icon: FootprintsIcon }];


const uploads = [
{ id: 'license', label: "Driver's licence", done: true },
{ id: 'nin', label: 'NIN slip', done: true },
{ id: 'reg', label: 'Vehicle registration', done: false }];


export function Signup() {
  const navigate = useNavigate();
  const [vehicle, setVehicle] = useState('bike');

  return (
    <Screen title="Set up your account" subtitle="Step 2 of 2" backTo="/auth/otp">
      <div className="space-y-6 pt-1">
        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Your details
          </h2>
          <div className="space-y-2.5">
            <Field label="Full name" value="Kunle Adeyemi" />
            <Field label="Email" value="kunle.adeyemi@gmail.com" />
            <Field label="City" value="Osogbo, Osun State" />
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Vehicle type
          </h2>
          <div className="grid grid-cols-3 gap-2.5">
            {vehicles.map(({ id, label, Icon }) => {
              const active = vehicle === id;
              return (
                <button
                  key={id}
                  type="button"
                  onClick={() => setVehicle(id)}
                  aria-pressed={active}
                  className={`flex h-[104px] flex-col items-center justify-center gap-2 rounded-card border-2 transition-[border-color,background-color] duration-150 ease-swift ${
                  active ? 'border-coral bg-coral-soft' : 'border-line bg-surface'}`
                  }>
                  
                  <Icon
                    className={`h-8 w-8 ${active ? 'text-coral' : 'text-ink-muted'}`}
                    strokeWidth={2.4} />
                  
                  <span
                    className={`text-[14px] font-bold ${active ? 'text-coral' : 'text-ink-muted'}`}>
                    
                    {label}
                  </span>
                </button>);

            })}
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Documents
          </h2>
          <div className="space-y-2.5">
            {uploads.map(({ id, label, done }) =>
            <div
              key={id}
              className="flex items-center gap-3 rounded-card bg-surface px-4 py-4">
              
                <span
                className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-btn ${
                done ? 'bg-online-soft text-online' : 'bg-canvas text-ink-faint'}`
                }>
                
                  {done ?
                <CheckIcon className="h-6 w-6" strokeWidth={3} /> :

                <UploadIcon className="h-6 w-6" strokeWidth={2.5} />
                }
                </span>
                <span className="flex-1 text-[17px] font-bold text-ink">{label}</span>
                <span
                className={`text-[15px] font-extrabold ${done ? 'text-online' : 'text-coral'}`}>
                
                  {done ? 'Uploaded' : 'Upload'}
                </span>
              </div>
            )}
          </div>
        </section>

        <section>
          <h2 className="mb-2.5 text-[15px] font-extrabold uppercase tracking-wide text-ink-muted">
            Payout account
          </h2>
          <div className="space-y-2.5">
            <Field label="Bank" value="Opay" />
            <Field label="Account number" value="8034421170" />
          </div>
        </section>

        <Button size="xl" onClick={() => navigate('/auth/verification')}>
          Submit for review
        </Button>
      </div>
    </Screen>);

}

function Field({ label, value }: {label: string;value: string;}) {
  return (
    <label className="block rounded-card border-2 border-line bg-surface px-4 py-3">
      <span className="block text-[13px] font-bold uppercase tracking-wide text-ink-faint">
        {label}
      </span>
      <input
        defaultValue={value}
        className="w-full bg-transparent text-[19px] font-bold tracking-[-0.01em] text-ink outline-none" />
      
    </label>);

}