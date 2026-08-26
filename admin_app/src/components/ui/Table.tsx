import React from 'react';
import { ArrowDownIcon, ArrowUpIcon, ChevronsUpDownIcon } from 'lucide-react';
import { cn } from '../../utils/cn';

export function TableShell({
  children,
  className



}: {children: React.ReactNode;className?: string;}) {
  return (
    <div
      className={cn(
        'overflow-hidden rounded-xl border border-line bg-surface shadow-card',
        className
      )}>
      
      {children}
    </div>);

}

export function Table({ children }: {children: React.ReactNode;}) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full border-collapse text-left">{children}</table>
    </div>);

}

export function THead({ children }: {children: React.ReactNode;}) {
  return (
    <thead className="border-b border-line bg-canvas">
      <tr>{children}</tr>
    </thead>);

}

export function TH({
  children,
  className,
  align = 'left',
  sortable,
  active,
  direction,
  onSort,
  width









}: {children?: React.ReactNode;className?: string;align?: 'left' | 'right' | 'center';sortable?: boolean;active?: boolean;direction?: 'asc' | 'desc';onSort?: () => void;width?: string;}) {
  const Arrow = active ?
  direction === 'asc' ?
  ArrowUpIcon :
  ArrowDownIcon :
  ChevronsUpDownIcon;
  return (
    <th
      scope="col"
      style={width ? { width } : undefined}
      className={cn(
        'px-3 py-2 text-2xs font-semibold uppercase tracking-wider text-ink-muted',
        align === 'right' && 'text-right',
        align === 'center' && 'text-center',
        className
      )}>
      
      {sortable ?
      <button
        type="button"
        onClick={onSort}
        className={cn(
          'inline-flex items-center gap-1 rounded transition-colors duration-150 ease-exp hover:text-ink',
          active && 'text-ink',
          align === 'right' && 'flex-row-reverse'
        )}>
        
          {children}
          <Arrow className="h-3 w-3" />
        </button> :

      children
      }
    </th>);

}

export function TBody({ children }: {children: React.ReactNode;}) {
  return <tbody className="divide-y divide-line">{children}</tbody>;
}

export function TR({
  children,
  onClick,
  className,
  selected





}: {children: React.ReactNode;onClick?: () => void;className?: string;selected?: boolean;}) {
  return (
    <tr
      onClick={onClick}
      className={cn(
        'group transition-colors duration-150 ease-exp',
        onClick && 'cursor-pointer',
        selected ? 'bg-canvas' : 'hover:bg-canvas',
        className
      )}>
      
      {children}
    </tr>);

}

export function TD({
  children,
  className,
  align = 'left',
  colSpan





}: {children?: React.ReactNode;className?: string;align?: 'left' | 'right' | 'center';colSpan?: number;}) {
  return (
    <td
      colSpan={colSpan}
      className={cn(
        'px-3 py-2.5 align-middle text-base text-ink-soft',
        align === 'right' && 'text-right',
        align === 'center' && 'text-center',
        className
      )}>
      
      {children}
    </td>);

}

export function TableFoot({ children }: {children: React.ReactNode;}) {
  return (
    <div className="flex items-center justify-between gap-3 border-t border-line bg-canvas px-3 py-2">
      {children}
    </div>);

}