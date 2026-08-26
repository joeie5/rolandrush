import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { BanknoteIcon, CheckIcon, FlagIcon, XIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import {
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
  TableFoot,
  TableShell } from
'../../components/ui/Table';
import { Badge, TierBadge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState, Pagination } from '../../components/ui/Pagination';
import { DecisionDialog, useDecision } from '../../components/ui/DecisionDialog';
import { ago, naira, shortDateTime } from '../../utils/format';
import { TIER_META } from '../../utils/tiers';
import type { Withdrawal } from '../../types';

const PAGE_SIZE = 8;

type View = 'attention' | 'flagged' | 'auto' | 'decided' | 'all';

const VIEWS: {id: View;label: string;}[] = [
{ id: 'attention', label: 'Needs review' },
{ id: 'flagged', label: 'Flagged' },
{ id: 'auto', label: 'Auto-approved' },
{ id: 'decided', label: 'Decided' },
{ id: 'all', label: 'All' }];


export function WithdrawalQueue() {
  const { withdrawals, decideWithdrawal } = useAdmin();
  const navigate = useNavigate();
  const decision = useDecision();

  const [view, setView] = React.useState<View>('attention');
  const [query, setQuery] = React.useState('');
  const [who, setWho] = React.useState('all');
  const [band, setBand] = React.useState('all');
  const [sortKey, setSortKey] = React.useState<'amount' | 'requestedAt'>(
    'requestedAt'
  );
  const [direction, setDirection] = React.useState<'asc' | 'desc'>('asc');
  const [page, setPage] = React.useState(1);
  const [selected, setSelected] = React.useState<string[]>([]);

  const counts = React.useMemo(
    () => ({
      attention: withdrawals.filter((w) => w.status === 'pending').length,
      flagged: withdrawals.filter((w) => w.status === 'pending' && w.tier === 'urgent').
      length,
      auto: withdrawals.filter((w) => w.status === 'auto_approved').length,
      decided: withdrawals.filter(
        (w) => w.status === 'approved' || w.status === 'rejected'
      ).length,
      all: withdrawals.length
    }),
    [withdrawals]
  );

  const rows = React.useMemo(() => {
    const matchesView = (item: Withdrawal) => {
      if (view === 'attention') return item.status === 'pending';
      if (view === 'flagged') return item.status === 'pending' && item.tier === 'urgent';
      if (view === 'auto') return item.status === 'auto_approved';
      if (view === 'decided')
      return item.status === 'approved' || item.status === 'rejected';
      return true;
    };
    const matchesBand = (item: Withdrawal) => {
      if (band === 'under50') return item.amount < 50000;
      if (band === 'mid') return item.amount >= 50000 && item.amount <= 250000;
      if (band === 'over250') return item.amount > 250000;
      return true;
    };
    const needle = query.trim().toLowerCase();
    return withdrawals.
    filter(
      (item) =>
      matchesView(item) &&
      matchesBand(item) && (
      who === 'all' || item.requesterType === who) && (
      !needle ||
      item.requesterName.toLowerCase().includes(needle) ||
      item.reference.toLowerCase().includes(needle) ||
      item.bank.accountNumber.includes(needle))
    ).
    sort((a, b) => {
      const value =
      sortKey === 'amount' ?
      a.amount - b.amount :
      a.requestedAt.localeCompare(b.requestedAt);
      return direction === 'asc' ? value : -value;
    });
  }, [withdrawals, view, band, who, query, sortKey, direction]);

  const paged = rows.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);
  const selectable = paged.filter((item) => item.status === 'pending');
  const selectedRows = withdrawals.filter((item) => selected.includes(item.id));
  const selectedTotal = selectedRows.reduce((sum, item) => sum + item.amount, 0);

  const toggleSort = (key: 'amount' | 'requestedAt') => {
    if (sortKey === key) {
      setDirection(direction === 'asc' ? 'desc' : 'asc');
    } else {
      setSortKey(key);
      setDirection('desc');
    }
  };

  const askApprove = (items: Withdrawal[]) => {
    const total = items.reduce((sum, item) => sum + item.amount, 0);
    decision.ask({
      title:
      items.length === 1 ?
      `Release ${naira(items[0].amount)} to ${items[0].requesterName}?` :
      `Release ${naira(total)} across ${items.length} payouts?`,
      consequence:
      'Money leaves the RolandRush float immediately and cannot be recalled.',
      facts:
      items.length === 1 ?
      [
      { label: 'Reference', value: items[0].reference },
      { label: 'Bank', value: `${items[0].bank.bankName} · ${items[0].bank.accountNumber}` },
      { label: 'Account name', value: items[0].bank.accountName },
      { label: 'Amount', value: naira(items[0].amount) }] :

      items.slice(0, 6).map((item) => ({
        label: item.requesterName,
        value: naira(item.amount)
      })),
      intent: 'approve',
      reasonRequired: false,
      confirmLabel: items.length === 1 ? 'Approve payout' : `Approve ${items.length} payouts`,
      onConfirm: (reason) => {
        items.forEach((item) => decideWithdrawal(item.id, 'approve', reason));
        setSelected([]);
      }
    });
  };

  const askReject = (item: Withdrawal) => {
    decision.ask({
      title: `Reject ${naira(item.amount)} to ${item.requesterName}?`,
      consequence:
      'The requester is notified with your reason and the funds stay in their balance.',
      facts: [
      { label: 'Reference', value: item.reference },
      { label: 'Routed because', value: item.routingReason }],

      intent: 'reject',
      reasonRequired: true,
      reasonLabel: 'Reason for rejection',
      suggestions: [
      'Bank account name does not match the verified identity.',
      'Balance does not reconcile with completed orders.',
      'Waiting on the outcome of an open dispute.'],

      confirmLabel: 'Reject payout',
      onConfirm: (reason) => {
        decideWithdrawal(item.id, 'reject', reason);
        setSelected((current) => current.filter((id) => id !== item.id));
      }
    });
  };

  return (
    <>
      <PageHeader
        title="Withdrawals"
        subtitle={`${counts.attention} payouts waiting on a decision · ${naira(
          withdrawals.
          filter((w) => w.status === 'pending').
          reduce((sum, w) => sum + w.amount, 0)
        )} held. Anything under ₦50,000 from a known account released itself.`}
        actions={
        <Link to="/withdrawals/audit">
            <Button>Approval log</Button>
          </Link>
        } />
      

      <div className="mb-4 flex items-center gap-1 border-b border-line">
        {VIEWS.map((tab) =>
        <button
          key={tab.id}
          type="button"
          onClick={() => {
            setView(tab.id);
            setPage(1);
            setSelected([]);
          }}
          className={`-mb-px flex items-center gap-1.5 border-b-2 px-3 py-2 text-base transition-colors duration-150 ease-exp ${
          view === tab.id ?
          'border-coral font-medium text-ink' :
          'border-transparent text-ink-muted hover:text-ink'}`
          }>
          
            {tab.id === 'flagged' ? <FlagIcon className="h-3.5 w-3.5 text-coral" /> : null}
            {tab.label}
            <span className="tabular text-xs text-ink-faint">{counts[tab.id]}</span>
          </button>
        )}
      </div>

      <TableShell>
        <FilterBar>
          <SearchInput
            className="w-[300px]"
            value={query}
            onChange={(value) => {
              setQuery(value);
              setPage(1);
            }}
            placeholder="Reference, name or account number…" />
          
          <Select
            className="w-[150px]"
            label="Requester type"
            value={who}
            onChange={(value) => {
              setWho(value);
              setPage(1);
            }}
            options={[
            { value: 'all', label: 'All requesters' },
            { value: 'vendor', label: 'Vendors' },
            { value: 'rider', label: 'Riders' }]
            } />
          
          <Select
            className="w-[190px]"
            label="Amount range"
            value={band}
            onChange={(value) => {
              setBand(value);
              setPage(1);
            }}
            options={[
            { value: 'all', label: 'Any amount' },
            { value: 'under50', label: 'Under ₦50,000' },
            { value: 'mid', label: '₦50,000 – ₦250,000' },
            { value: 'over250', label: 'Over ₦250,000' }]
            } />
          
          {selected.length ?
          <div className="ml-auto flex items-center gap-2">
              <span className="tabular text-sm text-ink-muted">
                {selected.length} selected · {naira(selectedTotal)}
              </span>
              <Button
              size="sm"
              variant="approve"
              icon={CheckIcon}
              onClick={() => askApprove(selectedRows)}>
              
                Approve selected
              </Button>
              <Button size="sm" variant="ghost" onClick={() => setSelected([])}>
                Clear
              </Button>
            </div> :
          null}
        </FilterBar>

        {paged.length === 0 ?
        <EmptyState
          icon={BanknoteIcon}
          title="Queue is clear"
          body="No withdrawals match this view. Auto-approved payouts are still visible under the Auto-approved tab." /> :


        <Table>
            <THead>
              <TH width="36px">
                <input
                type="checkbox"
                aria-label="Select all pending on this page"
                className="h-3.5 w-3.5 rounded border-line-strong accent-coral"
                disabled={selectable.length === 0}
                checked={
                selectable.length > 0 &&
                selectable.every((item) => selected.includes(item.id))
                }
                onChange={(event) =>
                setSelected(
                  event.target.checked ? selectable.map((item) => item.id) : []
                )
                } />
              
              </TH>
              <TH>Requester</TH>
              <TH>Routing</TH>
              <TH
              align="right"
              sortable
              active={sortKey === 'amount'}
              direction={direction}
              onSort={() => toggleSort('amount')}>
              
                Amount
              </TH>
              <TH>Bank</TH>
              <TH
              sortable
              active={sortKey === 'requestedAt'}
              direction={direction}
              onSort={() => toggleSort('requestedAt')}>
              
                Requested
              </TH>
              <TH>Status</TH>
              <TH align="right" width="150px" />
            </THead>
            <TBody>
              {paged.map((item) => {
              const pending = item.status === 'pending';
              return (
                <TR
                  key={item.id}
                  onClick={() => navigate(`/withdrawals/${item.id}`)}
                  selected={selected.includes(item.id)}
                  className={TIER_META[item.tier].rail}>
                  
                    <TD>
                      {pending ?
                    <input
                      type="checkbox"
                      aria-label={`Select ${item.reference}`}
                      className="h-3.5 w-3.5 rounded border-line-strong accent-coral"
                      checked={selected.includes(item.id)}
                      onClick={(event) => event.stopPropagation()}
                      onChange={(event) =>
                      setSelected((current) =>
                      event.target.checked ?
                      [...current, item.id] :
                      current.filter((id) => id !== item.id)
                      )
                      } /> :

                    null}
                    </TD>
                    <TD>
                      <p className="font-medium text-ink">{item.requesterName}</p>
                      <p className="text-xs text-ink-faint">
                        {item.requesterType === 'vendor' ? 'Vendor' : 'Rider'} ·{' '}
                        {item.location}
                      </p>
                    </TD>
                    <TD className="max-w-[280px]">
                      <TierBadge tier={item.tier} />
                      <p className="mt-1 truncate text-xs text-ink-muted">
                        {item.flagReason ?? item.routingReason}
                      </p>
                    </TD>
                    <TD align="right" className="tabular font-medium text-ink">
                      {naira(item.amount)}
                    </TD>
                    <TD>
                      <p className="text-sm text-ink">{item.bank.bankName}</p>
                      <p className="tabular text-xs text-ink-faint">
                        {item.bank.accountNumber}
                        {item.bank.timesUsed === 0 ?
                      <span className="ml-1 text-warn-ink">· new</span> :
                      null}
                      </p>
                    </TD>
                    <TD>
                      <p className="text-sm text-ink-soft">{shortDateTime(item.requestedAt)}</p>
                      <p className="text-xs text-ink-faint">{ago(item.requestedAt)}</p>
                    </TD>
                    <TD>
                      <Badge
                      tone={
                      item.status === 'rejected' ?
                      'urgent' :
                      item.status === 'pending' ?
                      'warn' :
                      'ok'
                      }>
                      
                        {item.status === 'auto_approved' ?
                      'Auto-approved' :
                      item.status === 'pending' ?
                      'Awaiting' :
                      item.status}
                      </Badge>
                    </TD>
                    <TD align="right">
                      {pending ?
                    <div
                      className="flex justify-end gap-1.5 opacity-0 transition-opacity duration-150 ease-exp group-hover:opacity-100 focus-within:opacity-100"
                      onClick={(event) => event.stopPropagation()}>
                      
                          <Button
                        size="sm"
                        variant="approve"
                        icon={CheckIcon}
                        onClick={() => askApprove([item])}>
                        
                            Approve
                          </Button>
                          <Button
                        size="sm"
                        variant="danger"
                        icon={XIcon}
                        onClick={() => askReject(item)}>
                        
                            Reject
                          </Button>
                        </div> :

                    <span className="text-xs text-ink-faint">
                          {item.decision?.by}
                        </span>
                    }
                    </TD>
                  </TR>);

            })}
            </TBody>
          </Table>
        }

        <TableFoot>
          <Pagination
            page={page}
            pageSize={PAGE_SIZE}
            total={rows.length}
            onPageChange={setPage}
            noun="withdrawals" />
          
        </TableFoot>
      </TableShell>

      <DecisionDialog request={decision.request} onClose={decision.close} />
    </>);

}