import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { AlertTriangleIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader, DefinitionList } from '../../components/ui/Panel';
import { StatusBadge } from '../../components/ui/Badge';
import { AccountStatusActions } from '../../components/directory/AccountStatusActions';
import { OrderMiniTable } from '../../components/directory/OrderMiniTable';
import { AuditEntryList } from '../../components/AuditEntryList';
import { dayMonth, naira, shortDateTime } from '../../utils/format';

export function CustomerDetail() {
  const { id } = useParams();
  const { customers, orders, audit } = useAdmin();
  const customer = customers.find((entry) => entry.id === id);

  if (!customer) {
    return (
      <Panel padded>
        <p className="text-base text-ink-muted">
          Customer not found.{' '}
          <Link to="/customers" className="text-coral underline">
            Back to customers
          </Link>
        </p>
      </Panel>);

  }

  const customerOrders = orders.filter((order) => order.customerId === customer.id);
  const history = audit.filter((entry) =>
  entry.sentence.toLowerCase().includes(customer.name.toLowerCase())
  );
  const refundRate = customer.orders ? customer.refunds / customer.orders : 0;

  return (
    <>
      <PageHeader
        backTo="/customers"
        backLabel="Customers"
        title={customer.name}
        subtitle={
        <span className="flex flex-wrap items-center gap-2">
            <StatusBadge status={customer.status} />
            <span>
              {customer.phone} · {customer.zone} · joined{' '}
              {dayMonth(customer.joinedAt)}
            </span>
          </span>
        }
        actions={
        <AccountStatusActions
          kind="customer"
          id={customer.id}
          name={customer.name}
          status={customer.status}
          allowBan />

        } />
      

      {refundRate > 0.2 ?
      <div className="mb-4 flex items-start gap-2.5 rounded-xl border border-coral-border bg-coral-soft px-4 py-3">
          <AlertTriangleIcon className="mt-0.5 h-4 w-4 shrink-0 text-coral" />
          <p className="text-base text-coral-ink">
            {customer.refunds} refunds on {customer.orders} orders (
            {Math.round(refundRate * 100)}%). Worth checking the pattern before
            approving another refund.
          </p>
        </div> :
      null}

      <div className="mb-4 grid grid-cols-2 gap-px overflow-hidden rounded-xl border border-line bg-line lg:grid-cols-5">
        {[
        { label: 'Orders', value: `${customer.orders}` },
        {
          label: 'Lifetime spend',
          value: naira(customer.lifetimeSpend, { compact: true })
        },
        {
          label: 'Avg order',
          value: customer.orders ?
          naira(Math.round(customer.lifetimeSpend / customer.orders)) :
          '—'
        },
        { label: 'Refunds', value: `${customer.refunds}` },
        { label: 'Last order', value: shortDateTime(customer.lastOrderAt) }].
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
              title="Order history"
              meta={`${customerOrders.length} on record`} />
            
            <OrderMiniTable
              orders={customerOrders}
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

        <aside className="col-span-12 xl:col-span-4">
          <Panel>
            <PanelHeader title="Account details" />
            <div className="px-4 py-4">
              <DefinitionList
                items={[
                { label: 'Phone', value: customer.phone },
                { label: 'Home zone', value: customer.zone },
                { label: 'Wallet balance', value: naira(2400) },
                { label: 'Preferred payment', value: 'Card (Paystack)' }]
                } />
              
            </div>
          </Panel>
        </aside>
      </div>
    </>);

}