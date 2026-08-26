import React from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import {
  AlertTriangleIcon,
  BuildingIcon,
  CheckIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  XIcon } from
'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader, DefinitionList } from '../../components/ui/Panel';
import { Badge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { ago, dateTime, dayMonth, naira } from '../../utils/format';

export function WithdrawalDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { withdrawals, decideWithdrawal } = useAdmin();
  const decision = useDecision();

  const item = withdrawals.find((entry) => entry.id === id);
  const queue = withdrawals.filter((entry) => entry.status === 'pending');
  const position = queue.findIndex((entry) => entry.id === id);

  if (!item) {
    return (
      <Panel padded>
        <p className="text-base text-ink-muted">
          That withdrawal no longer exists.{' '}
          <Link to="/withdrawals" className="text-coral underline">
            Back to the queue
          </Link>
        </p>
      </Panel>);

  }

  const pending = item.status === 'pending';

  const goto = (offset: number) => {
    const next = queue[position + offset];
    if (next) navigate(`/withdrawals/${next.id}`);else
    navigate('/withdrawals');
  };

  const askApprove = () =>
  decision.ask({
    title: `Release ${naira(item.amount)} to ${item.requesterName}?`,
    consequence:
    'Money leaves the RolandRush float immediately and cannot be recalled.',
    facts: [
    { label: 'Reference', value: item.reference },
    { label: 'Bank', value: `${item.bank.bankName} · ${item.bank.accountNumber}` },
    { label: 'Account name', value: item.bank.accountName },
    { label: 'Amount', value: naira(item.amount) }],

    intent: 'approve',
    reasonRequired: item.tier === 'urgent',
    reasonLabel: 'Why you are releasing a flagged payout',
    confirmLabel: 'Approve payout',
    onConfirm: (reason) => {
      decideWithdrawal(item.id, 'approve', reason);
      goto(1);
    }
  });

  const askReject = () =>
  decision.ask({
    title: `Reject ${naira(item.amount)} to ${item.requesterName}?`,
    consequence:
    'The requester is notified with your reason and the funds stay in their balance.',
    facts: [
    { label: 'Reference', value: item.reference },
    { label: 'Routed because', value: item.routingReason }],

    intent: 'reject',
    reasonRequired: true,
    reasonLabel: 'Reason for rejection',
    suggestions: [
    'Bank account name does not match the verified identity.',
    'Balance does not reconcile with completed orders.',
    'Waiting on the outcome of an open dispute.'],

    confirmLabel: 'Reject payout',
    onConfirm: (reason) => {
      decideWithdrawal(item.id, 'reject', reason);
      goto(1);
    }
  });

  return (
    <>
      <PageHeader
        backTo="/withdrawals"
        backLabel="Withdrawal queue"
        title={`${naira(item.amount)} — ${item.requesterName}`}
        subtitle={
        <span className="flex flex-wrap items-center gap-2">
            <TierBadge tier={item.tier} />
            <Badge tone="neutral">{item.reference}</Badge>
            <span>
              Requested {dateTime(item.requestedAt)} · {ago(item.requestedAt)}
            </span>
          </span>
        }
        actions={
        pending && position >= 0 ?
        <div className="flex items-center gap-1.5">
              <span className="tabular mr-1 text-sm text-ink-muted">
                {position + 1} of {queue.length} in queue
              </span>
              <Button
            size="sm"
            icon={ChevronLeftIcon}
            disabled={position <= 0}
            onClick={() => goto(-1)}>
            
                Prev
              </Button>
              <Button
            size="sm"
            iconRight={ChevronRightIcon}
            disabled={position >= queue.length - 1}
            onClick={() => goto(1)}>
            
                Next
              </Button>
            </div> :
        null
        } />
      

      {item.flagReason ?
      <div className="mb-4 flex items-start gap-2.5 rounded-xl border border-coral-border bg-coral-soft px-4 py-3">
          <AlertTriangleIcon className="mt-0.5 h-4 w-4 shrink-0 text-coral" />
          <div>
            <p className="text-base font-semibold text-coral-ink">
              Flagged for immediate attention
            </p>
            <p className="mt-0.5 text-base text-coral-ink/90">{item.flagReason}</p>
          </div>
        </div> :
      null}

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 space-y-4 xl:col-span-8">
          <Panel>
            <PanelHeader
              title="Requester"
              meta={`${item.requesterType === 'vendor' ? 'Vendor' : 'Rider'} · ${item.location}`}
              action={
              <Link
                to={`/${item.requesterType}s/${item.requesterId}`}
                className="text-sm text-coral underline-offset-2 hover:underline">
                
                  Open {item.requesterType} record
                </Link>
              } />
            
            <div className="px-4 py-4">
              <DefinitionList
                columns={3}
                items={[
                { label: 'Account age', value: `${item.history.accountAgeDays} days` },
                {
                  label: 'Completed payouts',
                  value: `${item.history.completedPayouts}`
                },
                {
                  label: 'Total paid out',
                  value: naira(item.history.totalPaidOut)
                },
                {
                  label: 'Average payout',
                  value: naira(item.history.averagePayout)
                },
                {
                  label: 'Last payout',
                  value: item.history.lastPayoutAt ?
                  dayMonth(item.history.lastPayoutAt) :
                  '—'
                },
                {
                  label: 'This request vs average',
                  value:
                  <span
                    className={
                    item.amount > item.history.averagePayout * 2 ?
                    'font-medium text-coral-ink' :
                    'text-ink'
                    }>
                    
                        {item.history.averagePayout ?
                    `${(item.amount / item.history.averagePayout).toFixed(1)}×` :
                    'First payout'}
                      </span>

                },
                {
                  label: 'Open disputes',
                  value:
                  <span
                    className={
                    item.history.openDisputes ?
                    'font-medium text-coral-ink' :
                    'text-ink'
                    }>
                    
                        {item.history.openDisputes}
                      </span>

                },
                {
                  label: 'Previously rejected',
                  value: `${item.history.rejectedBefore}`
                },
                {
                  label: 'Available balance',
                  value: naira(item.availableBalance)
                }]
                } />
              
            </div>
          </Panel>

          <Panel>
            <PanelHeader
              title="Destination account"
              meta="Confirm the name matches the verified identity before releasing." />
            
            <div className="px-4 py-4">
              <DefinitionList
                columns={2}
                items={[
                { label: 'Bank', value: item.bank.bankName },
                {
                  label: 'Account number',
                  value: <span className="tabular">{item.bank.accountNumber}</span>
                },
                { label: 'Account name', value: item.bank.accountName },
                {
                  label: 'Times used',
                  value:
                  item.bank.timesUsed === 0 ?
                  <span className="font-medium text-warn-ink">
                          Never used before
                        </span> :

                  `${item.bank.timesUsed} payouts`

                },
                {
                  label: 'Details verified',
                  value: item.bank.verifiedAt ? dateTime(item.bank.verifiedAt) :
                  <span className="font-medium text-coral-ink">Not verified</span>

                },
                { label: 'Routed because', value: item.routingReason }]
                } />
              
            </div>
          </Panel>

          <Panel>
            <PanelHeader
              title="Recent payouts to this account"
              meta="Most recent first" />
            
            <ul className="divide-y divide-line">
              {withdrawals.
              filter(
                (entry) =>
                entry.requesterId === item.requesterId && entry.id !== item.id
              ).
              slice(0, 4).
              map((entry) =>
              <li key={entry.id}>
                    <Link
                  to={`/withdrawals/${entry.id}`}
                  className="flex items-center gap-3 px-4 py-2.5 transition-colors duration-150 ease-exp hover:bg-canvas">
                  
                      <span className="tabular w-24 text-base font-medium text-ink">
                        {naira(entry.amount)}
                      </span>
                      <TierBadge tier={entry.tier} />
                      <span className="flex-1 truncate text-sm text-ink-muted">
                        {entry.decision?.reason ?? entry.routingReason}
                      </span>
                      <span className="text-xs text-ink-faint">
                        {dayMonth(entry.requestedAt)}
                      </span>
                    </Link>
                  </li>
              )}
              {withdrawals.filter(
                (entry) =>
                entry.requesterId === item.requesterId && entry.id !== item.id
              ).length === 0 ?
              <li className="px-4 py-4 text-base text-ink-muted">
                  No earlier payout requests from this account.
                </li> :
              null}
            </ul>
          </Panel>
        </div>

        <aside className="col-span-12 xl:col-span-4">
          <Panel className="sticky top-0">
            <PanelHeader
              title={pending ? 'Your decision' : 'Decision'}
              meta={
              pending ?
              'Both actions ask you to confirm before anything moves.' :
              undefined
              } />
            
            <div className="px-4 py-4">
              <dl className="mb-4 divide-y divide-line rounded-lg border border-line bg-canvas">
                <div className="flex items-baseline justify-between px-3 py-2">
                  <dt className="text-sm text-ink-muted">Payout amount</dt>
                  <dd className="tabular text-lg font-semibold text-ink">
                    {naira(item.amount)}
                  </dd>
                </div>
                <div className="flex items-baseline justify-between px-3 py-2">
                  <dt className="text-sm text-ink-muted">Left in balance after</dt>
                  <dd className="tabular text-base text-ink">
                    {naira(item.availableBalance - item.amount)}
                  </dd>
                </div>
              </dl>

              {pending ?
              <div className="space-y-2">
                  <Button
                  variant="approve"
                  size="lg"
                  icon={CheckIcon}
                  className="w-full"
                  onClick={askApprove}>
                  
                    Approve payout
                  </Button>
                  <Button
                  variant="danger"
                  size="lg"
                  icon={XIcon}
                  className="w-full"
                  onClick={askReject}>
                  
                    Reject with reason
                  </Button>
                  <p className="pt-1 text-xs text-ink-faint">
                    Rejecting requires a written reason. Both outcomes are written to
                    the approval log under your name.
                  </p>
                </div> :

              <div className="rounded-lg border border-line bg-canvas px-3 py-3">
                  <Badge
                  tone={item.status === 'rejected' ? 'urgent' : 'ok'}
                  className="mb-2">
                  
                    {item.status === 'auto_approved' ?
                  'Auto-approved' :
                  item.status}
                  </Badge>
                  <p className="text-base text-ink">
                    {item.decision?.by} · {item.decision ? dateTime(item.decision.at) : ''}
                  </p>
                  {item.decision?.reason ?
                <p className="mt-1 text-base text-ink-muted">
                      “{item.decision.reason}”
                    </p> :

                <p className="mt-1 text-base text-ink-muted">
                      {item.routingReason}
                    </p>
                }
                </div>
              }
            </div>
            <div className="flex items-start gap-2 border-t border-line px-4 py-3">
              <BuildingIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ink-faint" />
              <p className="text-xs text-ink-muted">
                Payouts settle through Paystack Transfers. Settlement usually lands
                within 10 minutes on weekdays.
              </p>
            </div>
          </Panel>
        </aside>
      </div>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}