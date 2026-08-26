import React from 'react';
import { InfoIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
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
import { Modal } from '../../components/ui/Modal';
import { TextInput, Toggle } from '../../components/ui/Field';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { naira } from '../../utils/format';
import type { FeeRule } from '../../types';

export function DeliveryFees() {
  // maxFee/surgeMultiplier have no backing column on delivery_fee_rules —
  // shown as 0/1× (i.e. "no cap" / "no surge") since real rows never set them.
  const { logAction, feeRules: rules, toggleFeeRule, updateFeeRule } = useAdmin();
  const decision = useDecision();
  const [editing, setEditing] = React.useState<FeeRule | null>(null);
  const [base, setBase] = React.useState('');
  const [perKm, setPerKm] = React.useState('');

  const openEdit = (rule: FeeRule) => {
    setEditing(rule);
    setBase(String(rule.baseFee));
    setPerKm(String(rule.perKm));
  };

  const preview = (rule: FeeRule, km: number) =>
  Math.min(
    rule.maxFee || Infinity,
    Math.max(rule.minFee, Math.round((rule.baseFee + rule.perKm * km) * rule.surgeMultiplier))
  );

  return (
    <>
      <PageHeader
        title="Delivery fee rules"
        subtitle="What the customer pays for delivery, per zone. Changes apply to the next order placed — orders already in flight keep the fee they were quoted." />
      

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 xl:col-span-8">
          <TableShell>
            <Table>
              <THead>
                <TH>Rule</TH>
                <TH>Zone</TH>
                <TH align="right">Base</TH>
                <TH align="right">Per km</TH>
                <TH align="right">Min</TH>
                <TH align="right">Max</TH>
                <TH align="right">Surge</TH>
                <TH align="center">Active</TH>
                <TH align="right" width="90px" />
              </THead>
              <TBody>
                {rules.map((rule) =>
                <TR key={rule.id}>
                    <TD className="font-medium text-ink">{rule.name}</TD>
                    <TD>{rule.zone}</TD>
                    <TD align="right" className="tabular">
                      {naira(rule.baseFee)}
                    </TD>
                    <TD align="right" className="tabular">
                      {naira(rule.perKm)}
                    </TD>
                    <TD align="right" className="tabular">
                      {naira(rule.minFee)}
                    </TD>
                    <TD align="right" className="tabular">
                      {naira(rule.maxFee)}
                    </TD>
                    <TD align="right" className="tabular">
                      {rule.surgeMultiplier === 1 ? '—' : `${rule.surgeMultiplier}×`}
                    </TD>
                    <TD align="center">
                      <div className="flex justify-center">
                        <Toggle
                        label={`Toggle ${rule.name}`}
                        checked={rule.active}
                        onChange={(next) =>
                        decision.ask({
                          title: next ?
                          `Switch on “${rule.name}”?` :
                          `Switch off “${rule.name}”?`,
                          consequence:
                          'This changes what customers are charged on their very next order.',
                          facts: [
                          { label: 'Zone', value: rule.zone },
                          { label: 'Base fee', value: naira(rule.baseFee) }],

                          intent: next ? 'approve' : 'reject',
                          reasonRequired: true,
                          reasonLabel: 'Reason',
                          suggestions: [
                          'Heavy rain across all live zones.',
                          'Fuel price change.',
                          'Peak-hour demand outstripping riders.'],

                          confirmLabel: next ? 'Switch on' : 'Switch off',
                          onConfirm: (reason) => {
                            toggleFeeRule(rule.id, next);
                            logAction({
                              area: 'config',
                              sentence: `${next ? 'switched on' : 'switched off'} the “${rule.name}” delivery fee rule`,
                              reason,
                              outcome: 'info'
                            });
                          }
                        })
                        } />
                      
                      </div>
                    </TD>
                    <TD align="right">
                      <Button size="sm" onClick={() => openEdit(rule)}>
                        Edit
                      </Button>
                    </TD>
                  </TR>
                )}
              </TBody>
            </Table>
          </TableShell>
        </div>

        <aside className="col-span-12 space-y-4 xl:col-span-4">
          <Panel>
            <PanelHeader
              title="What a customer would pay"
              meta="Using the active rule for each zone" />
            
            <Table>
              <THead>
                <TH>Zone</TH>
                <TH align="right">2 km</TH>
                <TH align="right">5 km</TH>
                <TH align="right">9 km</TH>
              </THead>
              <TBody>
                {rules.
                filter((rule) => rule.active && rule.baseFee > 0).
                map((rule) =>
                <TR key={rule.id}>
                      <TD className="text-sm">{rule.name}</TD>
                      <TD align="right" className="tabular">
                        {naira(preview(rule, 2))}
                      </TD>
                      <TD align="right" className="tabular">
                        {naira(preview(rule, 5))}
                      </TD>
                      <TD align="right" className="tabular">
                        {naira(preview(rule, 9))}
                      </TD>
                    </TR>
                )}
              </TBody>
            </Table>
            <div className="flex items-start gap-2 border-t border-line px-4 py-3">
              <InfoIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ink-faint" />
              <p className="text-sm text-ink-muted">
                Riders are paid from the delivery fee. Dropping a base fee below
                ₦700 usually shows up as a falling acceptance rate within a day.
              </p>
            </div>
          </Panel>
        </aside>
      </div>

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={editing ? `Edit “${editing.name}”` : ''}
        description="You will be asked to confirm before this affects live pricing."
        footer={
        <>
            <Button variant="ghost" onClick={() => setEditing(null)}>
              Cancel
            </Button>
            <Button
            variant="primary"
            onClick={() => {
              if (!editing) return;
              const nextBase = Number(base) || editing.baseFee;
              const nextPerKm = Number(perKm) || editing.perKm;
              const rule = editing;
              setEditing(null);
              decision.ask({
                title: `Change “${rule.name}” pricing?`,
                consequence:
                'Customers in this zone see the new fee on their next order.',
                facts: [
                {
                  label: 'Base fee',
                  value: `${naira(rule.baseFee)} → ${naira(nextBase)}`
                },
                {
                  label: 'Per km',
                  value: `${naira(rule.perKm)} → ${naira(nextPerKm)}`
                }],

                intent: 'approve',
                reasonRequired: true,
                reasonLabel: 'Reason for the change',
                suggestions: [
                'Fuel price change and longer average trip distance.',
                'Matching a competitor’s pricing in this zone.'],

                confirmLabel: 'Apply new pricing',
                onConfirm: (reason) => {
                  updateFeeRule(rule.id, nextBase, nextPerKm);
                  logAction({
                    area: 'config',
                    sentence: `changed the ${rule.zone} base delivery fee from ${naira(
                      rule.baseFee
                    )} to ${naira(nextBase)}`,
                    reason,
                    outcome: 'info'
                  });
                }
              });
            }}>
            
              Continue
            </Button>
          </>
        }>
        
        {editing ?
        <>
            <div className="mb-4 flex items-center gap-2">
              <Badge tone="neutral">{editing.zone}</Badge>
              {editing.surgeMultiplier !== 1 ?
            <Badge tone="warn">{editing.surgeMultiplier}× surge</Badge> :
            null}
            </div>
            <div className="grid grid-cols-2 gap-4">
              <TextInput label="Base fee" prefix="₦" value={base} onChange={setBase} />
              <TextInput
              label="Per kilometre"
              prefix="₦"
              value={perKm}
              onChange={setPerKm} />
            
            </div>
            <p className="mt-3 text-sm text-ink-muted">
              A 5 km delivery would cost{' '}
              <span className="tabular font-medium text-ink">
                {naira(
                Math.min(
                  editing.maxFee || Infinity,
                  Math.max(
                    editing.minFee,
                    Math.round(
                      ((Number(base) || 0) + (Number(perKm) || 0) * 5) *
                      editing.surgeMultiplier
                    )
                  )
                )
              )}
              </span>
              .
            </p>
          </> :
        null}
      </Modal>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}