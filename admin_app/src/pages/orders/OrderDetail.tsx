import React from 'react';
import { Link, useParams } from 'react-router-dom';
import {
  AlertTriangleIcon,
  BanknoteIcon,
  MessageSquareIcon,
  PhoneIcon,
  SlidersHorizontalIcon } from
'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { Badge, StatusBadge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { Select, TextArea } from '../../components/ui/Field';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { OrderTimeline } from '../../components/orders/OrderTimeline';
import { RefundComposer } from '../../components/orders/RefundComposer';
import { clockTime, dateTime, naira, titleCase } from '../../utils/format';
import type { OrderStatus } from '../../types';

const STATUS_OPTIONS: {value: OrderStatus;label: string;}[] = [
{ value: 'accepted', label: 'Accepted by vendor' },
{ value: 'preparing', label: 'Preparing' },
{ value: 'awaiting_rider', label: 'Awaiting rider' },
{ value: 'in_transit', label: 'In transit' },
{ value: 'delivered', label: 'Delivered' },
{ value: 'cancelled', label: 'Cancelled' }];


export function OrderDetail() {
  const { id } = useParams();
  const { orders, overrideOrderStatus, issueRefund } = useAdmin();
  const decision = useDecision();
  const [overrideOpen, setOverrideOpen] = React.useState(false);
  const [refundOpen, setRefundOpen] = React.useState(false);
  const [nextStatus, setNextStatus] = React.useState<OrderStatus>('delivered');
  const [overrideReason, setOverrideReason] = React.useState('');

  const order = orders.find((entry) => entry.id === id);

  if (!order) {
    return (
      <Panel padded>
        <p className="text-base text-ink-muted">
          Order not found.{' '}
          <Link to="/orders" className="text-coral underline">
            Back to lookup
          </Link>
        </p>
      </Panel>);

  }

  return (
    <>
      <PageHeader
        backTo="/orders"
        backLabel="Order lookup"
        title={order.code}
        subtitle={
        <span className="flex flex-wrap items-center gap-2">
            <StatusBadge status={order.status} />
            {order.stalledMinutes ? <TierBadge tier={order.tier} /> : null}
            <span>
              Placed {dateTime(order.placedAt)} · {order.zone}
            </span>
          </span>
        }
        actions={
        <>
            <Button
            icon={SlidersHorizontalIcon}
            onClick={() => setOverrideOpen(true)}>
            
              Override status
            </Button>
            <Button
            variant="primary"
            icon={BanknoteIcon}
            onClick={() => setRefundOpen(true)}>
            
              Refund or credit
            </Button>
          </>
        } />
      

      {order.note ?
      <div className="mb-4 flex items-start gap-2.5 rounded-xl border border-coral-border bg-coral-soft px-4 py-3">
          <AlertTriangleIcon className="mt-0.5 h-4 w-4 shrink-0 text-coral" />
          <p className="text-base text-coral-ink">{order.note}</p>
        </div> :
      null}

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 space-y-4 xl:col-span-7">
          <Panel>
            <PanelHeader
              title="Full journey"
              meta="Customer, vendor, dispatch, rider and money — in one timeline." />
            
            <OrderTimeline events={order.timeline} />
          </Panel>

          <Panel>
            <PanelHeader
              title="Chat log"
              meta={
              order.chat.length ?
              `${order.chat.length} messages between the customer, vendor, rider and support` :
              undefined
              } />
            
            {order.chat.length === 0 ?
            <p className="flex items-center gap-2 px-4 py-5 text-base text-ink-muted">
                <MessageSquareIcon className="h-4 w-4 text-ink-faint" />
                No messages were exchanged on this order.
              </p> :

            <ul className="divide-y divide-line">
                {order.chat.map((message) =>
              <li key={message.id} className="px-4 py-3">
                    <div className="flex items-baseline gap-2">
                      <p className="text-base font-medium text-ink">{message.name}</p>
                      <Badge
                    tone={
                    message.from === 'support' ?
                    'info' :
                    message.from === 'customer' ?
                    'neutral' :
                    'neutral'
                    }>
                    
                        {message.from}
                      </Badge>
                      <span className="tabular ml-auto text-xs text-ink-faint">
                        {clockTime(message.at)}
                      </span>
                    </div>
                    <p className="mt-1 text-base text-ink-soft">{message.body}</p>
                  </li>
              )}
              </ul>
            }
          </Panel>
        </div>

        <div className="col-span-12 space-y-4 xl:col-span-5">
          <Panel>
            <PanelHeader title="People on this order" />
            <ul className="divide-y divide-line">
              {[
              {
                role: 'Customer',
                name: order.customerName,
                meta: `${order.customerPhone} · ${order.address}`,
                href: `/customers/${order.customerId}`
              },
              {
                role: 'Vendor',
                name: order.vendorName,
                meta: order.zone,
                href: `/vendors/${order.vendorId}`
              },
              {
                role: 'Rider',
                name: order.riderName ?? 'Not assigned',
                meta: order.riderId ? 'Assigned by dispatch engine' : 'No rider accepted yet',
                href: order.riderId ? `/riders/${order.riderId}` : null
              }].
              map((person) =>
              <li key={person.role} className="flex items-start gap-3 px-4 py-3">
                  <div className="min-w-0 flex-1">
                    <p className="text-2xs uppercase tracking-wider text-ink-faint">
                      {person.role}
                    </p>
                    <p className="text-base font-medium text-ink">{person.name}</p>
                    <p className="truncate text-sm text-ink-muted">{person.meta}</p>
                  </div>
                  {person.href ?
                <Link
                  to={person.href}
                  className="shrink-0 text-sm text-coral underline-offset-2 hover:underline">
                  
                      Open
                    </Link> :
                null}
                </li>
              )}
            </ul>
            <div className="flex gap-2 border-t border-line px-4 py-3">
              <Button size="sm" icon={PhoneIcon}>
                Call customer
              </Button>
              {order.riderId ?
              <Button size="sm" icon={PhoneIcon}>
                  Call rider
                </Button> :
              null}
            </div>
          </Panel>

          <Panel>
            <PanelHeader title="Items & money" />
            <ul className="divide-y divide-line">
              {order.lines.map((line) =>
              <li
                key={line.name}
                className="flex items-baseline gap-3 px-4 py-2 text-base">
                
                  <span className="tabular w-6 text-ink-muted">{line.qty}×</span>
                  <span className="flex-1 text-ink">{line.name}</span>
                  <span className="tabular text-ink-soft">
                    {naira(line.price * line.qty)}
                  </span>
                </li>
              )}
            </ul>
            <dl className="space-y-1 border-t border-line px-4 py-3 text-base">
              {[
              { label: 'Subtotal', value: naira(order.totals.subtotal) },
              { label: 'Delivery fee', value: naira(order.totals.deliveryFee) },
              { label: 'Service fee', value: naira(order.totals.serviceFee) },
              ...(order.totals.discount ?
              [{ label: 'Discount', value: `−${naira(order.totals.discount)}` }] :
              [])].
              map((row) =>
              <div key={row.label} className="flex justify-between">
                  <dt className="text-ink-muted">{row.label}</dt>
                  <dd className="tabular text-ink-soft">{row.value}</dd>
                </div>
              )}
              <div className="flex justify-between border-t border-line pt-2">
                <dt className="font-medium text-ink">Total</dt>
                <dd className="tabular font-semibold text-ink">
                  {naira(order.totals.total)}
                </dd>
              </div>
            </dl>
            <div className="flex items-center gap-2 border-t border-line bg-canvas px-4 py-2.5">
              <StatusBadge status={order.payment.status} />
              <p className="text-sm text-ink-muted">
                {titleCase(order.payment.method)} · {order.payment.reference}
                {order.payment.settledAt ?
                ` · settled ${clockTime(order.payment.settledAt)}` :
                ''}
              </p>
            </div>
          </Panel>
        </div>
      </div>

      {/* Status override */}
      <Modal
        open={overrideOpen}
        onClose={() => setOverrideOpen(false)}
        title="Override order status"
        description="Use this only when the apps got it wrong. The customer, vendor and rider all see the change."
        footer={
        <>
            <Button variant="ghost" onClick={() => setOverrideOpen(false)}>
              Cancel
            </Button>
            <Button
            variant="primary"
            disabled={overrideReason.trim().length < 6}
            onClick={() => {
              setOverrideOpen(false);
              decision.ask({
                title: `Set ${order.code} to ${titleCase(nextStatus)}?`,
                consequence:
                'This rewrites the order’s state for everyone and cannot be undone from here.',
                facts: [
                { label: 'Current status', value: titleCase(order.status) },
                { label: 'New status', value: titleCase(nextStatus) },
                { label: 'Reason', value: overrideReason.trim() }],

                intent: 'approve',
                reasonRequired: false,
                confirmLabel: 'Apply override',
                onConfirm: () => {
                  overrideOrderStatus(order.id, nextStatus, overrideReason.trim());
                  setOverrideReason('');
                }
              });
            }}>
            
              Continue
            </Button>
          </>
        }>
        
        <div className="space-y-4">
          <div>
            <label className="mb-1 block text-sm font-medium text-ink">
              New status<span className="ml-1 text-coral">*</span>
            </label>
            <Select
              label="New status"
              value={nextStatus}
              onChange={(value) => setNextStatus(value as OrderStatus)}
              options={STATUS_OPTIONS.filter(
                (option) => option.value !== order.status
              )} />
            
            <p className="mt-1 text-xs text-ink-muted">
              Current status is {titleCase(order.status)}.
            </p>
          </div>
          <TextArea
            label="Reason for the override"
            required
            rows={3}
            value={overrideReason}
            onChange={setOverrideReason}
            placeholder="e.g. Customer confirmed receipt by phone, rider’s app crashed before confirming." />
          
        </div>
      </Modal>

      {/* Refund / credit */}
      <Modal
        open={refundOpen}
        onClose={() => setRefundOpen(false)}
        title={`Refund or credit — ${order.code}`}
        description={`${order.customerName} · ${order.vendorName}`}
        width="max-w-xl">
        
        <RefundComposer
          order={order}
          onSubmit={(draft) => {
            setRefundOpen(false);
            decision.ask({
              title: `Send ${naira(draft.amount)} back to ${order.customerName}?`,
              consequence:
              draft.method === 'refund' ?
              'The refund is submitted to the payment provider immediately and cannot be reversed.' :
              'The wallet credit is available to the customer immediately and cannot be reversed.',
              facts: [
              { label: 'Order', value: order.code },
              { label: 'Amount', value: naira(draft.amount) },
              {
                label: 'Method',
                value:
                draft.method === 'refund' ?
                'Original payment method' :
                'RolandRush wallet'
              },
              { label: 'Category', value: draft.scope }],

              intent: 'approve',
              reasonRequired: false,
              confirmLabel:
              draft.method === 'refund' ? 'Issue refund' : 'Issue wallet credit',
              onConfirm: () =>
              issueRefund(order.id, draft.amount, draft.method, draft.reason)
            });
          }} />
        
      </Modal>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}