import React from 'react';
import { FileTextIcon } from 'lucide-react';
import { useAdmin } from '../contexts/AdminContext';
import { PageHeader } from '../components/ui/PageHeader';
import { Panel } from '../components/ui/Panel';
import { FilterBar, SearchInput, Select } from '../components/ui/Field';
import { EmptyState } from '../components/ui/Pagination';
import { AuditEntryList } from '../components/AuditEntryList';
import { Button } from '../components/ui/Button';
import type { AuditArea } from '../types';

const AREAS: {value: string;label: string;}[] = [
{ value: 'all', label: 'All areas' },
{ value: 'withdrawals', label: 'Withdrawals' },
{ value: 'orders', label: 'Orders & refunds' },
{ value: 'verification', label: 'Verification' },
{ value: 'accounts', label: 'Accounts' },
{ value: 'moderation', label: 'Moderation' },
{ value: 'config', label: 'Configuration' },
{ value: 'team', label: 'Admin team' }];


export function AuditLog() {
  const { audit } = useAdmin();
  const [query, setQuery] = React.useState('');
  const [area, setArea] = React.useState('all');
  const [source, setSource] = React.useState('all');
  const [actor, setActor] = React.useState('all');

  const actors = React.useMemo(
    () => Array.from(new Set(audit.filter((e) => !e.automated).map((e) => e.actor))),
    [audit]
  );

  const entries = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    return audit.
    filter((entry) => area === 'all' || entry.area === area as AuditArea).
    filter((entry) =>
    source === 'all' ? true : source === 'human' ? !entry.automated : entry.automated
    ).
    filter((entry) => actor === 'all' || entry.actor === actor).
    filter(
      (entry) =>
      !needle ||
      entry.sentence.toLowerCase().includes(needle) ||
      entry.actor.toLowerCase().includes(needle) ||
      (entry.reason ?? '').toLowerCase().includes(needle)
    );
  }, [audit, area, source, actor, query]);

  const manual = entries.filter((entry) => !entry.automated).length;

  return (
    <>
      <PageHeader
        title="Audit log"
        subtitle="Everything anyone — person or rule — has done across the platform. This is the record you reach for when accountability matters."
        actions={<Button>Export CSV</Button>} />
      

      <Panel>
        <FilterBar>
          <SearchInput
            className="w-[320px]"
            value={query}
            onChange={setQuery}
            placeholder="Search actions, names or reasons…" />
          
          <Select
            className="w-[190px]"
            label="Area"
            value={area}
            onChange={setArea}
            options={AREAS} />
          
          <Select
            className="w-[190px]"
            label="Actor"
            value={actor}
            onChange={setActor}
            options={[
            { value: 'all', label: 'Anyone' },
            ...actors.map((name) => ({ value: name, label: name }))]
            } />
          
          <Select
            className="w-[200px]"
            label="Source"
            value={source}
            onChange={setSource}
            options={[
            { value: 'all', label: 'People and rules' },
            { value: 'human', label: 'People only' },
            { value: 'auto', label: 'Automatic rules only' }]
            } />
          
          <span className="tabular ml-auto text-sm text-ink-muted">
            {entries.length} entries · {manual} by a person
          </span>
        </FilterBar>

        {entries.length === 0 ?
        <EmptyState
          icon={FileTextIcon}
          title="Nothing matches those filters"
          body="Widen the area or clear the search to see more history." /> :


        <AuditEntryList entries={entries} showArea />
        }
      </Panel>
    </>);

}