import React from 'react';
import { DownloadIcon } from 'lucide-react';
import { ledger } from '../../data/phaseTwo';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import {
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
  TableShell } from
'../../components/ui/Table';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { FilterBar, Select } from '../../components/ui/Field';
import { naira, shortDateTime, titleCase } from '../../utils/format';

const TYPE_TONE: Record<string, 'ok' | 'warn' | 'urgent' | 'neutral' | 'info'> = {
  order: 'ok',
  commission: 'ok',
  ad_spend: 'info',
  payout: 'neutral',
  refund: 'urgent'
};

export function Ledger() {
  const [type, setType] = React.useState('all');
  const rows = ledger.filter((entry) => type === 'all' || entry.type === type);

  const inflow = rows.reduce((sum, entry) => sum + entry.inflow, 0);
  const outflow = rows.reduce((sum, entry) => sum + entry.outflow, 0);

  return (
    <>
      <PageHeader
        title="Transaction ledger"
        phaseTwo
        subtitle="Every naira in and out of the RolandRush float, newest first. This is the source for monthly reconciliation."
        actions={
        <>
            <Button icon={DownloadIcon}>Export month</Button>
            <Button variant="primary" icon={DownloadIcon}>
              Financial report
            </Button>
          </>
        } />
      

      <div className="mb-4 grid grid-cols-2 gap-px overflow-hidden rounded-xl border border-line bg-line lg:grid-cols-4">
        {[
        { label: 'Float balance', value: naira(4182400) },
        { label: 'In (this view)', value: naira(inflow) },
        { label: 'Out (this view)', value: naira(outflow) },
        { label: 'Net', value: naira(inflow - outflow) }].
        map((stat) =>
        <div key={stat.label} className="bg-surface px-4 py-3">
            <p className="text-xs text-ink-muted">{stat.label}</p>
            <p className="tabular mt-0.5 text-lg font-semibold text-ink">
              {stat.value}
            </p>
          </div>
        )}
      </div>

      <TableShell>
        <FilterBar>
          <Select
            className="w-[200px]"
            label="Entry type"
            value={type}
            onChange={setType}
            options={[
            { value: 'all', label: 'All entries' },
            { value: 'order', label: 'Order payments' },
            { value: 'payout', label: 'Payouts' },
            { value: 'refund', label: 'Refunds' },
            { value: 'commission', label: 'Commission' },
            { value: 'ad_spend', label: 'Ad spend' }]
            } />
          
          <span className="tabular ml-auto text-sm text-ink-muted">
            {rows.length} entries
          </span>
        </FilterBar>
        <Table>
          <THead>
            <TH>Date</TH>
            <TH>Reference</TH>
            <TH>Type</TH>
            <TH>Party</TH>
            <TH align="right">In</TH>
            <TH align="right">Out</TH>
            <TH align="right">Balance</TH>
          </THead>
          <TBody>
            {rows.map((entry) =>
            <TR key={entry.id}>
                <TD className="text-sm">{shortDateTime(entry.date)}</TD>
                <TD className="tabular font-medium text-ink">{entry.reference}</TD>
                <TD>
                  <Badge tone={TYPE_TONE[entry.type] ?? 'neutral'}>
                    {titleCase(entry.type)}
                  </Badge>
                </TD>
                <TD>{entry.party}</TD>
                <TD align="right" className="tabular text-ok-ink">
                  {entry.inflow ? naira(entry.inflow) : '—'}
                </TD>
                <TD align="right" className="tabular text-coral-ink">
                  {entry.outflow ? naira(entry.outflow) : '—'}
                </TD>
                <TD align="right" className="tabular font-medium text-ink">
                  {naira(entry.balance)}
                </TD>
              </TR>
            )}
          </TBody>
        </Table>
      </TableShell>

      <Panel className="mt-4">
        <PanelHeader
          title="Reports you can pull"
          meta="Generated from the ledger above" />
        
        <ul className="divide-y divide-line">
          {[
          { name: 'Monthly settlement summary', detail: 'Vendor payouts, commission and refunds by zone' },
          { name: 'Vendor earnings statement', detail: 'Per-vendor, per-month, ready to send' },
          { name: 'Rider earnings statement', detail: 'Per-rider, per-week' },
          { name: 'Tax export (FIRS format)', detail: 'Commission revenue and VAT' }].
          map((report) =>
          <li key={report.name} className="flex items-center gap-3 px-4 py-3">
              <div className="min-w-0 flex-1">
                <p className="text-base font-medium text-ink">{report.name}</p>
                <p className="text-sm text-ink-muted">{report.detail}</p>
              </div>
              <Button size="sm" icon={DownloadIcon}>
                CSV
              </Button>
            </li>
          )}
        </ul>
      </Panel>
    </>);

}