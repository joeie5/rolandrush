import React from 'react';
import { SendIcon, UsersIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Checkbox, Select, TextArea, TextInput } from '../../components/ui/Field';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { shortDateTime } from '../../utils/format';

const AUDIENCES: Record<string, number> = {
  'All customers': 18420,
  'Customers in Osogbo Central': 9210,
  'Lapsed customers (30d+)': 3140,
  'All vendors': 190,
  'All riders': 97
};

const SENT = [
{
  id: 'b_3',
  channel: 'Push',
  audience: 'Customers in Ile-Ife',
  body: 'Free delivery in Ile-Ife this weekend with IFEFREE.',
  at: '2026-08-23T10:00:00',
  reach: 4120,
  opened: 0.38
},
{
  id: 'b_2',
  channel: 'SMS',
  audience: 'All riders',
  body: 'Fuel subsidy payout lands tomorrow. Keep your bank details current.',
  at: '2026-08-20T17:30:00',
  reach: 97,
  opened: 1
},
{
  id: 'b_1',
  channel: 'Push',
  audience: 'Lapsed customers (30d+)',
  body: 'We miss you — ₦1,000 off your next order.',
  at: '2026-08-17T12:00:00',
  reach: 3020,
  opened: 0.21
}];


export function Broadcasts() {
  const { logAction } = useAdmin();
  const decision = useDecision();
  const [channel, setChannel] = React.useState('push');
  const [audience, setAudience] = React.useState('All customers');
  const [title, setTitle] = React.useState('');
  const [body, setBody] = React.useState('');
  const [confirmCost, setConfirmCost] = React.useState(false);

  const reach = AUDIENCES[audience];
  const cost = channel === 'sms' ? reach * 4 : 0;
  const invalid =
  body.trim().length < 10 ||
  channel === 'push' && title.trim().length < 3 ||
  channel === 'sms' && !confirmCost;

  return (
    <>
      <PageHeader
        title="Broadcasts"
        phaseTwo
        subtitle="Push and SMS to a whole audience at once. There is no undo, so the recipient count and cost are shown before you send." />
      

      <div className="grid grid-cols-12 gap-4">
        <Panel className="col-span-12 xl:col-span-7">
          <PanelHeader title="Compose" />
          <form
            className="space-y-4 px-4 py-4"
            onSubmit={(event) => {
              event.preventDefault();
              decision.ask({
                title: `Send to ${reach.toLocaleString('en-NG')} recipients?`,
                consequence:
                'This goes out immediately to everyone in the audience and cannot be recalled.',
                facts: [
                { label: 'Channel', value: channel === 'sms' ? 'SMS' : 'Push notification' },
                { label: 'Audience', value: audience },
                { label: 'Recipients', value: reach.toLocaleString('en-NG') },
                ...(cost ? [{ label: 'Estimated cost', value: `₦${cost.toLocaleString('en-NG')}` }] : [])],

                intent: 'approve',
                reasonRequired: false,
                confirmLabel: 'Send now',
                onConfirm: () => {
                  logAction({
                    area: 'config',
                    sentence: `sent a ${channel === 'sms' ? 'SMS' : 'push'} broadcast to ${audience} (${reach.toLocaleString('en-NG')} recipients)`,
                    outcome: 'info'
                  });
                  setTitle('');
                  setBody('');
                  setConfirmCost(false);
                }
              });
            }}>
            
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="mb-1 block text-sm font-medium text-ink">
                  Channel<span className="ml-1 text-coral">*</span>
                </label>
                <Select
                  label="Channel"
                  value={channel}
                  onChange={setChannel}
                  options={[
                  { value: 'push', label: 'Push notification (free)' },
                  { value: 'sms', label: 'SMS (₦4 per recipient)' }]
                  } />
                
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-ink">
                  Audience<span className="ml-1 text-coral">*</span>
                </label>
                <Select
                  label="Audience"
                  value={audience}
                  onChange={setAudience}
                  options={Object.keys(AUDIENCES).map((key) => ({
                    value: key,
                    label: key
                  }))} />
                
              </div>
            </div>

            {channel === 'push' ?
            <TextInput
              label="Title"
              required
              value={title}
              onChange={setTitle}
              placeholder="Free delivery this weekend" /> :

            null}

            <TextArea
              label="Message"
              required
              rows={4}
              value={body}
              onChange={setBody}
              placeholder="Keep it under 160 characters for SMS."
              hint={`${body.length} characters${channel === 'sms' ? ` · ${Math.max(1, Math.ceil(body.length / 160))} SMS per recipient` : ''}`} />
            

            <div className="flex items-center justify-between gap-4 rounded-lg border border-line bg-canvas px-3 py-2.5">
              <p className="flex items-center gap-2 text-base text-ink">
                <UsersIcon className="h-4 w-4 text-ink-faint" />
                <span className="tabular font-semibold">
                  {reach.toLocaleString('en-NG')}
                </span>
                recipients
              </p>
              {cost ?
              <p className="tabular text-base text-ink">
                  Estimated cost{' '}
                  <span className="font-semibold">₦{cost.toLocaleString('en-NG')}</span>
                </p> :

              <Badge tone="ok">No cost</Badge>
              }
            </div>

            {channel === 'sms' ?
            <Checkbox
              checked={confirmCost}
              onChange={setConfirmCost}
              label={`I accept the ₦${cost.toLocaleString('en-NG')} SMS cost`} /> :

            null}

            <Button
              type="submit"
              variant="primary"
              size="lg"
              icon={SendIcon}
              disabled={invalid}>
              
              Review and send
            </Button>
          </form>
        </Panel>

        <Panel className="col-span-12 xl:col-span-5">
          <PanelHeader title="Recently sent" meta="Last 30 days" />
          <ul className="divide-y divide-line">
            {SENT.map((item) =>
            <li key={item.id} className="px-4 py-3">
                <div className="flex items-center gap-2">
                  <Badge tone={item.channel === 'SMS' ? 'warn' : 'neutral'}>
                    {item.channel}
                  </Badge>
                  <p className="text-sm text-ink-muted">{item.audience}</p>
                  <span className="tabular ml-auto text-xs text-ink-faint">
                    {shortDateTime(item.at)}
                  </span>
                </div>
                <p className="mt-1 text-base text-ink-soft">{item.body}</p>
                <p className="tabular mt-1 text-xs text-ink-faint">
                  {item.reach.toLocaleString('en-NG')} reached ·{' '}
                  {Math.round(item.opened * 100)}% opened
                </p>
              </li>
            )}
          </ul>
        </Panel>
      </div>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}