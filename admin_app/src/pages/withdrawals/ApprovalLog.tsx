import React from 'react';
import { Link } from 'react-router-dom';
import { FileTextIcon } from 'lucide-react';
import { useAdmin } from '../../contexts/AdminContext';
import { PageHeader } from '../../components/ui/PageHeader';
import { Panel } from '../../components/ui/Panel';
import { Button } from '../../components/ui/Button';
import { FilterBar, SearchInput, Select } from '../../components/ui/Field';
import { EmptyState } from '../../components/ui/Pagination';
import { AuditEntryList } from '../../components/AuditEntryList';

export function ApprovalLog() {
  const { audit } = useAdmin();
  const [query, setQuery] = React.useState('');
  const [source, setSource] = React.useState('all');

  const entries = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    return audit.
    filter((entry) => entry.area === 'withdrawals').
    filter((entry) =>
    source === 'all' ?
    true :
    source === 'human' ?
    !entry.automated :
    entry.automated
    ).
    filter(
      (entry) =>
      !needle ||
      entry.sentence.toLowerCase().includes(needle) ||
      entry.actor.toLowerCase().includes(needle) ||
      (entry.reason ?? '').toLowerCase().includes(needle)
    );
  }, [audit, query, source]);

  return (
    <>
      <PageHeader
        title="Approval log"
        subtitle="Every payout decision in the order it happened, written as a sentence so it answers “who did this, and why” without translation."
        actions={
        <Link to="/audit">
            <Button>Full audit log</Button>
          </Link>
        } />
      

      <Panel>
        <FilterBar>
          <SearchInput
            className="w-[340px]"
            value={query}
            onChange={setQuery}
            placeholder="Search by name, amount or reason…" />
          
          <Select
            className="w-[200px]"
            label="Decided by"
            value={source}
            onChange={setSource}
            options={[
            { value: 'all', label: 'Everyone' },
            { value: 'human', label: 'People only' },
            { value: 'auto', label: 'Automatic rules only' }]
            } />
          
          <span className="tabular ml-auto text-sm text-ink-muted">
            {entries.length} entries
          </span>
        </FilterBar>

        {entries.length === 0 ?
        <EmptyState
          icon={FileTextIcon}
          title="No matching decisions"
          body="Try a different name, amount or reason." /> :


        <AuditEntryList entries={entries} />
        }
      </Panel>
    </>);

}