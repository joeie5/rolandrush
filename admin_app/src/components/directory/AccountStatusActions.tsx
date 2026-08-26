import React from 'react';
import { BanIcon, PauseIcon, PlayIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { Button } from '../ui/Button';
import { DecisionDialog, useDecision } from '../ui/DecisionDialog';
import type { AccountStatus } from '../../types';

const CONSEQUENCE: Record<string, string> = {
  vendor:
  'The store disappears from the apps immediately, open orders are cancelled and refunded, and payouts are held.',
  rider:
  'The rider is logged out, removed from dispatch and cannot accept deliveries.',
  customer:
  'The customer can no longer place orders. Their wallet balance stays intact.'
};

export function AccountStatusActions({
  kind,
  id,
  name,
  status,
  allowBan = false






}: {kind: 'vendor' | 'rider' | 'customer';id: string;name: string;status: AccountStatus;allowBan?: boolean;}) {
  const { setAccountStatus } = useAdmin();
  const decision = useDecision();

  const ask = (next: AccountStatus) =>
  decision.ask({
    title:
    next === 'active' ?
    `Reactivate ${name}?` :
    next === 'banned' ?
    `Permanently ban ${name}?` :
    `Suspend ${name}?`,
    consequence:
    next === 'active' ?
    'The account goes back to normal immediately.' :
    next === 'banned' ?
    'A ban is permanent and cannot be lifted from this console.' :
    CONSEQUENCE[kind],
    facts: [
    { label: 'Account', value: name },
    { label: 'Current status', value: status }],

    intent: next === 'active' ? 'approve' : 'reject',
    reasonRequired: true,
    reasonLabel: next === 'active' ? 'Why it is safe to reactivate' : 'Reason',
    suggestions:
    next === 'active' ?
    ['Documents re-submitted and verified.', 'Issue resolved with the owner.'] :
    [
    'Repeated confirmed complaints from customers.',
    'Identity could not be re-verified.',
    'Suspected refund abuse under investigation.'],

    confirmLabel:
    next === 'active' ?
    'Reactivate account' :
    next === 'banned' ?
    'Ban permanently' :
    'Suspend account',
    onConfirm: (reason) => setAccountStatus(kind, id, next, reason)
  });

  return (
    <>
      {status === 'active' || status === 'pending' ?
      <Button variant="danger" icon={PauseIcon} onClick={() => ask('suspended')}>
          Suspend
        </Button> :

      <Button variant="approve" icon={PlayIcon} onClick={() => ask('active')}>
          Reactivate
        </Button>
      }
      {allowBan && status !== 'banned' ?
      <Button variant="primary" icon={BanIcon} onClick={() => ask('banned')}>
          Ban
        </Button> :
      null}
      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}