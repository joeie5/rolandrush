import React from 'react';
import { AlertTriangleIcon } from 'lucide-react';
import type { Order } from '../../types';
import { Button } from '../ui/Button';
import { Select, TextArea, TextInput } from '../ui/Field';
import { naira } from '../../utils/format';

export interface RefundDraft {
  amount: number;
  method: 'refund' | 'credit';
  reason: string;
  scope: string;
}

const SCOPES = [
{ value: 'missing_items', label: 'Missing or wrong items' },
{ value: 'late', label: 'Late delivery' },
{ value: 'quality', label: 'Food quality complaint' },
{ value: 'never_arrived', label: 'Order never arrived' },
{ value: 'goodwill', label: 'Goodwill gesture' }];


/**
 * Shared body for issuing money back to a customer. Confirmation and the audit
 * entry are handled by the caller — this only collects and validates a draft.
 */
export function RefundComposer({
  order,
  onSubmit,
  submitLabel = 'Review and issue'




}: {order: Order;onSubmit: (draft: RefundDraft) => void;submitLabel?: string;}) {
  const [amount, setAmount] = React.useState('');
  const [method, setMethod] = React.useState<'refund' | 'credit'>('refund');
  const [scope, setScope] = React.useState('missing_items');
  const [reason, setReason] = React.useState('');

  const numeric = Number(amount.replace(/[^\d]/g, ''));
  const overTotal = numeric > order.totals.total;
  const invalid = !numeric || overTotal || reason.trim().length < 6;

  return (
    <form
      className="space-y-4"
      onSubmit={(event) => {
        event.preventDefault();
        if (invalid) return;
        onSubmit({
          amount: numeric,
          method,
          reason: reason.trim(),
          scope: SCOPES.find((item) => item.value === scope)?.label ?? scope
        });
      }}>
      
      <dl className="grid grid-cols-3 gap-px overflow-hidden rounded-lg border border-line bg-line">
        {[
        { label: 'Order total', value: naira(order.totals.total) },
        { label: 'Delivery fee', value: naira(order.totals.deliveryFee) },
        {
          label: 'Paid by',
          value:
          order.payment.method === 'card' ?
          'Card' :
          order.payment.method === 'transfer' ?
          'Bank transfer' :
          order.payment.method === 'wallet' ?
          'Wallet' :
          'Cash'
        }].
        map((fact) =>
        <div key={fact.label} className="bg-surface px-3 py-2">
            <dt className="text-2xs uppercase tracking-wider text-ink-faint">
              {fact.label}
            </dt>
            <dd className="tabular mt-0.5 text-base font-medium text-ink">
              {fact.value}
            </dd>
          </div>
        )}
      </dl>

      <div className="grid grid-cols-2 gap-4">
        <TextInput
          label="Amount"
          required
          prefix="₦"
          value={amount}
          onChange={setAmount}
          placeholder="0"
          hint={
          overTotal ?
          `Cannot exceed the order total of ${naira(order.totals.total)}` :
          'Partial amounts are fine.'
          } />
        
        <div>
          <label className="mb-1 block text-sm font-medium text-ink">
            Method<span className="ml-1 text-coral">*</span>
          </label>
          <Select
            label="Method"
            value={method}
            onChange={(value) => setMethod(value as 'refund' | 'credit')}
            options={[
            { value: 'refund', label: 'Refund to original payment method' },
            { value: 'credit', label: 'Credit to RolandRush wallet' }]
            } />
          
          <p className="mt-1 text-xs text-ink-muted">
            {method === 'refund' ?
            'Card refunds take 3–5 working days to land.' :
            'Wallet credit is available to the customer immediately.'}
          </p>
        </div>
      </div>

      <div>
        <label className="mb-1 block text-sm font-medium text-ink">Category</label>
        <Select
          label="Category"
          value={scope}
          onChange={setScope}
          options={SCOPES} />
        
      </div>

      <TextArea
        label="Reason"
        required
        rows={3}
        value={reason}
        onChange={setReason}
        placeholder="What happened, and what did you verify before issuing this?"
        hint="Stored on the order timeline and the audit log under your name." />
      

      <div className="flex items-start gap-2 rounded-lg border border-warn-border bg-warn-soft px-3 py-2.5">
        <AlertTriangleIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-warn" />
        <p className="text-sm text-warn-ink">
          Refunds cannot be reversed. Vendor and rider earnings on this order are
          adjusted automatically where the fault sits with them.
        </p>
      </div>

      <Button type="submit" variant="primary" size="lg" disabled={invalid}>
        {submitLabel}
      </Button>
    </form>);

}