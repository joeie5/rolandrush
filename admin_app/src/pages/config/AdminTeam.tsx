import React from 'react';
import { UserPlusIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { ROLE_PERMISSIONS } from '../../data/config';
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
import { Badge, StatusBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { Select, TextInput } from '../../components/ui/Field';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { ago } from '../../utils/format';
import type { AdminRole, AdminUser } from '../../types';

export function AdminTeam() {
  const { logAction, currentAdmin, adminTeam: team, setAdminActive, inviteAdmin } = useAdmin();
  const decision = useDecision();
  const [inviteOpen, setInviteOpen] = React.useState(false);
  const [email, setEmail] = React.useState('');
  const [role, setRole] = React.useState<AdminRole>('Support Agent');

  const askDisable = (member: AdminUser) =>
  decision.ask({
    title:
    member.status === 'disabled' ?
    `Restore access for ${member.name}?` :
    `Remove ${member.name}’s access?`,
    consequence:
    member.status === 'disabled' ?
    'They can sign in again with their existing password and 2FA.' :
    'They are signed out of every session immediately. Their past actions stay on the audit log.',
    facts: [
    { label: 'Role', value: member.role },
    { label: 'Actions in last 30 days', value: `${member.actions30d}` }],

    intent: member.status === 'disabled' ? 'approve' : 'reject',
    reasonRequired: true,
    reasonLabel: 'Reason',
    confirmLabel:
    member.status === 'disabled' ? 'Restore access' : 'Remove access',
    onConfirm: (reason) => {
      const next = member.status === 'disabled' ? 'active' : 'disabled';
      setAdminActive(member.id, next === 'active');
      logAction({
        area: 'team',
        sentence:
        next === 'disabled' ?
        `removed admin access for ${member.email}` :
        `restored admin access for ${member.email}`,
        reason,
        outcome: next === 'disabled' ? 'urgent' : 'ok'
      });
    }
  });

  return (
    <>
      <PageHeader
        title="Admin team"
        subtitle="Who can get into this console and what they are allowed to approve. Payout limits are enforced by role, not by trust."
        actions={
        <Button
          variant="primary"
          icon={UserPlusIcon}
          onClick={() => setInviteOpen(true)}>
          
            Invite team member
          </Button>
        } />
      

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 xl:col-span-7">
          <TableShell>
            <Table>
              <THead>
                <TH>Name</TH>
                <TH>Role</TH>
                <TH align="right">Actions (30d)</TH>
                <TH>Last active</TH>
                <TH>Status</TH>
                <TH align="right" width="120px" />
              </THead>
              <TBody>
                {team.map((member) =>
                <TR key={member.id}>
                    <TD>
                      <p className="font-medium text-ink">{member.name}</p>
                      <p className="text-xs text-ink-faint">{member.email}</p>
                    </TD>
                    <TD>
                      <Badge tone={member.role === 'Founder' ? 'info' : 'neutral'}>
                        {member.role}
                      </Badge>
                    </TD>
                    <TD align="right" className="tabular">
                      {member.actions30d}
                    </TD>
                    <TD className="text-sm">{ago(member.lastActiveAt)}</TD>
                    <TD>
                      <StatusBadge status={member.status} />
                    </TD>
                    <TD align="right">
                      {member.id === currentAdmin.id ?
                    <span className="text-xs text-ink-faint">You</span> :

                    <Button
                      size="sm"
                      variant={member.status === 'disabled' ? 'approve' : 'danger'}
                      onClick={() => askDisable(member)}>
                      
                          {member.status === 'disabled' ? 'Restore' : 'Remove'}
                        </Button>
                    }
                    </TD>
                  </TR>
                )}
              </TBody>
            </Table>
          </TableShell>
        </div>

        <aside className="col-span-12 xl:col-span-5">
          <Panel>
            <PanelHeader
              title="What each role can do"
              meta="Anything above a role’s limit routes to someone who can approve it." />
            
            <Table>
              <THead>
                <TH>Role</TH>
                <TH>Payouts</TH>
                <TH>Refunds</TH>
                <TH>Accounts</TH>
                <TH>Config</TH>
              </THead>
              <TBody>
                {ROLE_PERMISSIONS.map((row) =>
                <TR key={row.role}>
                    <TD className="font-medium text-ink">{row.role}</TD>
                    <TD className="text-sm">{row.approvePayouts}</TD>
                    <TD className="text-sm">{row.refunds}</TD>
                    <TD className="text-sm">{row.accounts}</TD>
                    <TD className="text-sm">{row.config}</TD>
                  </TR>
                )}
              </TBody>
            </Table>
          </Panel>
        </aside>
      </div>

      <Modal
        open={inviteOpen}
        onClose={() => setInviteOpen(false)}
        title="Invite a team member"
        description="They get an email invite and must set up 2FA before their first sign-in."
        footer={
        <>
            <Button variant="ghost" onClick={() => setInviteOpen(false)}>
              Cancel
            </Button>
            <Button
            variant="primary"
            disabled={!email.endsWith('@rolandrush.ng')}
            onClick={() => {
              const name = email.split('@')[0].replace(/^./, (c) => c.toUpperCase());
              inviteAdmin(name, email, role);
              setEmail('');
              setInviteOpen(false);
            }}>
            
              Send invite
            </Button>
          </>
        }>
        
        <div className="space-y-4">
          <TextInput
            label="Work email"
            required
            type="email"
            value={email}
            onChange={setEmail}
            placeholder="name@rolandrush.ng"
            hint="Only @rolandrush.ng addresses can be invited." />
          
          <div>
            <label className="mb-1 block text-sm font-medium text-ink">
              Role<span className="ml-1 text-coral">*</span>
            </label>
            <Select
              label="Role"
              value={role}
              onChange={(value) => setRole(value as AdminRole)}
              options={[
              { value: 'Support Agent', label: 'Support Agent' },
              { value: 'Ops Lead', label: 'Ops Lead' },
              { value: 'Finance', label: 'Finance' },
              { value: 'Founder', label: 'Founder' }]
              } />
            
            <p className="mt-1 text-xs text-ink-muted">
              {ROLE_PERMISSIONS.find((item) => item.role === role)?.approvePayouts}{' '}
              on payouts ·{' '}
              {ROLE_PERMISSIONS.find((item) => item.role === role)?.refunds} on
              refunds.
            </p>
          </div>
        </div>
      </Modal>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}