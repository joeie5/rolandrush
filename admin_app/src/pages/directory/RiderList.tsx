import React from 'react';
import { useNavigate } from 'react-router-dom';
import { BikeIcon } from 'lucide-react';
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
import { Dot, StatusBadge } from '../../components/ui/Badge';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState, Pagination } from '../../components/ui/Pagination';
import { dayMonth, titleCase } from '../../utils/format';

const PAGE_SIZE = 10;

export function RiderList() {
  const { riders } = useAdmin();
  const navigate = useNavigate();
  const [query, setQuery] = React.useState('');
  const [status, setStatus] = React.useState('all');
  const [presence, setPresence] = React.useState('all');
  const [zone, setZone] = React.useState('all');
  const [page, setPage] = React.useState(1);

  const zones = Array.from(new Set(riders.map((rider) => rider.zone)));

  const rows = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    return riders.
    filter((rider) => status === 'all' || rider.status === status).
    filter((rider) =>
    presence === 'all' ?
    true :
    presence === 'online' ?
    rider.online :
    !rider.online
    ).
    filter((rider) => zone === 'all' || rider.zone === zone).
    filter(
      (rider) =>
      !needle ||
      rider.name.toLowerCase().includes(needle) ||
      rider.phone.includes(needle) ||
      rider.plateNumber.toLowerCase().includes(needle)
    ).
    sort((a, b) => b.deliveries30d - a.deliveries30d);
  }, [riders, query, status, presence, zone]);

  const paged = rows.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <>
      <PageHeader
        title="Riders"
        subtitle={`${riders.filter((r) => r.online).length} online now · ${riders.filter((r) => r.status === 'active').length} active riders · ${riders.filter((r) => r.status === 'suspended').length} suspended`} />
      

      <TableShell>
        <FilterBar>
          <SearchInput
            className="w-[280px]"
            value={query}
            onChange={(value) => {
              setQuery(value);
              setPage(1);
            }}
            placeholder="Name, phone or plate number…" />
          
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
            label="Presence"
            value={presence}
            onChange={setPresence}
            options={[
            { value: 'all', label: 'Online & offline' },
            { value: 'online', label: 'Online only' },
            { value: 'offline', label: 'Offline only' }]
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
        <EmptyState icon={BikeIcon} title="No riders match" /> :

        <Table>
            <THead>
              <TH>Rider</TH>
              <TH>Zone</TH>
              <TH>Vehicle</TH>
              <TH align="right">Deliveries 30d</TH>
              <TH align="right">Acceptance</TH>
              <TH align="right">Rating</TH>
              <TH>Joined</TH>
              <TH>Presence</TH>
              <TH>Status</TH>
            </THead>
            <TBody>
              {paged.map((rider) =>
            <TR key={rider.id} onClick={() => navigate(`/riders/${rider.id}`)}>
                  <TD>
                    <p className="font-medium text-ink">{rider.name}</p>
                    <p className="text-xs text-ink-faint">{rider.phone}</p>
                  </TD>
                  <TD>{rider.zone}</TD>
                  <TD>
                    <p>{titleCase(rider.vehicle)}</p>
                    <p className="tabular text-xs text-ink-faint">{rider.plateNumber}</p>
                  </TD>
                  <TD align="right" className="tabular">
                    {rider.deliveries30d}
                  </TD>
                  <TD align="right" className="tabular">
                    {rider.acceptanceRate ?
                `${Math.round(rider.acceptanceRate * 100)}%` :
                '—'}
                  </TD>
                  <TD align="right" className="tabular">
                    {rider.rating ? rider.rating.toFixed(1) : '—'}
                  </TD>
                  <TD className="text-sm">{dayMonth(rider.joinedAt)}</TD>
                  <TD>
                    <span className="inline-flex items-center gap-1.5 text-sm">
                      <Dot tone={rider.online ? 'ok' : 'neutral'} />
                      {rider.online ? 'Online' : 'Offline'}
                    </span>
                  </TD>
                  <TD>
                    <StatusBadge status={rider.status} />
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
            noun="riders" />
          
        </TableFoot>
      </TableShell>
    </>);

}