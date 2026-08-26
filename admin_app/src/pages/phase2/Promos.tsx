import React from 'react';
import { PlusIcon, TagIcon } from 'lucide-react';
import { promoCodes } from '../../data/phaseTwo';
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
import { StatusBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { EmptyState } from '../../components/ui/Pagination';
import { dayMonth, naira, titleCase } from '../../utils/format';

export function Promos() {
  const active = promoCodes.filter((promo) => promo.status === 'active');

  return (
    <>
      <PageHeader
        title="Promo codes"
        phaseTwo
        subtitle={`${active.length} codes live. Discounts come out of platform margin, not vendor earnings — the cap is what limits the damage.`}
        actions={
        <Button variant="primary" icon={PlusIcon}>
            Create code
          </Button>
        } />
      

      <TableShell>
        {promoCodes.length === 0 ?
        <EmptyState icon={TagIcon} title="No promo codes yet" /> :

        <Table>
            <THead>
              <TH>Code</TH>
              <TH>Type</TH>
              <TH align="right">Value</TH>
              <TH align="right">Redemptions</TH>
              <TH align="right">Cap</TH>
              <TH align="right">Cost so far</TH>
              <TH>Expires</TH>
              <TH>Status</TH>
              <TH align="right" width="100px" />
            </THead>
            <TBody>
              {promoCodes.map((promo) => {
              const usage = promo.cap ? promo.redemptions / promo.cap : 0;
              return (
                <TR key={promo.id}>
                    <TD className="font-mono text-base font-medium text-ink">
                      {promo.code}
                    </TD>
                    <TD>{titleCase(promo.type)}</TD>
                    <TD align="right" className="tabular">
                      {promo.type === 'percent' ?
                    `${promo.value}%` :
                    promo.type === 'fixed' ?
                    naira(promo.value) :
                    'Free delivery'}
                    </TD>
                    <TD align="right">
                      <span className="tabular">{promo.redemptions.toLocaleString('en-NG')}</span>
                      <div className="mt-1 h-1 w-20 overflow-hidden rounded-full bg-line">
                        <div
                        className={`h-full rounded-full ${
                        usage > 0.9 ? 'bg-coral' : usage > 0.6 ? 'bg-warn' : 'bg-ok'}`
                        }
                        style={{ width: `${Math.min(100, usage * 100)}%` }} />
                      
                      </div>
                    </TD>
                    <TD align="right" className="tabular">
                      {promo.cap.toLocaleString('en-NG')}
                    </TD>
                    <TD align="right" className="tabular">
                      {naira(promo.redemptions * (promo.type === 'percent' ? 850 : 1000), {
                      compact: true
                    })}
                    </TD>
                    <TD className="text-sm">{dayMonth(promo.expiresAt)}</TD>
                    <TD>
                      <StatusBadge status={promo.status} />
                    </TD>
                    <TD align="right">
                      {promo.status === 'expired' ? null :
                    <Button size="sm">Edit</Button>
                    }
                    </TD>
                  </TR>);

            })}
            </TBody>
          </Table>
        }
      </TableShell>
    </>);

}