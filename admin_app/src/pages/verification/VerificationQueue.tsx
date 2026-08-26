import React from 'react';
import {
  CheckIcon,
  CheckCircle2Icon,
  FlagIcon,
  ShieldCheckIcon,
  XCircleIcon,
  XIcon } from
'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { Badge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { EmptyState } from '../../components/ui/Pagination';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { ago, shortDateTime } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';
import type { VerificationSubmission } from '../../types';

const COPY = {
  vendor: {
    title: 'Vendor verification',
    subtitle:
    'CAC number, registration certificate and owner ID. Clean applications in live zones verify themselves — these are the ones a rule could not clear.',
    rejectSuggestions: [
    'CAC number could not be found in the registry.',
    'Business name on the certificate does not match the application.',
    'Owner ID is unreadable — asked for a clearer photo.']

  },
  rider: {
    title: 'Rider verification',
    subtitle:
    'Driver’s licence, national ID and vehicle papers. Anything expired, mismatched or unreadable lands here.',
    rejectSuggestions: [
    'Driver’s licence has expired.',
    'Vehicle registration names a different owner.',
    'Photo of the plate is unreadable — asked for a re-upload.']

  }
};

export function VerificationQueue({ kind }: {kind: 'vendor' | 'rider';}) {
  const { vendorChecks, riderChecks, decideVerification } = useAdmin();
  const decision = useDecision();
  const submissions = kind === 'vendor' ? vendorChecks : riderChecks;
  const copy = COPY[kind];

  const pending = submissions.filter((item) => item.status === 'pending');
  const resolved = submissions.filter((item) => item.status !== 'pending');
  const [activeId, setActiveId] = React.useState<string | null>(
    pending[0]?.id ?? null
  );

  React.useEffect(() => {
    if (!activeId || !submissions.some((item) => item.id === activeId)) {
      setActiveId(pending[0]?.id ?? resolved[0]?.id ?? null);
    }
  }, [activeId, submissions, pending, resolved]);

  const active = submissions.find((item) => item.id === activeId) ?? null;

  const advance = (currentId: string) => {
    const remaining = pending.filter((item) => item.id !== currentId);
    setActiveId(remaining[0]?.id ?? null);
  };

  const askApprove = (item: VerificationSubmission) =>
  decision.ask({
    title: `Verify ${item.subjectName}?`,
    consequence:
    kind === 'vendor' ?
    'The vendor goes live immediately and can start taking orders and payouts.' :
    'The rider can start accepting deliveries and earning immediately.',
    facts: [
    { label: 'Zone', value: item.zone },
    { label: 'Submitted', value: shortDateTime(item.submittedAt) },
    { label: 'Routed because', value: item.routingReason }],

    intent: 'approve',
    reasonRequired: item.tier === 'urgent',
    reasonLabel: 'Why you are approving a flagged application',
    confirmLabel: 'Approve and go live',
    onConfirm: (reason) => {
      decideVerification(kind, item.id, 'approve', reason);
      advance(item.id);
    }
  });

  const askReject = (item: VerificationSubmission) =>
  decision.ask({
    title: `Reject ${item.subjectName}?`,
    consequence:
    'The applicant is notified with your reason and can re-submit corrected documents.',
    facts: [{ label: 'Zone', value: item.zone }],
    intent: 'reject',
    reasonRequired: true,
    reasonLabel: 'Reason for rejection',
    suggestions: copy.rejectSuggestions,
    confirmLabel: 'Reject application',
    onConfirm: (reason) => {
      decideVerification(kind, item.id, 'reject', reason);
      advance(item.id);
    }
  });

  return (
    <>
      <PageHeader
        title={copy.title}
        subtitle={copy.subtitle}
        actions={
        <span className="tabular text-sm text-ink-muted">
            {pending.length} waiting ·{' '}
            {pending.filter((item) => item.tier === 'urgent').length} flagged
          </span>
        } />
      

      <div className="grid grid-cols-12 gap-4">
        {/* Queue list — built for clearing in one sitting */}
        <div className="col-span-12 lg:col-span-4">
          <Panel className="overflow-hidden">
            <PanelHeader title="Queue" meta="Flagged first, then oldest" />
            {pending.length === 0 ?
            <EmptyState
              icon={ShieldCheckIcon}
              title="Queue cleared"
              body="Every outstanding application has a decision." /> :


            <ul className="divide-y divide-line">
                {[...pending].
              sort((a, b) =>
              a.tier === b.tier ?
              a.submittedAt.localeCompare(b.submittedAt) :
              a.tier === 'urgent' ?
              -1 :
              1
              ).
              map((item) =>
              <li key={item.id}>
                      <button
                  type="button"
                  onClick={() => setActiveId(item.id)}
                  className={`w-full px-4 py-3 text-left transition-colors duration-150 ease-exp ${
                  TIER_META[item.tier].rail} ${
                  activeId === item.id ? 'bg-canvas' : 'hover:bg-canvas'}`}>
                  
                        <div className="flex items-center gap-2">
                          <p className="min-w-0 flex-1 truncate text-base font-medium text-ink">
                            {item.subjectName}
                          </p>
                          <TierBadge tier={item.tier} withLabel={false} />
                        </div>
                        <p className="mt-0.5 truncate text-sm text-ink-muted">
                          {item.flagReason ?? item.routingReason}
                        </p>
                        <p className="mt-1 text-xs text-ink-faint">
                          {item.zone} · {ago(item.submittedAt)}
                        </p>
                      </button>
                    </li>
              )}
              </ul>
            }
            {resolved.length ?
            <div className="border-t border-line">
                <p className="px-4 pt-3 pb-1 text-2xs font-semibold uppercase tracking-wider text-ink-faint">
                  Already resolved
                </p>
                <ul className="divide-y divide-line">
                  {resolved.slice(0, 5).map((item) =>
                <li key={item.id}>
                      <button
                    type="button"
                    onClick={() => setActiveId(item.id)}
                    className="flex w-full items-center gap-2 px-4 py-2 text-left transition-colors duration-150 ease-exp hover:bg-canvas">
                    
                        <span className="min-w-0 flex-1 truncate text-base text-ink-soft">
                          {item.subjectName}
                        </span>
                        <Badge
                      tone={
                      item.status === 'rejected' ?
                      'urgent' :
                      item.status === 'auto_approved' ?
                      'ok' :
                      'ok'
                      }>
                      
                          {item.status === 'auto_approved' ? 'Auto' : item.status}
                        </Badge>
                      </button>
                    </li>
                )}
                </ul>
              </div> :
            null}
          </Panel>
        </div>

        {/* Document review */}
        <div className="col-span-12 lg:col-span-8">
          {active ?
          <Panel>
              <PanelHeader
              title={active.subjectName}
              meta={`${active.contact} · submitted ${shortDateTime(active.submittedAt)}`}
              action={
              active.status === 'pending' ?
              <>
                      <Button
                  variant="danger"
                  icon={XIcon}
                  onClick={() => askReject(active)}>
                  
                        Reject
                      </Button>
                      <Button
                  variant="approve"
                  icon={CheckIcon}
                  onClick={() => askApprove(active)}>
                  
                        Approve
                      </Button>
                    </> :

              <Badge tone={active.status === 'rejected' ? 'urgent' : 'ok'}>
                      {active.status === 'auto_approved' ?
                'Auto-approved' :
                active.status}
                    </Badge>

              } />
            

              <div className="flex flex-wrap items-center gap-2 border-b border-line px-4 py-2.5">
                <TierBadge tier={active.tier} />
                <p className="text-sm text-ink-muted">{active.routingReason}</p>
              </div>

              {active.flagReason ?
            <div className="flex items-start gap-2 border-b border-coral-border bg-coral-soft px-4 py-3">
                  <FlagIcon className="mt-0.5 h-4 w-4 shrink-0 text-coral" />
                  <p className="text-base text-coral-ink">{active.flagReason}</p>
                </div> :
            null}

              <div className="grid gap-4 px-4 py-4 md:grid-cols-2">
                {active.documents.map((document) =>
              <div
                key={document.label}
                className="overflow-hidden rounded-lg border border-line">
                
                    {document.preview ?
                <img
                  src={document.preview}
                  alt={`${document.label} submitted by ${active.subjectName}`}
                  className="h-40 w-full bg-canvas object-cover" /> :


                <div className="flex h-20 items-center bg-canvas px-3">
                        <p className="tabular text-lg font-medium text-ink">
                          {document.value}
                        </p>
                      </div>
                }
                    <div className="border-t border-line px-3 py-2.5">
                      <p className="text-2xs uppercase tracking-wider text-ink-faint">
                        {document.label}
                      </p>
                      <p className="truncate text-base text-ink">{document.value}</p>
                      <ul className="mt-2 space-y-1">
                        {document.checks.map((check) =>
                    <li
                      key={check.label}
                      className={`flex items-center gap-1.5 text-sm ${
                      check.passed ? 'text-ink-muted' : 'text-coral-ink'}`
                      }>
                      
                            {check.passed ?
                      <CheckCircle2Icon className="h-3.5 w-3.5 text-ok" /> :

                      <XCircleIcon className="h-3.5 w-3.5 text-coral" />
                      }
                            {check.label}
                          </li>
                    )}
                      </ul>
                    </div>
                  </div>
              )}
              </div>

              {active.decision ?
            <div className="border-t border-line bg-canvas px-4 py-3">
                  <p className="text-base text-ink-soft">
                    <span className="font-medium text-ink">
                      {active.decision.by}
                    </span>{' '}
                    decided this on {shortDateTime(active.decision.at)}
                    {active.decision.reason ? ` — “${active.decision.reason}”` : ''}
                  </p>
                </div> :

            <div className="flex items-center justify-between gap-3 border-t border-line bg-canvas px-4 py-3">
                  <p className="text-sm text-ink-muted">
                    Approving or rejecting moves you straight to the next application.
                  </p>
                  <div className="flex gap-2">
                    <Button
                  variant="danger"
                  icon={XIcon}
                  onClick={() => askReject(active)}>
                  
                      Reject with reason
                    </Button>
                    <Button
                  variant="approve"
                  icon={CheckIcon}
                  onClick={() => askApprove(active)}>
                  
                      Approve
                    </Button>
                  </div>
                </div>
            }
            </Panel> :

          <Panel>
              <EmptyState
              icon={ShieldCheckIcon}
              title="Nothing left to review"
              body="New applications will appear here as they come in." />
            
            </Panel>
          }
        </div>
      </div>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}