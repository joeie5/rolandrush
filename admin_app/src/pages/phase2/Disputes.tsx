import React from 'react';
import { Link } from 'react-router-dom';
import { ScaleIcon } from 'lucide-react';
import { disputes } from '../../data/phaseTwo';
import { PageHeader } from '../../components/ui/PageHeader';
import {
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
  TableShell } from
'../../components/ui/Table';
import { StatusBadge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState } from '../../components/ui/Pagination';
import { ago, naira, titleCase } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';

export function Disputes() {
  const [query, setQuery] = React.useState('');
  const [status, setStatus] = React.useState('all');

  const rows = disputes.
  filter((dispute) => status === 'all' || dispute.status === status).
  filter((dispute) => {
    const needle = query.trim().toLowerCase();
    return (
      !needle ||
      dispute.orderCode.toLowerCase().includes(needle) ||
      dispute.raisedBy.toLowerCase().includes(needle) ||
      dispute.category.toLowerCase().includes(needle));

  }).
  sort((a, b) => a.tier === b.tier ? 0 : a.tier === 'urgent' ? -1 : 1);

  const atRisk = rows.
  filter((dispute) => dispute.status !== 'resolved').
  reduce((sum, dispute) => sum + dispute.amountAtRisk, 0);

  return (
    <>
      <PageHeader
        title="Disputes & complaints"
        phaseTwo
        subtitle={`${disputes.filter((d) => d.status !== 'resolved').length} open, ${naira(atRisk)} of payouts held while they are decided.`} />
      

      <TableShell>
        <FilterBar>
          <SearchInput
            className="w-[300px]"
            value={query}
            onChange={setQuery}
            placeholder="Order number, name or category…" />
          
          <Select
            className="w-[180px]"
            label="Status"
            value={status}
            onChange={setStatus}
            options={[
            { value: 'all', label: 'Any status' },
            { value: 'open', label: 'Open' },
            { value: 'waiting', label: 'Waiting on a reply' },
            { value: 'resolved', label: 'Resolved' }]
            } />
          
        </FilterBar>

        {rows.length === 0 ?
        <EmptyState icon={ScaleIcon} title="No disputes match" /> :

        <Table>
            <THead>
              <TH>Order</TH>
              <TH>Raised by</TH>
              <TH>Category</TH>
              <TH>Routing</TH>
              <TH align="right">Held</TH>
              <TH>Opened</TH>
              <TH>Status</TH>
              <TH align="right" width="110px" />
            </THead>
            <TBody>
              {rows.map((dispute) =>
            <TR key={dispute.id} className={TIER_META[dispute.tier].rail}>
                  <TD>
                    <Link
                  to="/orders"
                  className="font-medium text-ink underline-offset-2 hover:underline">
                  
                      {dispute.orderCode}
                    </Link>
                  </TD>
                  <TD>
                    <p>{dispute.raisedBy}</p>
                    <p className="text-xs text-ink-faint">
                      {titleCase(dispute.party)}
                    </p>
                  </TD>
                  <TD>{dispute.category}</TD>
                  <TD className="max-w-[300px]">
                    <TierBadge tier={dispute.tier} />
                    <p className="mt-1 truncate text-xs text-ink-muted">
                      {dispute.summary}
                    </p>
                  </TD>
                  <TD align="right" className="tabular font-medium text-ink">
                    {naira(dispute.amountAtRisk)}
                  </TD>
                  <TD className="text-sm">{ago(dispute.openedAt)}</TD>
                  <TD>
                    <StatusBadge status={dispute.status} />
                  </TD>
                  <TD align="right">
                    {dispute.status === 'resolved' ? null :
                <Button size="sm">Open case</Button>
                }
                  </TD>
                </TR>
            )}
            </TBody>
          </Table>
        }
      </TableShell>
    </>);

}