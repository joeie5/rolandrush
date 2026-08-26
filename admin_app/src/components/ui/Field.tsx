import React from 'react';
import { ChevronDownIcon, SearchIcon } from 'lucide-react';
import { cn } from '../../utils/cn';

const CONTROL =
'h-9 w-full rounded-md border border-line-strong bg-surface px-3 text-base text-ink placeholder:text-ink-faint transition-colors duration-150 ease-exp hover:border-ink-faint focus:border-ink focus:outline-none focus:ring-0';

export function SearchInput({
  value,
  onChange,
  placeholder = 'Search…',
  className,
  label






}: {value: string;onChange: (value: string) => void;placeholder?: string;className?: string;label?: string;}) {
  return (
    <div className={cn('relative', className)}>
      <SearchIcon className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-faint" />
      <input
        type="search"
        aria-label={label ?? placeholder}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        className={cn(CONTROL, 'pl-8')} />
      
    </div>);

}

export function Select({
  value,
  onChange,
  options,
  label,
  className






}: {value: string;onChange: (value: string) => void;options: {value: string;label: string;}[];label: string;className?: string;}) {
  return (
    <div className={cn('relative', className)}>
      <select
        aria-label={label}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className={cn(CONTROL, 'appearance-none pr-8')}>
        
        {options.map((option) =>
        <option key={option.value} value={option.value}>
            {option.label}
          </option>
        )}
      </select>
      <ChevronDownIcon className="pointer-events-none absolute right-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-faint" />
    </div>);

}

export function TextInput({
  value,
  onChange,
  label,
  hint,
  placeholder,
  type = 'text',
  required,
  className,
  prefix










}: {value: string;onChange: (value: string) => void;label: string;hint?: string;placeholder?: string;type?: string;required?: boolean;className?: string;prefix?: string;}) {
  const id = React.useId();
  return (
    <div className={className}>
      <label htmlFor={id} className="mb-1 block text-sm font-medium text-ink">
        {label}
        {required ? <span className="ml-1 text-coral">*</span> : null}
      </label>
      <div className="relative">
        {prefix ?
        <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-base text-ink-muted">
            {prefix}
          </span> :
        null}
        <input
          id={id}
          type={type}
          value={value}
          required={required}
          placeholder={placeholder}
          onChange={(event) => onChange(event.target.value)}
          className={cn(CONTROL, prefix && 'pl-7')} />
        
      </div>
      {hint ? <p className="mt-1 text-xs text-ink-muted">{hint}</p> : null}
    </div>);

}

export function TextArea({
  value,
  onChange,
  label,
  hint,
  placeholder,
  rows = 3,
  required,
  className









}: {value: string;onChange: (value: string) => void;label: string;hint?: string;placeholder?: string;rows?: number;required?: boolean;className?: string;}) {
  const id = React.useId();
  return (
    <div className={className}>
      <label htmlFor={id} className="mb-1 block text-sm font-medium text-ink">
        {label}
        {required ? <span className="ml-1 text-coral">*</span> : null}
      </label>
      <textarea
        id={id}
        rows={rows}
        value={value}
        placeholder={placeholder}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-md border border-line-strong bg-surface px-3 py-2 text-base text-ink placeholder:text-ink-faint transition-colors duration-150 ease-exp hover:border-ink-faint focus:border-ink focus:outline-none" />
      
      {hint ? <p className="mt-1 text-xs text-ink-muted">{hint}</p> : null}
    </div>);

}

export function Checkbox({
  checked,
  onChange,
  label,
  className





}: {checked: boolean;onChange: (checked: boolean) => void;label: string;className?: string;}) {
  return (
    <label
      className={cn(
        'inline-flex cursor-pointer select-none items-center gap-2 text-base text-ink-soft',
        className
      )}>
      
      <input
        type="checkbox"
        checked={checked}
        onChange={(event) => onChange(event.target.checked)}
        className="h-4 w-4 rounded border-line-strong text-coral accent-coral focus:ring-0" />
      
      {label}
    </label>);

}

export function Toggle({
  checked,
  onChange,
  label




}: {checked: boolean;onChange: (checked: boolean) => void;label: string;}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      onClick={() => onChange(!checked)}
      className={cn(
        'relative h-5 w-9 shrink-0 rounded-full border transition-colors duration-150 ease-exp',
        checked ? 'border-ok bg-ok' : 'border-line-strong bg-line'
      )}>
      
      <span
        className={cn(
          'absolute top-0.5 h-3.5 w-3.5 rounded-full bg-white shadow-sm transition-transform duration-150 ease-exp',
          checked ? 'translate-x-[18px]' : 'translate-x-0.5'
        )} />
      
    </button>);

}

export function FilterBar({
  children,
  className



}: {children: React.ReactNode;className?: string;}) {
  return (
    <div
      className={cn(
        'flex flex-wrap items-center gap-2 border-b border-line px-3 py-2.5',
        className
      )}>
      
      {children}
    </div>);

}