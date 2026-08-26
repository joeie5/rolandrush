import React from 'react';
import {
  CheckIcon,
  FlagIcon,
  MessageSquareWarningIcon,
  PlayIcon,
  Trash2Icon } from
'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel, PanelHeader } from '../../components/ui/Panel';
import { Badge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Select } from '../../components/ui/Field';
import { EmptyState } from '../../components/ui/Pagination';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { TierLegend } from '../../components/TierLegend';
import { ago, shortDateTime, titleCase } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';
import type { ModerationItem } from '../../types';

export function ModerationQueue({
  only,
  title,
  subtitle,
  phaseTwo





}: {only?: ModerationItem['kind'];title?: string;subtitle?: string;phaseTwo?: boolean;}) {
  const { moderation, decideModeration } = useAdmin();
  const decision = useDecision();
  const [kind, setKind] = React.useState<string>(only ?? 'all');
  const [view, setView] = React.useState<'pending' | 'resolved'>('pending');

  const scoped = moderation.filter((item) => only ? item.kind === only : true);
  const rows = scoped.
  filter((item) => kind === 'all' ? true : item.kind === kind).
  filter((item) =>
  view === 'pending' ? item.status === 'pending' : item.status !== 'pending'
  ).
  sort((a, b) =>
  a.tier === b.tier ?
  b.reportCount - a.reportCount :
  a.tier === 'urgent' ?
  -1 :
  1
  );

  const pendingCount = scoped.filter((item) => item.status === 'pending').length;
  const autoRemoved = scoped.filter((item) => item.status === 'auto_removed').length;

  const askRemove = (item: ModerationItem) =>
  decision.ask({
    title: `Remove this ${titleCase(item.kind).toLowerCase()}?`,
    consequence:
    'The content disappears from every app immediately and the author is notified.',
    facts: [
    { label: 'Author', value: item.author },
    { label: 'Reports', value: `${item.reportCount} · ${item.reportedBy}` },
    { label: 'Reported for', value: item.reason }],

    intent: 'reject',
    reasonRequired: true,
    reasonLabel: 'Reason for removal',
    suggestions: [
    'Misleading pricing that does not exist on the menu.',
    'Abusive language directed at a named individual.',
    'Hygiene concern — asked the vendor to re-shoot.'],

    confirmLabel: 'Remove content',
    onConfirm: (reason) => decideModeration(item.id, 'remove', reason)
  });

  const askDismiss = (item: ModerationItem) =>
  decision.ask({
    title: `Dismiss ${item.reportCount} report${item.reportCount === 1 ? '' : 's'}?`,
    consequence:
    'The content stays live and the reporters are told no action was taken.',
    facts: [
    { label: 'Author', value: item.author },
    { label: 'Reported for', value: item.reason }],

    intent: 'approve',
    reasonRequired: true,
    reasonLabel: 'Why no action is needed',
    suggestions: [
    'Reports came from a single competing vendor’s accounts.',
    'Content is within guidelines — complaint is about taste, not policy.',
    'Verified order, criticism is legitimate feedback.'],

    confirmLabel: 'Dismiss reports',
    onConfirm: (reason) => decideModeration(item.id, 'dismiss', reason)
  });

  return (
    <>
      <PageHeader
        title={title ?? 'Moderation'}
        phaseTwo={phaseTwo}
        subtitle={
        subtitle ??
        `${pendingCount} reported items need a call. ${autoRemoved} were removed automatically once they crossed the report threshold.`
        } />
      

      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-12 xl:col-span-9">
          <Panel>
            <div className="flex flex-wrap items-center gap-2 border-b border-line px-3 py-2.5">
              <div className="flex items-center gap-1 rounded-md border border-line-strong bg-canvas p-0.5">
                {(['pending', 'resolved'] as const).map((option) =>
                <button
                  key={option}
                  type="button"
                  onClick={() => setView(option)}
                  className={`rounded px-2.5 py-1 text-sm transition-colors duration-150 ease-exp ${
                  view === option ?
                  'bg-surface font-medium text-ink shadow-card' :
                  'text-ink-muted hover:text-ink'}`
                  }>
                  
                    {option === 'pending' ? 'Needs a call' : 'Already resolved'}
                  </button>
                )}
              </div>
              {only ? null :
              <Select
                className="w-[190px]"
                label="Content type"
                value={kind}
                onChange={setKind}
                options={[
                { value: 'all', label: 'All content' },
                { value: 'feed_video', label: 'Feed videos' },
                { value: 'review', label: 'Reviews' },
                { value: 'profile', label: 'Profiles' }]
                } />

              }
              <span className="tabular ml-auto text-sm text-ink-muted">
                {rows.length} items
              </span>
            </div>

            {rows.length === 0 ?
            <EmptyState
              icon={MessageSquareWarningIcon}
              title={view === 'pending' ? 'Nothing to moderate' : 'Nothing resolved yet'}
              body={
              view === 'pending' ?
              'Reported content will appear here. Items past the report threshold are removed automatically.' :
              undefined
              } /> :


            <ul className="divide-y divide-line">
                {rows.map((item) =>
              <li
                key={item.id}
                className={`flex gap-4 px-4 py-3.5 ${TIER_META[item.tier].rail}`}>
                
                    {item.thumbnail ?
                <div className="relative h-24 w-16 shrink-0 overflow-hidden rounded-lg border border-line">
                        <img
                    src={item.thumbnail}
                    alt={`Thumbnail of ${item.subject}`}
                    className="h-full w-full object-cover" />
                  
                        <span className="absolute inset-0 flex items-center justify-center bg-ink/25">
                          <PlayIcon className="h-4 w-4 text-white" />
                        </span>
                      </div> :

                <div className="flex h-24 w-16 shrink-0 items-center justify-center rounded-lg border border-line bg-canvas">
                        <MessageSquareWarningIcon className="h-4 w-4 text-ink-faint" />
                      </div>
                }

                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <p className="text-base font-medium text-ink">{item.subject}</p>
                        <TierBadge tier={item.tier} />
                        <Badge tone="neutral">{titleCase(item.kind)}</Badge>
                        {item.status !== 'pending' ?
                    <Badge
                      tone={
                      item.status === 'auto_removed' || item.status === 'removed' ?
                      item.status === 'removed' ?
                      'urgent' :
                      'ok' :
                      'neutral'
                      }>
                      
                            {titleCase(item.status)}
                          </Badge> :
                    null}
                      </div>
                      <p className="mt-1 text-base text-ink-soft">{item.excerpt}</p>
                      <p className="mt-1.5 text-sm text-ink-muted">
                        <span className="font-medium text-ink-soft">
                          {item.reportCount} report{item.reportCount === 1 ? '' : 's'}
                        </span>{' '}
                        from {item.reportedBy} — {item.reason}
                      </p>
                      <p className="mt-1 text-xs text-ink-faint">
                        By {item.author} · posted {ago(item.createdAt)} ·{' '}
                        {item.routingReason}
                      </p>
                      {item.decision ?
                  <p className="mt-1.5 border-l-2 border-line pl-2 text-sm text-ink-muted">
                          {item.decision.by} on {shortDateTime(item.decision.at)}
                          {item.decision.reason ? ` — “${item.decision.reason}”` : ''}
                        </p> :
                  null}
                    </div>

                    {item.status === 'pending' ?
                <div className="flex shrink-0 flex-col gap-1.5">
                        <Button
                    size="sm"
                    variant="danger"
                    icon={Trash2Icon}
                    onClick={() => askRemove(item)}>
                    
                          Remove
                        </Button>
                        <Button
                    size="sm"
                    variant="approve"
                    icon={CheckIcon}
                    onClick={() => askDismiss(item)}>
                    
                          Dismiss
                        </Button>
                      </div> :
                null}
                  </li>
              )}
              </ul>
            }
          </Panel>
        </div>

        <aside className="col-span-12 space-y-4 xl:col-span-3">
          <Panel>
            <PanelHeader title="How content is routed" />
            <div className="px-4 py-3">
              <TierLegend />
            </div>
          </Panel>
          <Panel>
            <PanelHeader title="Automatic rules in force" />
            <ul className="divide-y divide-line text-sm">
              {[
              '10+ reports in an hour removes the post and notifies the author.',
              'The same clip posted 6 times in a day is treated as spam.',
              'Reviews on unverified orders never reach the feed at all.',
              'Everything else waits here for a person.'].
              map((rule) =>
              <li key={rule} className="flex gap-2 px-4 py-2.5 text-ink-muted">
                  <FlagIcon className="mt-0.5 h-3 w-3 shrink-0 text-ink-faint" />
                  {rule}
                </li>
              )}
            </ul>
          </Panel>
        </aside>
      </div>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}