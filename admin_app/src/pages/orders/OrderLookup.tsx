import React from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { PackageSearchIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import {
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
  TableFoot,
  TableShell } from
'../../components/ui/Table';
import { StatusBadge, TierBadge } from '../../components/ui/Badge';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState, Pagination } from '../../components/ui/Pagination';
import { naira, shortDateTime } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';

const PAGE_SIZE = 10;

export function OrderLookup() {
  const { orders } = useAdmin();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [query, setQuery] = React.useState(params.get('q') ?? '');
  const [status, setStatus] = React.useState('all');
  const [zone, setZone] = React.useState('all');
  const [page, setPage] = React.useState(1);

  const zones = Array.from(new Set(orders.map((order) => order.zone)));

  const rows = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    return orders.
    filter((order) => status === 'all' || order.status === status).
    filter((order) => zone === 'all' || order.zone === zone).
    filter(
      (order) =>
      !needle ||
      order.code.toLowerCase().includes(needle) ||
      order.customerName.toLowerCase().includes(needle) ||
      order.vendorName.toLowerCase().includes(needle) ||
      (order.riderName ?? '').toLowerCase().includes(needle) ||
      order.customerPhone.includes(needle)
    ).
    sort((a, b) => b.placedAt.localeCompare(a.placedAt));
  }, [orders, query, status, zone]);

  const paged = rows.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <>
      <PageHeader
        title="Order lookup"
        subtitle="One search across order numbers, customers, vendors and riders. Open an order to see its whole journey in one timeline." />
      

      <TableShell>
        <FilterBar>
          <SearchInput
            className="w-[380px]"
            value={query}
            onChange={(value) => {
              setQuery(value);
              setPage(1);
            }}
            placeholder="Order number, customer, vendor, rider or phone…" />
          
          <Select
            className="w-[180px]"
            label="Status"
            value={status}
            onChange={(value) => {
              setStatus(value);
              setPage(1);
            }}
            options={[
            { value: 'all', label: 'Any status' },
            { value: 'awaiting_rider', label: 'Awaiting rider' },
            { value: 'in_transit', label: 'In transit' },
            { value: 'delivered', label: 'Delivered' },
            { value: 'cancelled', label: 'Cancelled' },
            { value: 'refunded', label: 'Refunded' }]
            } />
          
          <Select
            className="w-[180px]"
            label="Zone"
            value={zone}
            onChange={(value) => {
              setZone(value);
              setPage(1);
            }}
            options={[
            { value: 'all', label: 'All zones' },
            ...zones.map((name) => ({ value: name, label: name }))]
            } />
          
        </FilterBar>

        {paged.length === 0 ?
        <EmptyState
          icon={PackageSearchIcon}
          title="No orders match that search"
          body="Try the full order number (e.g. RR-88240) or the customer’s phone number." /> :


        <Table>
            <THead>
              <TH>Order</TH>
              <TH>Customer</TH>
              <TH>Vendor</TH>
              <TH>Rider</TH>
              <TH align="right">Total</TH>
              <TH>Placed</TH>
              <TH>Status</TH>
              <TH>Payment</TH>
            </THead>
            <TBody>
              {paged.map((order) =>
            <TR
              key={order.id}
              onClick={() => navigate(`/orders/${order.id}`)}
              className={TIER_META[order.tier].rail}>
              
                  <TD>
                    <p className="font-medium text-ink">{order.code}</p>
                    <p className="text-xs text-ink-faint">{order.zone}</p>
                  </TD>
                  <TD>{order.customerName}</TD>
                  <TD>{order.vendorName}</TD>
                  <TD className={order.riderName ? '' : 'text-ink-faint'}>
                    {order.riderName ?? 'Unassigned'}
                  </TD>
                  <TD align="right" className="tabular font-medium text-ink">
                    {naira(order.totals.total)}
                  </TD>
                  <TD className="text-sm">{shortDateTime(order.placedAt)}</TD>
                  <TD>
                    <div className="flex items-center gap-1.5">
                      <StatusBadge status={order.status} />
                      {order.stalledMinutes ?
                  <TierBadge tier={order.tier} withLabel={false} /> :
                  null}
                    </div>
                    {order.stalledMinutes ?
                <p className="mt-1 text-xs font-medium text-coral-ink">
                        Stalled {order.stalledMinutes}m
                      </p> :
                null}
                  </TD>
                  <TD>
                    <StatusBadge status={order.payment.status} />
                  </TD>
                </TR>
            )}
            </TBody>
          </Table>
        }

        <TableFoot>
          <Pagination
            page={page}
            pageSize={PAGE_SIZE}
            total={rows.length}
            onPageChange={setPage}
            noun="orders" />
          
        </TableFoot>
      </TableShell>
    </>);

}