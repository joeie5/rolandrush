import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader, DefinitionList } from '../../components/ui/Panel';
import { Badge, StatusBadge } from '../../components/ui/Badge';
import { AccountStatusActions } from '../../components/directory/AccountStatusActions';
import { OrderMiniTable } from '../../components/directory/OrderMiniTable';
import { AuditEntryList } from '../../components/AuditEntryList';
import { dayMonth, naira, titleCase } from '../../utils/format';

export function VendorDetail() {
  const { id } = useParams();
  const { vendors, orders, withdrawals, audit } = useAdmin();
  const vendor = vendors.find((entry) => entry.id === id);

  if (!vendor) {
    return (
      <Panel padded>
        <p className="text-base text-ink-muted">
          Vendor not found.{' '}
          <Link to="/vendors" className="text-coral underline">
            Back to vendors
          </Link>
        </p>
      </Panel>);

  }

  const vendorOrders = orders.filter((order) => order.vendorId === vendor.id);
  const payouts = withdrawals.filter((entry) => entry.requesterId === vendor.id);
  const history = audit.filter((entry) =>
  entry.sentence.toLowerCase().includes(vendor.name.toLowerCase())
  );

  return (
    <>
      <PageHeader
        backTo="/vendors"
        backLabel="Vendors"
        title={vendor.name}
        subtitle={
        <span className="flex flex-wrap items-center gap-2">
            <StatusBadge status={vendor.status} />
            <Badge tone={vendor.tier === 'featured' ? 'info' : 'neutral'}>
              {titleCase(vendor.tier)}
            </Badge>
            <span>
              {vendor.owner} · {vendor.phone} · {vendor.zone}
            </span>
          </span>
        }
        actions={
        <AccountStatusActions
          kind="vendor"
          id={vendor.id}
          name={vendor.name}
          status={vendor.status} />

        } />
      

      <div className="mb-4 grid grid-cols-2 gap-px overflow-hidden rounded-xl border border-line bg-line lg:grid-cols-5">
        {[
        { label: 'Orders (30d)', value: `${vendor.orders30d}` },
        { label: 'GMV (30d)', value: naira(vendor.gmv30d, { compact: true }) },
        {
          label: 'Avg basket',
          value: vendor.orders30d ?
          naira(Math.round(vendor.gmv30d / vendor.orders30d)) :
          '—'
        },
        { label: 'Rating', value: vendor.rating ? vendor.rating.toFixed(1) : '—' },
        { label: 'On platform since', value: dayMonth(vendor.joinedAt) }].
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
            <PanelHeader title="Recent orders" meta={`${vendorOrders.length} on record`} />
            <OrderMiniTable
              orders={vendorOrders}
              counterparty={(order) => order.customerName} />
            
          </Panel>

          <Panel>
            <PanelHeader title="Admin history" meta="Everything anyone did to this account" />
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
            <PanelHeader title="Business details" />
            <div className="px-4 py-4">
              <DefinitionList
                items={[
                { label: 'CAC number', value: vendor.cacNumber },
                { label: 'Owner', value: vendor.owner },
                { label: 'Phone', value: vendor.phone },
                { label: 'Service zone', value: vendor.zone },
                { label: 'Commission', value: '15% of order subtotal' }]
                } />
              
            </div>
          </Panel>

          <Panel>
            <PanelHeader
              title="Payout history"
              meta={`${payouts.length} requests`}
              action={
              <Link
                to="/withdrawals"
                className="text-sm text-coral underline-offset-2 hover:underline">
                
                  Queue
                </Link>
              } />
            
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