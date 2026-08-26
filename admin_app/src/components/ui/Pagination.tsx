import React from 'react';
import { ChevronLeftIcon, ChevronRightIcon } from 'lucide-react';
import { Button } from './Button';

export function Pagination({
  page,
  pageSize,
  total,
  onPageChange,
  noun = 'items'






}: {page: number;pageSize: number;total: number;onPageChange: (page: number) => void;noun?: string;}) {
  const pages = Math.max(1, Math.ceil(total / pageSize));
  const from = total === 0 ? 0 : (page - 1) * pageSize + 1;
  const to = Math.min(total, page * pageSize);

  return (
    <>
      <p className="tabular text-xs text-ink-muted">
        {from}–{to} of {total} {noun}
      </p>
      <div className="flex items-center gap-1.5">
        <Button
          size="sm"
          icon={ChevronLeftIcon}
          disabled={page <= 1}
          onClick={() => onPageChange(page - 1)}>
          
          Prev
        </Button>
        <span className="tabular px-1 text-xs text-ink-muted">
          Page {page} / {pages}
        </span>
        <Button
          size="sm"
          iconRight={ChevronRightIcon}
          disabled={page >= pages}
          onClick={() => onPageChange(page + 1)}>
          
          Next
        </Button>
      </div>
    </>);

}

export function EmptyState({
  icon: Icon,
  title,
  body,
  action





}: {icon: React.ComponentType<{className?: string;}>;title: string;body?: string;action?: React.ReactNode;}) {
  return (
    <div className="flex flex-col items-center justify-center px-6 py-14 text-center">
      <span className="mb-3 inline-flex h-9 w-9 items-center justify-center rounded-lg border border-line bg-canvas text-ink-faint">
        <Icon className="h-4 w-4" />
      </span>
      <p className="text-md font-medium text-ink">{title}</p>
      {body ? <p className="mt-1 max-w-sm text-base text-ink-muted">{body}</p> : null}
      {action ? <div className="mt-4">{action}</div> : null}
    </div>);

}