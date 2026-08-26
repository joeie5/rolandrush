import React from 'react';
import { Link } from 'react-router-dom';
import {
  ArrowRightIcon,
  BanknoteIcon,
  CheckCircle2Icon,
  ClockIcon,
  FlagIcon,
  MessageSquareWarningIcon,
  ShieldCheckIcon,
  TruckIcon } from
'lucide-react';
import { useAdmin } from '../contexts/AdminContext';
import { PageHeader } from '../components/ui/PageHeader';
import { Panel, PanelHeader } from '../components/ui/Panel';
import { Badge, TierBadge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { TierLegend } from '../components/TierLegend';
import { naira, ago, clockTime } from '../utils/format';
import { TIER_META } from '../utils/tiers';
import type { RiskTier } from '../types';

interface AttentionItem {
  id: string;
  tier: RiskTier;
  queue: string;
  title: string;
  detail: string;
  href: string;
  at: string;
}

export function Dashboard() {
  const {
    counts,
    withdrawals,
    vendorChecks,
    riderChecks,
    moderation,
    orders,
    audit,
    currentAdmin
  } = useAdmin();

  const flagged: AttentionItem[] = React.useMemo(() => {
    const items: AttentionItem[] = [];
    withdrawals.
    filter((w) => w.status === 'pending' && w.tier === 'urgent').
    forEach((w) =>
    items.push({
      id: w.id,
      tier: 'urgent',
      queue: 'Withdrawal',
      title: `${naira(w.amount)} to ${w.requesterName}`,
      detail: w.flagReason ?? w.routingReason,
      href: `/withdrawals/${w.id}`,
      at: w.requestedAt
    })
    );
    [...vendorChecks, ...riderChecks].
    filter((v) => v.status === 'pending' && v.tier === 'urgent').
    forEach((v) =>
    items.push({
      id: v.id,
      tier: 'urgent',
      queue: `${v.subjectType === 'vendor' ? 'Vendor' : 'Rider'} check`,
      title: v.subjectName,
      detail: v.flagReason ?? v.routingReason,
      href: `/verification/${v.subjectType}s`,
      at: v.submittedAt
    })
    );
    moderation.
    filter((m) => m.status === 'pending' && m.tier === 'urgent').
    forEach((m) =>
    items.push({
      id: m.id,
      tier: 'urgent',
      queue: 'Moderation',
      title: m.subject,
      detail: `${m.reportCount} reports · ${m.reason}`,
      href: '/moderation',
      at: m.createdAt
    })
    );
    orders.
    filter((o) => o.stalledMinutes && o.tier === 'urgent').
    forEach((o) =>
    items.push({
      id: o.id,
      tier: 'urgent',
      queue: 'Live order',
      title: `${o.code} — ${o.vendorName}`,
      detail: o.note ?? 'Stalled order',
      href: `/orders/${o.id}`,
      at: o.placedAt
    })
    );
    return items.sort((a, b) => a.at.localeCompare(b.at));
  }, [withdrawals, vendorChecks, riderChecks, moderation, orders]);

  const queues = [
  {
    label: 'Withdrawals',
    icon: BanknoteIcon,
    to: '/withdrawals',
    pending: counts.withdrawals,
    urgent: withdrawals.filter((w) => w.status === 'pending' && w.tier === 'urgent').
    length,
    value: naira(
      withdrawals.
      filter((w) => w.status === 'pending').
      reduce((sum, w) => sum + w.amount, 0),
      { compact: true }
    ),
    valueLabel: 'awaiting release'
  },
  {
    label: 'Vendor checks',
    icon: ShieldCheckIcon,
    to: '/verification/vendors',
    pending: counts.vendorChecks,
    urgent: vendorChecks.filter((v) => v.status === 'pending' && v.tier === 'urgent').
    length,
    value: 'CAC + ID',
    valueLabel: 'documents to read'
  },
  {
    label: 'Rider checks',
    icon: TruckIcon,
    to: '/verification/riders',
    pending: counts.riderChecks,
    urgent: riderChecks.filter((v) => v.status === 'pending' && v.tier === 'urgent').
    length,
    value: 'Licence + vehicle',
    valueLabel: 'documents to read'
  },
  {
    label: 'Moderation',
    icon: MessageSquareWarningIcon,
    to: '/moderation',
    pending: counts.moderation,
    urgent: moderation.filter((m) => m.status === 'pending' && m.tier === 'urgent').
    length,
    value: `${moderation.
    filter((m) => m.status === 'pending').
    reduce((sum, m) => sum + m.reportCount, 0)} reports`,
    valueLabel: 'from customers & vendors'
  }];


  const autoResolved = audit.filter((entry) => entry.automated).slice(0, 6);

  return (
    <>
      <PageHeader
        title={`Good morning, ${currentAdmin.name.split(' ')[0]}`}
        subtitle="Everything below either needs your decision or has already resolved itself. Start at the top."
        actions={
        <>
            <span className="inline-flex h-9 items-center gap-1.5 rounded-md border border-line bg-surface px-3 text-sm text-ink-muted">
              <ClockIcon className="h-3.5 w-3.5 text-ink-faint" />
              Last review: yesterday, 6:10pm
            </span>
            <Link to="/withdrawals">
              <Button variant="primary" iconRight={ArrowRightIcon}>
                Start review
              </Button>
            </Link>
          </>
        } />
      

      <div className="grid grid-cols-12 gap-4">
        {/* Primary: what needs a human right now */}
        <section className="col-span-12 xl:col-span-8">
          <div className="rounded-xl border border-line bg-surface shadow-card">
            <div className="flex items-stretch border-b border-line">
              <div className="flex-1 px-5 py-4">
                <p className="text-2xs font-semibold uppercase tracking-wider text-ink-faint">
                  Needs a human decision
                </p>
                <div className="mt-1 flex items-end gap-3">
                  <span className="tabular text-4xl font-semibold leading-none tracking-[-0.02em] text-ink">
                    {counts.total}
                  </span>
                  <span className="pb-1 text-base text-ink-muted">
                    items across {queues.filter((q) => q.pending > 0).length} queues
                  </span>
                </div>
              </div>
              <div className="flex w-[210px] shrink-0 flex-col justify-center border-l border-line bg-coral-soft px-5 py-4">
                <p className="flex items-center gap-1.5 text-2xs font-semibold uppercase tracking-wider text-coral-ink">
                  <FlagIcon className="h-3 w-3" /> Flagged — act now
                </p>
                <p className="tabular mt-1 text-2xl font-semibold leading-none text-coral-ink">
                  {counts.urgent}
                </p>
              </div>
            </div>

            {flagged.length ?
            <ul className="divide-y divide-line">
                {flagged.map((item) =>
              <li key={item.id}>
                    <Link
                  to={item.href}
                  className={`flex items-start gap-3 px-5 py-3 transition-colors duration-150 ease-exp hover:bg-coral-soft/50 ${TIER_META.urgent.rail}`}>
                  
                      <FlagIcon className="mt-0.5 h-4 w-4 shrink-0 text-coral" />
                      <div className="min-w-0 flex-1">
                        <div className="flex items-baseline gap-2">
                          <p className="truncate text-base font-medium text-ink">
                            {item.title}
                          </p>
                          <Badge tone="neutral">{item.queue}</Badge>
                        </div>
                        <p className="mt-0.5 text-sm text-ink-muted">{item.detail}</p>
                      </div>
                      <span className="shrink-0 text-xs text-ink-faint">
                        {ago(item.at)}
                      </span>
                    </Link>
                  </li>
              )}
              </ul> :

            <p className="px-5 py-6 text-base text-ink-muted">
                Nothing flagged. The queues below can wait for your next sitting.
              </p>
            }

            <div className="grid grid-cols-2 gap-px border-t border-line bg-line lg:grid-cols-4">
              {queues.map((queue) =>
              <Link
                key={queue.label}
                to={queue.to}
                className="group flex flex-col bg-surface px-4 py-3 transition-colors duration-150 ease-exp hover:bg-canvas">
                
                  <span className="flex items-center gap-1.5 text-sm text-ink-muted">
                    <queue.icon className="h-3.5 w-3.5 text-ink-faint" />
                    {queue.label}
                  </span>
                  <span className="tabular mt-1.5 flex items-baseline gap-1.5">
                    <span className="text-2xl font-semibold leading-none text-ink">
                      {queue.pending}
                    </span>
                    {queue.urgent > 0 ?
                  <span className="text-xs font-semibold text-coral">
                        {queue.urgent} flagged
                      </span> :

                  <span className="text-xs text-ink-faint">queued</span>
                  }
                  </span>
                  <span className="mt-auto pt-2 text-xs text-ink-faint">
                    {queue.value} {queue.valueLabel}
                  </span>
                </Link>
              )}
            </div>
          </div>
        </section>

        {/* Secondary: today's numbers + how routing works */}
        <aside className="col-span-12 space-y-4 xl:col-span-4">
          <Panel>
            <PanelHeader title="Today so far" meta="Osun State · all zones" />
            <dl className="grid grid-cols-2 gap-px bg-line">
              {[
              { label: 'Orders', value: '412', sub: '+8% vs last Tue' },
              { label: 'GMV', value: naira(4180000, { compact: true }), sub: 'settled + pending' },
              { label: 'Payouts released', value: naira(286400, { compact: true }), sub: '9 requests' },
              { label: 'Refunds issued', value: naira(5950), sub: '3 orders' },
              { label: 'Riders online', value: '38', sub: 'of 71 active' },
              { label: 'Avg delivery', value: '34 min', sub: 'target 30 min' }].
              map((stat) =>
              <div key={stat.label} className="bg-surface px-4 py-3">
                  <dt className="text-xs text-ink-muted">{stat.label}</dt>
                  <dd className="tabular mt-0.5 text-lg font-semibold text-ink">
                    {stat.value}
                  </dd>
                  <p className="text-2xs text-ink-faint">{stat.sub}</p>
                </div>
              )}
            </dl>
          </Panel>

          <Panel>
            <PanelHeader title="How items get here" />
            <div className="px-4 py-3">
              <TierLegend />
            </div>
          </Panel>
        </aside>

        {/* Tertiary: what already resolved itself */}
        <section className="col-span-12">
          <Panel>
            <PanelHeader
              title="Resolved automatically since your last review"
              meta="No action needed — shown so nothing is invisible."
              action={
              <Link to="/audit">
                  <Button size="sm" iconRight={ArrowRightIcon}>
                    Full audit log
                  </Button>
                </Link>
              } />
            
            <ul className="divide-y divide-line">
              {autoResolved.map((entry) =>
              <li
                key={entry.id}
                className="flex items-baseline gap-3 px-4 py-2.5 text-base">
                
                  <CheckCircle2Icon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ok" />
                  <p className="min-w-0 flex-1 text-ink-soft">
                    <span className="font-medium text-ink">Automatic rule</span>{' '}
                    {entry.sentence}
                    {entry.reason ?
                  <span className="text-ink-muted"> — {entry.reason}</span> :
                  null}
                  </p>
                  <TierBadge tier="auto" />
                  <span className="tabular shrink-0 text-xs text-ink-faint">
                    {clockTime(entry.at)}
                  </span>
                </li>
              )}
            </ul>
          </Panel>
        </section>
      </div>
    </>);

}