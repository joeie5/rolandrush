import React from 'react';
import { useNavigate } from 'react-router-dom';
import { UserSquareIcon } from 'lucide-react';
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
import { StatusBadge } from '../../components/ui/Badge';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState, Pagination } from '../../components/ui/Pagination';
import { naira, shortDateTime } from '../../utils/format';

const PAGE_SIZE = 10;

export function CustomerList() {
  const { customers } = useAdmin();
  const navigate = useNavigate();
  const [query, setQuery] = React.useState('');
  const [status, setStatus] = React.useState('all');
  const [page, setPage] = React.useState(1);

  const rows = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    return customers.
    filter((customer) => status === 'all' || customer.status === status).
    filter(
      (customer) =>
      !needle ||
      customer.name.toLowerCase().includes(needle) ||
      customer.phone.includes(needle)
    ).
    sort((a, b) => b.orders - a.orders);
  }, [customers, query, status]);

  const paged = rows.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <>
      <PageHeader
        title="Customers"
        subtitle="Order history, spend and refund pattern. A high refund count relative to orders is the signal worth looking at." />
      

      <TableShell>
        <FilterBar>
          <SearchInput
            className="w-[300px]"
            value={query}
            onChange={(value) => {
              setQuery(value);
              setPage(1);
            }}
            placeholder="Name or phone number…" />
          
          <Select
            className="w-[170px]"
            label="Status"
            value={status}
            onChange={setStatus}
            options={[
            { value: 'all', label: 'Any status' },
            { value: 'active', label: 'Active' },
            { value: 'suspended', label: 'Suspended' },
            { value: 'banned', label: 'Banned' }]
            } />
          
        </FilterBar>

        {paged.length === 0 ?
        <EmptyState icon={UserSquareIcon} title="No customers match" /> :

        <Table>
            <THead>
              <TH>Customer</TH>
              <TH>Zone</TH>
              <TH align="right">Orders</TH>
              <TH align="right">Lifetime spend</TH>
              <TH align="right">Refunds</TH>
              <TH>Last order</TH>
              <TH>Status</TH>
            </THead>
            <TBody>
              {paged.map((customer) => {
              const refundRate = customer.orders ?
              customer.refunds / customer.orders :
              0;
              return (
                <TR
                  key={customer.id}
                  onClick={() => navigate(`/customers/${customer.id}`)}>
                  
                    <TD>
                      <p className="font-medium text-ink">{customer.name}</p>
                      <p className="text-xs text-ink-faint">{customer.phone}</p>
                    </TD>
                    <TD>{customer.zone}</TD>
                    <TD align="right" className="tabular">
                      {customer.orders}
                    </TD>
                    <TD align="right" className="tabular font-medium text-ink">
                      {naira(customer.lifetimeSpend, { compact: true })}
                    </TD>
                    <TD align="right">
                      <span
                      className={`tabular ${
                      refundRate > 0.2 ? 'font-medium text-coral-ink' : ''}`
                      }>
                      
                        {customer.refunds}
                        {refundRate > 0.2 ?
                      <span className="ml-1 text-xs">
                            ({Math.round(refundRate * 100)}%)
                          </span> :
                      null}
                      </span>
                    </TD>
                    <TD className="text-sm">{shortDateTime(customer.lastOrderAt)}</TD>
                    <TD>
                      <StatusBadge status={customer.status} />
                    </TD>
                  </TR>);

            })}
            </TBody>
          </Table>
        }

        <TableFoot>
          <Pagination
            page={page}
            pageSize={PAGE_SIZE}
            total={rows.length}
            onPageChange={setPage}
            noun="customers" />
          
        </TableFoot>
      </TableShell>
    </>);

}