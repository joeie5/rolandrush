import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader, DefinitionList } from '../../components/ui/Panel';
import { Dot, StatusBadge } from '../../components/ui/Badge';
import { AccountStatusActions } from '../../components/directory/AccountStatusActions';
import { OrderMiniTable } from '../../components/directory/OrderMiniTable';
import { AuditEntryList } from '../../components/AuditEntryList';
import { dayMonth, naira, titleCase } from '../../utils/format';

export function RiderDetail() {
  const { id } = useParams();
  const { riders, orders, withdrawals, audit } = useAdmin();
  const rider = riders.find((entry) => entry.id === id);

  if (!rider) {
    return (
      <Panel padded>
        <p className="text-base text-ink-muted">
          Rider not found.{' '}
          <Link to="/riders" className="text-coral underline">
            Back to riders
          </Link>
        </p>
      </Panel>);

  }

  const riderOrders = orders.filter((order) => order.riderId === rider.id);
  const payouts = withdrawals.filter((entry) => entry.requesterId === rider.id);
  const history = audit.filter((entry) =>
  entry.sentence.toLowerCase().includes(rider.name.toLowerCase())
  );

  return (
    <>
      <PageHeader
        backTo="/riders"
        backLabel="Riders"
        title={rider.name}
        subtitle={
        <span className="flex flex-wrap items-center gap-2">
            <StatusBadge status={rider.status} />
            <span className="inline-flex items-center gap-1.5 text-sm">
              <Dot tone={rider.online ? 'ok' : 'neutral'} />
              {rider.online ? 'Online now' : 'Offline'}
            </span>
            <span>
              {rider.phone} · {rider.zone} · {titleCase(rider.vehicle)}{' '}
              {rider.plateNumber}
            </span>
          </span>
        }
        actions={
        <AccountStatusActions
          kind="rider"
          id={rider.id}
          name={rider.name}
          status={rider.status} />

        } />
      

      <div className="mb-4 grid grid-cols-2 gap-px overflow-hidden rounded-xl border border-line bg-line lg:grid-cols-5">
        {[
        { label: 'Deliveries (30d)', value: `${rider.deliveries30d}` },
        {
          label: 'Acceptance rate',
          value: rider.acceptanceRate ?
          `${Math.round(rider.acceptanceRate * 100)}%` :
          '—'
        },
        { label: 'Rating', value: rider.rating ? rider.rating.toFixed(1) : '—' },
        {
          label: 'Earnings paid out',
          value: naira(
            payouts.reduce((sum, payout) => sum + payout.amount, 0),
            { compact: true }
          )
        },
        { label: 'Riding since', value: dayMonth(rider.joinedAt) }].
        map((stat) =>
        <div key={stat.label} className="bg-surface px-4 py-3">
            <p className="text-xs text-ink-muted">{stat.label}</p>
            <p className="tabular mt-0.5 text-lg font-semibold text-ink">
              {stat.value}
            </p>
          </div>
        )}
      </div>

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 space-y-4 xl:col-span-8">
          <Panel>
            <PanelHeader
              title="Recent deliveries"
              meta={`${riderOrders.length} on record`} />
            
            <OrderMiniTable
              orders={riderOrders}
              counterparty={(order) => order.vendorName} />
            
          </Panel>

          <Panel>
            <PanelHeader title="Admin history" />
            {history.length ?
            <AuditEntryList entries={history} showArea /> :

            <p className="px-4 py-5 text-base text-ink-muted">
                Nothing has been changed on this account by an admin.
              </p>
            }
          </Panel>
        </div>

        <aside className="col-span-12 space-y-4 xl:col-span-4">
          <Panel>
            <PanelHeader title="Rider details" />
            <div className="px-4 py-4">
              <DefinitionList
                items={[
                { label: 'Phone', value: rider.phone },
                { label: 'Vehicle', value: titleCase(rider.vehicle) },
                { label: 'Plate number', value: rider.plateNumber },
                { label: 'Service zone', value: rider.zone },
                { label: 'Payout schedule', value: 'On request, min ₦5,000' }]
                } />
              
            </div>
          </Panel>

          <Panel>
            <PanelHeader title="Payout history" meta={`${payouts.length} requests`} />
            {payouts.length ?
            <ul className="divide-y divide-line">
                {payouts.map((payout) =>
              <li key={payout.id}>
                    <Link
                  to={`/withdrawals/${payout.id}`}
                  className="flex items-center gap-2 px-4 py-2.5 transition-colors duration-150 ease-exp hover:bg-canvas">
                  
                      <span className="tabular flex-1 text-base font-medium text-ink">
                        {naira(payout.amount)}
                      </span>
                      <StatusBadge status={payout.status} />
                      <span className="text-xs text-ink-faint">
                        {dayMonth(payout.requestedAt)}
                      </span>
                    </Link>
                  </li>
              )}
              </ul> :

            <p className="px-4 py-5 text-base text-ink-muted">
                No payout requests yet.
              </p>
            }
          </Panel>
        </aside>
      </div>
    </>);

}