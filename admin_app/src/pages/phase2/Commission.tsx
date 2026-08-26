import React from 'react';
import { InfoIcon } from 'lucide-react';
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
import { naira } from '../../utils/format';

const COMMISSION = [
{ tier: 'Standard', rate: 0.15, vendors: 128, note: 'Default for every new vendor' },
{ tier: 'Premium', rate: 0.13, vendors: 46, note: '200+ orders a month' },
{ tier: 'Featured', rate: 0.12, vendors: 16, note: 'Negotiated, founder approval only' }];


const OTHER_FEES = [
{ name: 'Customer service fee', value: '₦150 – ₦350', basis: 'Scales with basket size' },
{ name: 'Rider share of delivery fee', value: '85%', basis: 'Platform keeps 15%' },
{ name: 'Cash-order handling', value: '₦100', basis: 'Charged to the vendor' },
{ name: 'Payout fee', value: '₦50', basis: 'Per transfer, absorbed by platform' }];


export function Commission() {
  return (
    <>
      <PageHeader
        title="Commission & fees"
        phaseTwo
        subtitle="What RolandRush takes on each order. Changing a rate needs a written reason and only applies to orders placed after the change."
        actions={<Button variant="primary">Propose a rate change</Button>} />
      

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 xl:col-span-7">
          <TableShell>
            <Table>
              <THead>
                <TH>Vendor tier</TH>
                <TH align="right">Commission</TH>
                <TH align="right">Vendors</TH>
                <TH>Applies to</TH>
                <TH align="right">Revenue per ₦10,000 order</TH>
                <TH align="right" width="90px" />
              </THead>
              <TBody>
                {COMMISSION.map((row) =>
                <TR key={row.tier}>
                    <TD>
                      <Badge tone={row.tier === 'Featured' ? 'info' : 'neutral'}>
                        {row.tier}
                      </Badge>
                    </TD>
                    <TD align="right" className="tabular font-medium text-ink">
                      {Math.round(row.rate * 100)}%
                    </TD>
                    <TD align="right" className="tabular">
                      {row.vendors}
                    </TD>
                    <TD className="text-sm">{row.note}</TD>
                    <TD align="right" className="tabular">
                      {naira(10000 * row.rate)}
                    </TD>
                    <TD align="right">
                      <Button size="sm">Edit</Button>
                    </TD>
                  </TR>
                )}
              </TBody>
            </Table>
          </TableShell>
        </div>

        <aside className="col-span-12 space-y-4 xl:col-span-5">
          <Panel>
            <PanelHeader title="Other fees in force" />
            <Table>
              <THead>
                <TH>Fee</TH>
                <TH align="right">Amount</TH>
                <TH>Basis</TH>
              </THead>
              <TBody>
                {OTHER_FEES.map((fee) =>
                <TR key={fee.name}>
                    <TD className="font-medium text-ink">{fee.name}</TD>
                    <TD align="right" className="tabular">
                      {fee.value}
                    </TD>
                    <TD className="text-sm">{fee.basis}</TD>
                  </TR>
                )}
              </TBody>
            </Table>
            <div className="flex items-start gap-2 border-t border-line px-4 py-3">
              <InfoIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ink-faint" />
              <p className="text-sm text-ink-muted">
                Commission is taken from the order subtotal only — never from the
                delivery fee, which belongs to the rider.
              </p>
            </div>
          </Panel>
        </aside>
      </div>
    </>);

}