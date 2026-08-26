import React from 'react';
import { Link } from 'react-router-dom';
import { SearchIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { SearchInput } from '../../components/ui/Field';
import { StatusBadge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/Pagination';
import { RefundComposer } from '../../components/orders/RefundComposer';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { AuditEntryList } from '../../components/AuditEntryList';
import { naira, shortDateTime } from '../../utils/format';

export function Refunds() {
  const { orders, issueRefund, audit } = useAdmin();
  const decision = useDecision();
  const [query, setQuery] = React.useState('');
  const [selectedId, setSelectedId] = React.useState<string | null>(null);

  const matches = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    if (!needle) return [];
    return orders.
    filter(
      (order) =>
      order.code.toLowerCase().includes(needle) ||
      order.customerName.toLowerCase().includes(needle) ||
      order.customerPhone.includes(needle)
    ).
    slice(0, 6);
  }, [orders, query]);

  const order = orders.find((entry) => entry.id === selectedId) ?? null;
  const refundHistory = audit.
  filter((entry) => entry.sentence.includes('refund') || entry.sentence.includes('credit')).
  slice(0, 6);

  return (
    <>
      <PageHeader
        title="Refunds & credits"
        subtitle="Issue money back on a specific order. Find the order first — every refund is tied to one, so the ledger and the customer’s history stay honest." />
      

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 xl:col-span-7">
          <Panel>
            <PanelHeader
              title={order ? `Issuing on ${order.code}` : 'Step 1 — find the order'}
              meta={
              order ?
              `${order.customerName} · ${order.vendorName} · ${shortDateTime(order.placedAt)}` :
              'Search by order number, customer name or phone number.'
              }
              action={
              order ?
              <button
                type="button"
                onClick={() => setSelectedId(null)}
                className="text-sm text-coral underline-offset-2 hover:underline">
                
                    Choose a different order
                  </button> :
              null
              } />
            

            {order ?
            <div className="px-4 py-4">
                <RefundComposer
                order={order}
                onSubmit={(draft) => {
                  decision.ask({
                    title: `Send ${naira(draft.amount)} back to ${order.customerName}?`,
                    consequence:
                    draft.method === 'refund' ?
                    'The refund goes to the payment provider immediately and cannot be reversed.' :
                    'The wallet credit is available immediately and cannot be reversed.',
                    facts: [
                    { label: 'Order', value: order.code },
                    { label: 'Amount', value: naira(draft.amount) },
                    { label: 'Category', value: draft.scope }],

                    intent: 'approve',
                    reasonRequired: false,
                    confirmLabel:
                    draft.method === 'refund' ?
                    'Issue refund' :
                    'Issue wallet credit',
                    onConfirm: () => {
                      issueRefund(order.id, draft.amount, draft.method, draft.reason);
                      setSelectedId(null);
                      setQuery('');
                    }
                  });
                }} />
              
              </div> :

            <>
                <div className="border-b border-line px-4 py-3">
                  <SearchInput
                  value={query}
                  onChange={setQuery}
                  placeholder="RR-88213, Adaeze Nwosu, 0809…" />
                
                </div>
                {query && matches.length === 0 ?
              <EmptyState
                icon={SearchIcon}
                title="No orders match that"
                body="Check the order number with the customer, or search their phone number instead." /> :

              matches.length ?
              <ul className="divide-y divide-line">
                    {matches.map((match) =>
                <li key={match.id}>
                        <button
                    type="button"
                    onClick={() => setSelectedId(match.id)}
                    className="flex w-full items-center gap-3 px-4 py-2.5 text-left transition-colors duration-150 ease-exp hover:bg-canvas">
                    
                          <span className="w-24 font-medium text-ink">{match.code}</span>
                          <span className="flex-1 truncate text-base text-ink-soft">
                            {match.customerName} · {match.vendorName}
                          </span>
                          <StatusBadge status={match.payment.status} />
                          <span className="tabular w-20 text-right text-base text-ink">
                            {naira(match.totals.total)}
                          </span>
                        </button>
                      </li>
                )}
                  </ul> :

              <p className="px-4 py-6 text-base text-ink-muted">
                    Start typing to find the order.
                  </p>
              }
              </>
            }
          </Panel>
        </div>

        <aside className="col-span-12 xl:col-span-5">
          <Panel>
            <PanelHeader
              title="Recent money returned"
              meta="Automatic refunds are included — those needed no decision."
              action={
              <Link
                to="/audit"
                className="text-sm text-coral underline-offset-2 hover:underline">
                
                  Audit log
                </Link>
              } />
            
            <AuditEntryList entries={refundHistory} />
          </Panel>
        </aside>
      </div>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}