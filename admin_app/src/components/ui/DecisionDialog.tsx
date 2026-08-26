import React from 'react';
import { AlertTriangleIcon, ShieldCheckIcon } from 'lucide-react';
import { Modal } from './Modal';
import { Button } from './Button';
import { TextArea } from './Field';

export interface DecisionRequest {
  /** What is being decided, e.g. "Approve ₦46,000 payout". */
  title: string;
  /** One line stating the irreversible consequence. */
  consequence: string;
  /** Facts the reviewer should re-read before committing. */
  facts?: {label: string;value: string;}[];
  intent: 'approve' | 'reject';
  reasonRequired: boolean;
  reasonLabel?: string;
  suggestions?: string[];
  confirmLabel: string;
  onConfirm: (reason: string) => void;
}

/**
 * The single confirmation surface for every irreversible action in the
 * dashboard — money movement, account status, order overrides, removals.
 * The friction (re-stated consequence + required reason) is deliberate.
 */
export function DecisionDialog({
  request,
  onClose



}: {request: DecisionRequest | null;onClose: () => void;}) {
  const [reason, setReason] = React.useState('');

  React.useEffect(() => {
    if (request) setReason('');
  }, [request]);

  const blocked = Boolean(request?.reasonRequired) && reason.trim().length < 6;
  const isReject = request?.intent === 'reject';

  return (
    <Modal
      open={Boolean(request)}
      onClose={onClose}
      title={request?.title ?? ''}
      accent={isReject ? 'coral' : 'ok'}
      description={
      <span className="inline-flex items-start gap-1.5">
          {isReject ?
        <AlertTriangleIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-coral" /> :

        <ShieldCheckIcon className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ok" />
        }
          {request?.consequence}
        </span>
      }
      footer={
      <>
          <Button variant="ghost" onClick={onClose}>
            Cancel
          </Button>
          <Button
          variant={isReject ? 'primary' : 'approve'}
          disabled={blocked}
          onClick={() => {
            request?.onConfirm(reason.trim());
            onClose();
          }}>
          
            {request?.confirmLabel}
          </Button>
        </>
      }>
      
      {request?.facts?.length ?
      <dl className="mb-4 divide-y divide-line rounded-lg border border-line bg-canvas">
          {request.facts.map((fact) =>
        <div
          key={fact.label}
          className="flex items-baseline justify-between gap-4 px-3 py-2">
          
              <dt className="text-sm text-ink-muted">{fact.label}</dt>
              <dd className="tabular text-right text-base font-medium text-ink">
                {fact.value}
              </dd>
            </div>
        )}
        </dl> :
      null}

      {request?.reasonRequired ?
      <>
          <TextArea
          label={request.reasonLabel ?? 'Reason'}
          required
          rows={3}
          value={reason}
          onChange={setReason}
          placeholder="This is stored on the audit log and shown to the requester."
          hint={
          blocked ?
          'A reason of at least 6 characters is required before this can be submitted.' :
          'Written to the audit log against your name.'
          } />
        
          {request.suggestions?.length ?
        <div className="mt-2 flex flex-wrap gap-1.5">
              {request.suggestions.map((suggestion) =>
          <button
            key={suggestion}
            type="button"
            onClick={() => setReason(suggestion)}
            className="rounded-md border border-line-strong bg-surface px-2 py-1 text-xs text-ink-soft transition-colors duration-150 ease-exp hover:border-ink-faint hover:bg-line-soft hover:text-ink">
            
                  {suggestion}
                </button>
          )}
            </div> :
        null}
        </> :

      <p className="text-base text-ink-soft">
          This action is recorded against your name in the audit log.
        </p>
      }
    </Modal>);

}

export function useDecision() {
  const [request, setRequest] = React.useState<DecisionRequest | null>(null);
  return {
    request,
    ask: setRequest,
    close: () => setRequest(null)
  };
}