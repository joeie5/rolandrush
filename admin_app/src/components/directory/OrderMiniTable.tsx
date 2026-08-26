import React from 'react';
import { useNavigate } from 'react-router-dom';
import { PackageIcon } from 'lucide-react';
import { Table, TBody, TD, TH, THead, TR } from '../ui/Table';
import { StatusBadge } from '../ui/Badge';
import { EmptyState } from '../ui/Pagination';
import { naira, shortDateTime } from '../../utils/format';
import type { Order } from '../../types';

export function OrderMiniTable({
  orders,
  counterparty



}: {orders: Order[];counterparty: (order: Order) => string;}) {
  const navigate = useNavigate();

  if (orders.length === 0) {
    return <EmptyState icon={PackageIcon} title="No orders on record yet" />;
  }

  return (
    <Table>
      <THead>
        <TH>Order</TH>
        <TH>With</TH>
        <TH align="right">Total</TH>
        <TH>Placed</TH>
        <TH>Status</TH>
      </THead>
      <TBody>
        {orders.map((order) =>
        <TR key={order.id} onClick={() => navigate(`/orders/${order.id}`)}>
            <TD className="font-medium text-ink">{order.code}</TD>
            <TD>{counterparty(order)}</TD>
            <TD align="right" className="tabular">
              {naira(order.totals.total)}
            </TD>
            <TD className="text-sm">{shortDateTime(order.placedAt)}</TD>
            <TD>
              <StatusBadge status={order.status} />
            </TD>
          </TR>
        )}
      </TBody>
    </Table>);

}