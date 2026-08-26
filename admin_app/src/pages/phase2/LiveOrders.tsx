import React from 'react';
import { Link } from 'react-router-dom';
import { AlertTriangleIcon, GaugeCircleIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { StatusBadge, TierBadge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/Pagination';
import { ago, clockTime, naira } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';
import type { Order, OrderStatus } from '../../types';

const COLUMNS: {status: OrderStatus | 'stalled';label: string;hint: string;}[] = [
{ status: 'stalled', label: 'Stalled — flagged', hint: 'No movement past the expected window' },
{ status: 'awaiting_rider', label: 'Awaiting rider', hint: 'Vendor ready, no rider yet' },
{ status: 'in_transit', label: 'In transit', hint: 'On the way to the customer' },
{ status: 'delivered', label: 'Delivered today', hint: 'Closed, no action needed' }];


function OrderCard({ order }: {order: Order;}) {
  return (
    <Link
      to={`/orders/${order.id}`}
      className={`block rounded-lg border border-line bg-surface px-3 py-2.5 transition-colors duration-150 ease-exp hover:bg-canvas ${
      order.stalledMinutes ? TIER_META.urgent.rail : ''}`
      }>
      
      <div className="flex items-center gap-2">
        <p className="text-base font-medium text-ink">{order.code}</p>
        {order.stalledMinutes ? <TierBadge tier="urgent" withLabel={false} /> : null}
        <span className="tabular ml-auto text-sm text-ink-soft">
          {naira(order.totals.total)}
        </span>
      </div>
      <p className="mt-0.5 truncate text-sm text-ink-muted">{order.vendorName}</p>
      <p className="truncate text-xs text-ink-faint">
        {order.riderName ?? 'No rider'} · placed {clockTime(order.placedAt)}
      </p>
      {order.stalledMinutes ?
      <p className="mt-1.5 flex items-center gap-1 text-xs font-medium text-coral-ink">
          <AlertTriangleIcon className="h-3 w-3" />
          Stalled {order.stalledMinutes} minutes
        </p> :
      null}
    </Link>);

}

export function LiveOrders() {
  const { orders } = useAdmin();

  const bucket = (key: OrderStatus | 'stalled') =>
  key === 'stalled' ?
  orders.filter((order) => Boolean(order.stalledMinutes)) :
  orders.filter(
    (order) => order.status === key && !order.stalledMinutes
  );

  const stalled = bucket('stalled');

  return (
    <>
      <PageHeader
        title="Live order board"
        phaseTwo
        subtitle="Orders in flight, grouped by where they are stuck. The board flags stalls automatically — you only look at the first column."
        actions={
        <span className="tabular text-sm text-ink-muted">
            Refreshed {ago(new Date().toISOString())} · auto every 60s
          </span>
        } />
      

      {stalled.length ?
      <div className="mb-4 flex items-start gap-2.5 rounded-xl border border-coral-border bg-coral-soft px-4 py-3">
          <AlertTriangleIcon className="mt-0.5 h-4 w-4 shrink-0 text-coral" />
          <p className="text-base text-coral-ink">
            {stalled.length} order{stalled.length === 1 ? '' : 's'} stalled past the
            expected window. Everything else on this board is progressing normally.
          </p>
        </div> :
      null}

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-4">
        {COLUMNS.map((column) => {
          const items = bucket(column.status);
          return (
            <Panel key={column.label}>
              <PanelHeader
                title={
                <span className="flex items-center gap-2">
                    {column.label}
                    <span className="tabular text-sm font-normal text-ink-muted">
                      {items.length}
                    </span>
                  </span>
                }
                meta={column.hint} />
              
              <div className="space-y-2 px-3 py-3">
                {items.length ?
                items.map((order) => <OrderCard key={order.id} order={order} />) :

                <p className="px-1 py-3 text-sm text-ink-faint">Nothing here.</p>
                }
              </div>
            </Panel>);

        })}
      </div>

      {orders.length === 0 ?
      <Panel className="mt-4">
          <EmptyState icon={GaugeCircleIcon} title="No live orders" />
        </Panel> :
      null}
    </>);

}