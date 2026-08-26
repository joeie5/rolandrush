import React from 'react';
import { LockIcon, ShieldCheckIcon } from 'lucide-react';
import { useAdmin } from '../contexts/AdminContext';
import { Button } from '../components/ui/Button';
import { TextInput } from '../components/ui/Field';

/**
 * Real Supabase Auth (email/password) + an admin_users membership check —
 * see AdminContext.signIn. The mock's second "6-digit code" stage had no
 * backend behind it, so it's dropped here rather than kept as a fake gate;
 * wiring Supabase's built-in OTP/magic-link as a true second factor is a
 * follow-up, not simulated in this pass.
 */
export function Login() {
  const { signIn, authError } = useAdmin();
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [submitting, setSubmitting] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  return (
    <div className="flex min-h-screen w-full items-center justify-center bg-canvas px-6 py-12">
      <div className="w-full max-w-[380px]">
        <div className="mb-6 flex items-center gap-2">
          <span className="flex h-8 w-8 items-center justify-center rounded-md bg-coral text-sm font-bold text-white">
            RR
          </span>
          <div className="leading-tight">
            <p className="text-md font-semibold text-ink">RolandRush</p>
            <p className="text-2xs uppercase tracking-wider text-ink-faint">
              Admin console
            </p>
          </div>
        </div>

        <div className="rounded-xl border border-line bg-surface p-5 shadow-card">
          <h1 className="text-xl font-semibold text-ink">Sign in</h1>
          <p className="mt-1 text-base text-ink-muted">
            Internal access only. Every action you take here is logged against your name.
          </p>

          <form
            className="mt-5 space-y-4"
            onSubmit={async (event) => {
              event.preventDefault();
              setError(null);
              setSubmitting(true);
              const ok = await signIn(email, password);
              setSubmitting(false);
              if (!ok) setError(authError ?? 'Sign-in failed.');
            }}>

            <TextInput
              label="Work email"
              type="email"
              value={email}
              onChange={setEmail}
              required />

            <TextInput
              label="Password"
              type="password"
              value={password}
              onChange={setPassword}
              required />

            {error ?
            <p
              role="alert"
              className="rounded-md border border-coral-border bg-coral-soft px-2.5 py-2 text-sm text-coral-ink">

                {error}
              </p> :
            null}

            <Button type="submit" variant="primary" size="lg" className="w-full" disabled={submitting}>
              {submitting ? 'Signing in…' : 'Sign in'}
            </Button>
          </form>
        </div>

        <div className="mt-4 flex items-start gap-2 rounded-lg border border-line bg-surface px-3 py-2.5">
          <ShieldCheckIcon className="mt-0.5 h-4 w-4 shrink-0 text-ok" />
          <p className="text-sm text-ink-muted">
            Access requires an active admin_users record — a valid RolandRush
            account alone isn't enough.
          </p>
        </div>
        <p className="mt-3 flex items-center gap-1.5 text-2xs text-ink-faint">
          <LockIcon className="h-3 w-3" />
          Unauthorised access is a criminal offence under the NDPA 2023.
        </p>
      </div>
    </div>);

}
