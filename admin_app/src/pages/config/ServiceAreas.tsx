import React from 'react';
import { MapPinIcon, PencilIcon, PlusIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
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
import { Modal } from '../../components/ui/Modal';
import { Select, TextInput } from '../../components/ui/Field';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { naira } from '../../utils/format';
import type { ServiceZone } from '../../types';

export function ServiceAreas() {
  // real service_areas columns are just state/city/is_active — radius/
  // baseFee/vendors/riders/orders7d have no backing column yet (base fee
  // lives on delivery_fee_rules instead), so those fields stay UI-only.
  const { logAction, serviceZones: zones, feeRules, toggleServiceZone, addServiceZone, updateServiceZone } = useAdmin();
  const decision = useDecision();
  const [addOpen, setAddOpen] = React.useState(false);
  const [name, setName] = React.useState('');
  const [city, setCity] = React.useState('');
  const [radius, setRadius] = React.useState('5');
  const [baseFee, setBaseFee] = React.useState('750');

  const [editingZone, setEditingZone] = React.useState<ServiceZone | null>(null);
  const [editName, setEditName] = React.useState('');
  const [editCity, setEditCity] = React.useState('');

  const openEdit = (zone: ServiceZone) => {
    setEditingZone(zone);
    setEditName(zone.name);
    setEditCity(zone.city);
  };

  const askStatus = (zone: ServiceZone, next: ServiceZone['status']) =>
  decision.ask({
    title:
    next === 'live' ?
    `Open ${zone.name} for orders?` :
    `Pause ordering in ${zone.name}?`,
    consequence:
    next === 'live' ?
    'Customers in this zone can order immediately and vendors go visible.' :
    `Ordering stops for ${zone.vendors} vendors and ${zone.riders} riders in this zone.`,
    facts: [
    { label: 'Zone', value: `${zone.name} · ${zone.city}` },
    { label: 'Orders last 7 days', value: `${zone.orders7d}` }],

    intent: next === 'live' ? 'approve' : 'reject',
    reasonRequired: true,
    reasonLabel: 'Reason',
    suggestions:
    next === 'live' ?
    ['Enough vendors and riders onboarded to launch.'] :
    [
    'Not enough riders online to serve orders reliably.',
    'Pausing while we re-onboard vendors.'],

    confirmLabel: next === 'live' ? 'Open zone' : 'Pause zone',
    onConfirm: (reason) => {
      toggleServiceZone(zone.id, next === 'live');
      logAction({
        area: 'config',
        sentence:
        next === 'live' ?
        `opened the ${zone.name} service zone for ordering` :
        `paused ordering in the ${zone.name} service zone`,
        reason,
        outcome: next === 'live' ? 'ok' : 'warn'
      });
    }
  });

  return (
    <>
      <PageHeader
        title="Service areas"
        subtitle={`${zones.filter((z) => z.status === 'live').length} zones live across Osun State. Pausing a zone stops new orders without touching vendor or rider accounts.`}
        actions={
        <Button variant="primary" icon={PlusIcon} onClick={() => setAddOpen(true)}>
            Add zone
          </Button>
        } />
      

      <TableShell>
        <Table>
          <THead>
            <TH>Zone</TH>
            <TH>City</TH>
            <TH align="right">Vendors</TH>
            <TH align="right">Riders</TH>
            <TH align="right">Orders (7d)</TH>
            <TH align="right">Base fee</TH>
            <TH align="right">Radius</TH>
            <TH>Status</TH>
            <TH align="right" width="140px" />
          </THead>
          <TBody>
            {zones.map((zone) => {
            // service_areas has no base_fee column of its own — the real
            // value lives on delivery_fee_rules, matched here by
            // serviceAreaId so this cell isn't just a permanent 0.
            const feeRule = feeRules.find((f) => f.serviceAreaId === zone.id);
            return (
            <TR key={zone.id}>
                <TD className="font-medium text-ink">{zone.name}</TD>
                <TD>{zone.city}</TD>
                <TD align="right" className="tabular">
                  {zone.vendors}
                </TD>
                <TD align="right" className="tabular">
                  {zone.riders}
                </TD>
                <TD align="right" className="tabular">
                  {zone.orders7d.toLocaleString('en-NG')}
                </TD>
                <TD align="right" className="tabular">
                  {feeRule ? naira(feeRule.baseFee) : '—'}
                </TD>
                <TD align="right" className="tabular">
                  {zone.radiusKm} km
                </TD>
                <TD>
                  <StatusBadge status={zone.status} />
                </TD>
                <TD align="right">
                  <div className="flex justify-end gap-2">
                    <Button size="sm" variant="ghost" icon={PencilIcon} onClick={() => openEdit(zone)}>
                      Edit
                    </Button>
                    {zone.status === 'live' ?
                  <Button
                    size="sm"
                    variant="danger"
                    onClick={() => askStatus(zone, 'paused')}>

                        Pause
                      </Button> :

                  <Button
                    size="sm"
                    variant="approve"
                    onClick={() => askStatus(zone, 'live')}>

                        Open
                      </Button>
                  }
                  </div>
                </TD>
              </TR>
            );
            })}
          </TBody>
        </Table>
      </TableShell>

      <Modal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        title="Add a service zone"
        description="New zones start as planned — nothing goes live until you open it."
        footer={
        <>
            <Button variant="ghost" onClick={() => setAddOpen(false)}>
              Cancel
            </Button>
            <Button
            variant="primary"
            disabled={!name.trim() || !city.trim()}
            onClick={() => {
              addServiceZone(name.trim(), city.trim());
              setName('');
              setCity('');
              setAddOpen(false);
            }}>
            
              Create zone
            </Button>
          </>
        }>
        
        <div className="grid grid-cols-2 gap-4">
          <TextInput label="Zone name" required value={name} onChange={setName} placeholder="Ejigbo" />
          <div>
            <label className="mb-1 block text-sm font-medium text-ink">
              City<span className="ml-1 text-coral">*</span>
            </label>
            <Select
              label="City"
              value={city}
              onChange={setCity}
              options={[
              { value: '', label: 'Select a city' },
              ...['Osogbo', 'Ile-Ife', 'Ilesa', 'Ede', 'Ikirun', 'Iwo', 'Ikire', 'Gbongan', 'Ejigbo'].map(
                (option) => ({ value: option, label: option })
              )]
              } />
            
          </div>
          <TextInput
            label="Delivery radius (km)"
            value={radius}
            onChange={setRadius} />
          
          <TextInput label="Base fee" prefix="₦" value={baseFee} onChange={setBaseFee} />
        </div>
        <p className="mt-4 flex items-start gap-2 text-sm text-ink-muted">
          <MapPinIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ink-faint" />
          Zone boundaries are drawn on the rider app map. This console controls
          whether the zone accepts orders and what it charges.
        </p>
      </Modal>

      <Modal
        open={Boolean(editingZone)}
        onClose={() => setEditingZone(null)}
        title={editingZone ? `Edit ${editingZone.name}` : ''}
        description="Changes which vendors/orders count toward this zone — matching is by city."
        footer={
        <>
            <Button variant="ghost" onClick={() => setEditingZone(null)}>
              Cancel
            </Button>
            <Button
            variant="primary"
            disabled={!editName.trim() || !editCity.trim()}
            onClick={() => {
              if (!editingZone) return;
              updateServiceZone(editingZone.id, editName.trim(), editCity.trim());
              setEditingZone(null);
            }}>

              Save changes
            </Button>
          </>
        }>

        <div className="grid grid-cols-2 gap-4">
          <TextInput label="Zone name" required value={editName} onChange={setEditName} placeholder="Ejigbo" />
          <div>
            <label className="mb-1 block text-sm font-medium text-ink">
              City<span className="ml-1 text-coral">*</span>
            </label>
            <Select
              label="City"
              value={editCity}
              onChange={setEditCity}
              options={[
              { value: '', label: 'Select a city' },
              ...['Osogbo', 'Ile-Ife', 'Ilesa', 'Ede', 'Ikirun', 'Iwo', 'Ikire', 'Gbongan', 'Ejigbo'].map(
                (option) => ({ value: option, label: option })
              )]
              } />

          </div>
        </div>
      </Modal>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}