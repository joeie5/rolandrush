import React from 'react';
import { useNavigate } from 'react-router-dom';
import { BuildingIcon } from 'lucide-react';
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
import { Badge, StatusBadge } from '../../components/ui/Badge';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState, Pagination } from '../../components/ui/Pagination';
import { dayMonth, naira, titleCase } from '../../utils/format';

const PAGE_SIZE = 10;

export function VendorList() {
  const { vendors } = useAdmin();
  const navigate = useNavigate();
  const [query, setQuery] = React.useState('');
  const [status, setStatus] = React.useState('all');
  const [tier, setTier] = React.useState('all');
  const [zone, setZone] = React.useState('all');
  const [sortKey, setSortKey] = React.useState<'gmv30d' | 'orders30d'>('gmv30d');
  const [direction, setDirection] = React.useState<'asc' | 'desc'>('desc');
  const [page, setPage] = React.useState(1);

  const zones = Array.from(new Set(vendors.map((vendor) => vendor.zone)));

  const rows = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    return vendors.
    filter((vendor) => status === 'all' || vendor.status === status).
    filter((vendor) => tier === 'all' || vendor.tier === tier).
    filter((vendor) => zone === 'all' || vendor.zone === zone).
    filter(
      (vendor) =>
      !needle ||
      vendor.name.toLowerCase().includes(needle) ||
      vendor.owner.toLowerCase().includes(needle) ||
      vendor.phone.includes(needle) ||
      vendor.cacNumber.toLowerCase().includes(needle)
    ).
    sort((a, b) => {
      const value = a[sortKey] - b[sortKey];
      return direction === 'asc' ? value : -value;
    });
  }, [vendors, query, status, tier, zone, sortKey, direction]);

  const paged = rows.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const toggleSort = (key: 'gmv30d' | 'orders30d') => {
    if (sortKey === key) setDirection(direction === 'asc' ? 'desc' : 'asc');else
    {
      setSortKey(key);
      setDirection('desc');
    }
  };

  return (
    <>
      <PageHeader
        title="Vendors"
        subtitle={`${vendors.filter((v) => v.status === 'active').length} live stores across Osun State · ${vendors.filter((v) => v.status === 'suspended').length} suspended`} />
      

      <TableShell>
        <FilterBar>
          <SearchInput
            className="w-[300px]"
            value={query}
            onChange={(value) => {
              setQuery(value);
              setPage(1);
            }}
            placeholder="Store, owner, phone or CAC number…" />
          
          <Select
            className="w-[160px]"
            label="Status"
            value={status}
            onChange={setStatus}
            options={[
            { value: 'all', label: 'Any status' },
            { value: 'active', label: 'Active' },
            { value: 'pending', label: 'Pending' },
            { value: 'suspended', label: 'Suspended' }]
            } />
          
          <Select
            className="w-[160px]"
            label="Tier"
            value={tier}
            onChange={setTier}
            options={[
            { value: 'all', label: 'Any tier' },
            { value: 'featured', label: 'Featured' },
            { value: 'premium', label: 'Premium' },
            { value: 'standard', label: 'Standard' }]
            } />
          
          <Select
            className="w-[170px]"
            label="Zone"
            value={zone}
            onChange={setZone}
            options={[
            { value: 'all', label: 'All zones' },
            ...zones.map((name) => ({ value: name, label: name }))]
            } />
          
        </FilterBar>

        {paged.length === 0 ?
        <EmptyState
          icon={BuildingIcon}
          title="No vendors match"
          body="Clear a filter or search the owner’s phone number." /> :


        <Table>
            <THead>
              <TH>Store</TH>
              <TH>Owner</TH>
              <TH>Zone</TH>
              <TH>Tier</TH>
              <TH
              align="right"
              sortable
              active={sortKey === 'orders30d'}
              direction={direction}
              onSort={() => toggleSort('orders30d')}>
              
                Orders 30d
              </TH>
              <TH
              align="right"
              sortable
              active={sortKey === 'gmv30d'}
              direction={direction}
              onSort={() => toggleSort('gmv30d')}>
              
                GMV 30d
              </TH>
              <TH align="right">Rating</TH>
              <TH>Joined</TH>
              <TH>Status</TH>
            </THead>
            <TBody>
              {paged.map((vendor) =>
            <TR key={vendor.id} onClick={() => navigate(`/vendors/${vendor.id}`)}>
                  <TD>
                    <p className="font-medium text-ink">{vendor.name}</p>
                    <p className="tabular text-xs text-ink-faint">{vendor.cacNumber}</p>
                  </TD>
                  <TD>
                    <p>{vendor.owner}</p>
                    <p className="text-xs text-ink-faint">{vendor.phone}</p>
                  </TD>
                  <TD>{vendor.zone}</TD>
                  <TD>
                    <Badge tone={vendor.tier === 'featured' ? 'info' : 'neutral'}>
                      {titleCase(vendor.tier)}
                    </Badge>
                  </TD>
                  <TD align="right" className="tabular">
                    {vendor.orders30d}
                  </TD>
                  <TD align="right" className="tabular font-medium text-ink">
                    {naira(vendor.gmv30d, { compact: true })}
                  </TD>
                  <TD align="right" className="tabular">
                    {vendor.rating ? vendor.rating.toFixed(1) : '—'}
                  </TD>
                  <TD className="text-sm">{dayMonth(vendor.joinedAt)}</TD>
                  <TD>
                    <StatusBadge status={vendor.status} />
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
            noun="vendors" />
          
        </TableFoot>
      </TableShell>
    </>);

}