import React from 'react';
import { toast } from 'sonner';
import type {
  AccountStatus,
  AdminUser,
  AuditArea,
  AuditEntry,
  Customer,
  FeeRule,
  ModerationItem,
  Order,
  OrderStatus,
  Rider,
  ServiceZone,
  Tone,
  Vendor,
  VerificationSubmission,
  Withdrawal } from
'../types';
import { supabase } from '../lib/supabaseClient';
import {
  mapAdminUser,
  mapAudit,
  mapCustomer,
  mapFeeRule,
  mapModeration,
  mapOrder,
  mapRider,
  mapServiceZone,
  mapVendor,
  mapVerification,
  mapWithdrawal,
  fullName } from
'../lib/adapters';
import { naira, titleCase } from '../utils/format';

interface AdminState {
  currentAdmin: {id: string;name: string;email: string;role: string;};
  signedIn: boolean;
  authLoading: boolean;
  authError: string | null;
  signIn: (email: string, password: string) => Promise<boolean>;
  signOut: () => void;

  dataLoading: boolean;
  withdrawals: Withdrawal[];
  vendorChecks: VerificationSubmission[];
  riderChecks: VerificationSubmission[];
  moderation: ModerationItem[];
  vendors: Vendor[];
  riders: Rider[];
  customers: Customer[];
  orders: Order[];
  audit: AuditEntry[];
  serviceZones: ServiceZone[];
  feeRules: FeeRule[];
  adminTeam: AdminUser[];
  autoApprovalThreshold: number;

  counts: {
    withdrawals: number;
    vendorChecks: number;
    riderChecks: number;
    moderation: number;
    orders: number;
    urgent: number;
    total: number;
  };

  reload: () => Promise<void>;
  decideWithdrawal: (id: string, intent: 'approve' | 'reject', reason: string) => void;
  decideVerification: (
  kind: 'vendor' | 'rider',
  id: string,
  intent: 'approve' | 'reject',
  reason: string)
  => void;
  decideModeration: (id: string, intent: 'remove' | 'dismiss', reason: string) => void;
  setAccountStatus: (
  kind: 'vendor' | 'rider' | 'customer',
  id: string,
  status: AccountStatus,
  reason: string)
  => void;
  overrideOrderStatus: (orderId: string, status: OrderStatus, reason: string) => void;
  issueRefund: (
  orderId: string,
  amount: number,
  method: 'refund' | 'credit',
  reason: string)
  => void;
  logAction: (entry: {
    area: AuditArea;
    sentence: string;
    reason?: string;
    outcome: Tone;
  }) => void;

  addServiceZone: (state: string, city: string) => Promise<void>;
  toggleServiceZone: (id: string, isActive: boolean) => Promise<void>;
  updateServiceZone: (id: string, state: string, city: string) => Promise<void>;
  addFeeRule: (serviceAreaId: string, baseFee: number, perKmRate: number, minOrderValue: number) => Promise<void>;
  toggleFeeRule: (id: string, active: boolean) => Promise<void>;
  updateFeeRule: (id: string, baseFee: number, perKmRate: number) => Promise<void>;
  inviteAdmin: (name: string, email: string, role: AdminUser['role']) => Promise<void>;
  setAdminActive: (id: string, isActive: boolean) => Promise<void>;
}

const AdminContext = React.createContext<AdminState | null>(null);

function nowIso(): string {
  return new Date().toISOString();
}

export function AdminProvider({ children }: {children: React.ReactNode;}) {
  const [signedIn, setSignedIn] = React.useState(false);
  const [authLoading, setAuthLoading] = React.useState(true);
  const [authError, setAuthError] = React.useState<string | null>(null);
  const [currentAdminRow, setCurrentAdminRow] = React.useState<Record<string, any> | null>(null);
  const [currentAuthUser, setCurrentAuthUser] = React.useState<{email: string;} | null>(null);

  const [dataLoading, setDataLoading] = React.useState(false);
  const [withdrawalList, setWithdrawalList] = React.useState<Withdrawal[]>([]);
  const [vendorChecks, setVendorChecks] = React.useState<VerificationSubmission[]>([]);
  const [riderChecks, setRiderChecks] = React.useState<VerificationSubmission[]>([]);
  const [moderation, setModeration] = React.useState<ModerationItem[]>([]);
  const [vendors, setVendors] = React.useState<Vendor[]>([]);
  const [riders, setRiders] = React.useState<Rider[]>([]);
  const [customers, setCustomers] = React.useState<Customer[]>([]);
  const [orders, setOrders] = React.useState<Order[]>([]);
  const [audit, setAudit] = React.useState<AuditEntry[]>([]);
  const [serviceZones, setServiceZones] = React.useState<ServiceZone[]>([]);
  const [feeRules, setFeeRules] = React.useState<FeeRule[]>([]);
  const [adminTeam, setAdminTeam] = React.useState<AdminUser[]>([]);
  const [autoApprovalThreshold, setAutoApprovalThreshold] = React.useState(20000);

  // admin_users has no name/email column (only id/user_id/role/is_active/
  // created_at) — those come from the authenticated Supabase user instead.
  const currentAdmin = currentAdminRow && currentAuthUser ?
  {
    id: currentAdminRow.id as string,
    name: currentAuthUser.email.split('@')[0].replace(/[._]/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()),
    email: currentAuthUser.email,
    role: currentAdminRow.role ?? 'support'
  } :
  { id: '—', name: '—', email: '—', role: '—' };

  // ------------------------------------------------------------ auth

  const checkAdmin = React.useCallback(async (userId: string) => {
    const { data } = await supabase.
    from('admin_users').
    select('*').
    eq('user_id', userId).
    eq('is_active', true).
    maybeSingle();
    return data;
  }, []);

  React.useEffect(() => {
    let cancelled = false;
    (async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        const admin = await checkAdmin(session.user.id);
        if (cancelled) return;
        if (admin) {
          setCurrentAdminRow(admin);
          setCurrentAuthUser({ email: session.user.email ?? '' });
          setSignedIn(true);
        } else {
          // A valid Supabase user is not the same as an admin — sign them
          // back out rather than leaving a half-authenticated state.
          await supabase.auth.signOut();
        }
      }
      if (!cancelled) setAuthLoading(false);
    })();
    return () => {cancelled = true;};
  }, [checkAdmin]);

  const signIn = React.useCallback<AdminState['signIn']>(
    async (email, password) => {
      setAuthError(null);
      const { data, error } = await supabase.auth.signInWithPassword({ email, password });
      if (error || !data.user) {
        setAuthError(error?.message ?? 'Sign-in failed.');
        return false;
      }
      const admin = await checkAdmin(data.user.id);
      if (!admin) {
        setAuthError('This account is not an active RolandRush admin.');
        await supabase.auth.signOut();
        return false;
      }
      setCurrentAdminRow(admin);
      setCurrentAuthUser({ email: data.user.email ?? '' });
      setSignedIn(true);
      return true;
    },
    [checkAdmin]
  );

  const signOut = React.useCallback(() => {
    supabase.auth.signOut();
    setSignedIn(false);
    setCurrentAdminRow(null);
    setCurrentAuthUser(null);
  }, []);

  // ------------------------------------------------------------ audit

  const pushAuditLocal = React.useCallback((entry: AuditEntry) => {
    setAudit((current) => [entry, ...current]);
  }, []);

  /** Writes a real audit_log row (action/target_table/target_id/reason/admin_id). */
  const writeAudit = React.useCallback(
    async (action: string, targetTable: string, targetId: string, reason?: string) => {
      const adminId = currentAdminRow?.id ?? null;
      const { data } = await supabase.
      from('audit_log').
      insert({ action, target_table: targetTable, target_id: targetId, reason: reason || null, admin_id: adminId }).
      select().
      single();
      if (data) pushAuditLocal(mapAudit(data, currentAdmin.name));
    },
    [currentAdminRow, currentAdmin.name, pushAuditLocal]
  );

  const logAction = React.useCallback<AdminState['logAction']>(
    (entry) => {
      pushAuditLocal({
        id: `local_${Math.random().toString(36).slice(2, 9)}`,
        at: nowIso(),
        actor: currentAdmin.name,
        automated: false,
        ...entry
      });
    },
    [pushAuditLocal, currentAdmin.name]
  );

  // ------------------------------------------------------------ data load

  const reload = React.useCallback(async () => {
    setDataLoading(true);
    try {
      const [
      settingsRes,
      vendorRes,
      riderRes,
      customerRes,
      ordersRes,
      withdrawalsRes,
      walletsRes,
      contentReportsRes,
      serviceAreasRes,
      feeRulesRes,
      adminUsersRes,
      auditRes] =
      await Promise.all([
      supabase.from('platform_settings').select('key, value'),
      supabase.from('vendor_profiles').select('*'),
      supabase.from('rider_profiles').select('*'),
      supabase.from('customer_profiles').select('*'),
      supabase.from('orders').select('*').order('created_at', { ascending: false }).limit(500),
      supabase.from('withdrawal_requests').select('*').order('created_at', { ascending: false }),
      supabase.from('wallets').select('user_id, balance'),
      supabase.from('content_reports').select('*').order('created_at', { ascending: false }),
      supabase.from('service_areas').select('*'),
      supabase.from('delivery_fee_rules').select('*'),
      supabase.from('admin_users').select('*'),
      supabase.from('audit_log').select('*').order('created_at', { ascending: false }).limit(200)]
      );

      const settingsMap: Record<string, string> = {};
      (settingsRes.data ?? []).forEach((r: any) => {settingsMap[r.key] = String(r.value);});
      const threshold = Number(settingsMap['auto_withdrawal_approval_threshold']) || 20000;
      setAutoApprovalThreshold(threshold);

      const vendorRows = vendorRes.data ?? [];
      const riderRows = riderRes.data ?? [];
      const customerRows = customerRes.data ?? [];
      const orderRows = ordersRes.data ?? [];
      const walletByUser = new Map<string, number>((walletsRes.data ?? []).map((w: any) => [w.user_id, Number(w.balance) || 0]));

      const since30d = Date.now() - 30 * 24 * 60 * 60 * 1000;
      const ordersByVendor = new Map<string, any[]>();
      const ordersByCustomer = new Map<string, any[]>();
      orderRows.forEach((o: any) => {
        if (o.vendor_id) ordersByVendor.set(o.vendor_id, [...(ordersByVendor.get(o.vendor_id) ?? []), o]);
        if (o.customer_id) ordersByCustomer.set(o.customer_id, [...(ordersByCustomer.get(o.customer_id) ?? []), o]);
      });

      setVendors(
        vendorRows.map((v: any) => {
          const vOrders = (ordersByVendor.get(v.id) ?? []).filter((o) => new Date(o.created_at).getTime() > since30d);
          const gmv = vOrders.reduce((s, o) => s + (Number(o.subtotal) || 0), 0);
          return mapVendor(v, vOrders.length, gmv);
        })
      );
      setRiders(
        riderRows.map((r: any) => mapRider(r, 0)) // deliveries30d needs orders.rider_id join — left at 0, not tracked per-rider order count in this pass
      );
      setCustomers(
        customerRows.map((c: any) => {
          const cOrders = ordersByCustomer.get(c.user_id) ?? ordersByCustomer.get(c.id) ?? [];
          const spend = cOrders.reduce((s, o) => s + (Number(o.total_amount) || 0), 0);
          const last = cOrders[0]?.created_at ?? null;
          return mapCustomer(c, cOrders.length, spend, last);
        })
      );
      setOrders(orderRows.map(mapOrder));

      const vendorByUserId = new Map(vendorRows.map((v: any) => [v.user_id, v]));
      const riderByUserId = new Map(riderRows.map((r: any) => [r.user_id, r]));
      setWithdrawalList(
        (withdrawalsRes.data ?? []).map((w: any) => {
          const vendor = vendorByUserId.get(w.user_id);
          const rider = riderByUserId.get(w.user_id);
          const requester = vendor ?
          { type: 'vendor' as const, id: vendor.id, name: vendor.restaurant_name, location: [vendor.city, vendor.state].filter(Boolean).join(', '), bank: vendor } :
          rider ?
          { type: 'rider' as const, id: rider.id, name: fullName(rider), location: [rider.city, rider.state].filter(Boolean).join(', ') } :
          null;
          return mapWithdrawal(w, requester, walletByUser.get(w.user_id) ?? 0, threshold);
        })
      );

      setVendorChecks(vendorRows.filter((v: any) => v.verification_status === 'pending').map((v: any) => mapVerification(v, 'vendor')));
      setRiderChecks(riderRows.filter((r: any) => r.verification_status === 'pending').map((r: any) => mapVerification(r, 'rider')));

      const reportsByContent = new Map<string, any[]>();
      (contentReportsRes.data ?? []).forEach((r: any) => {
        const key = `${r.content_type}:${r.content_id}`;
        reportsByContent.set(key, [...(reportsByContent.get(key) ?? []), r]);
      });
      const moderationItems: ModerationItem[] = [];
      reportsByContent.forEach((group) => {
        const first = group.find((g) => g.status === 'pending') ?? group[0];
        if (first.status !== 'pending' && !group.some((g) => g.status === 'pending')) return;
        moderationItems.push(mapModeration(first, group.length, `${group.length} customer${group.length === 1 ? '' : 's'}`));
      });
      setModeration(moderationItems);

      const zoneRows = serviceAreasRes.data ?? [];
      // Real counts, matched on city (the only geography field both
      // service_areas and vendor_profiles/orders actually have in
      // common) — riders aren't included, see mapServiceZone's comment.
      const vendorsByCity = new Map<string, number>();
      vendorRows.forEach((v: any) => {
        if (!v.city) return;
        vendorsByCity.set(v.city, (vendorsByCity.get(v.city) ?? 0) + 1);
      });
      const vendorCityById = new Map(vendorRows.map((v: any) => [v.id, v.city]));
      const since7d = Date.now() - 7 * 24 * 60 * 60 * 1000;
      const ordersByCity = new Map<string, number>();
      orderRows.forEach((o: any) => {
        if (new Date(o.created_at).getTime() <= since7d) return;
        const city = vendorCityById.get(o.vendor_id);
        if (!city) return;
        ordersByCity.set(city, (ordersByCity.get(city) ?? 0) + 1);
      });
      setServiceZones(
        zoneRows.map((z: any) =>
          mapServiceZone(z, {
            vendors: vendorsByCity.get(z.city) ?? 0,
            orders7d: ordersByCity.get(z.city) ?? 0
          })
        )
      );
      const zoneById = new Map(zoneRows.map((z: any) => [z.id, [z.city, z.state].filter(Boolean).join(', ')]));
      setFeeRules((feeRulesRes.data ?? []).map((f: any) => mapFeeRule(f, zoneById.get(f.service_area_id) ?? '—')));

      setAdminTeam((adminUsersRes.data ?? []).map(mapAdminUser));

      const adminById = new Map((adminUsersRes.data ?? []).map((a: any) => [a.id, mapAdminUser(a).name]));
      setAudit((auditRes.data ?? []).map((a: any) => mapAudit(a, a.admin_id ? adminById.get(a.admin_id) ?? 'Admin' : 'Automated rule')));
    } catch (err) {
      toast.error('Could not load admin data', { description: String(err) });
    } finally {
      setDataLoading(false);
    }
  }, []);

  React.useEffect(() => {
    if (signedIn) reload();
  }, [signedIn, reload]);

  // ------------------------------------------------------------ decisions

  const decideWithdrawal = React.useCallback<AdminState['decideWithdrawal']>(
    async (id, intent, reason) => {
      const target = withdrawalList.find((item) => item.id === id);
      if (!target) return;
      const status = intent === 'approve' ? 'approved' : 'rejected';

      if (intent === 'approve') {
        // Approving must actually move money — a plain status update
        // here was the bug: it flipped withdrawal_requests.status but
        // never touched wallets.balance, so a vendor's available balance
        // never changed no matter how many withdrawals got "approved".
        // This RPC debits the wallet, records the transaction, and sets
        // status, all atomically, admin-gated.
        const { error } = await supabase.rpc('approve_withdrawal_and_debit', { p_withdrawal_id: id });
        if (error) {
          toast.error('Could not approve withdrawal', { description: error.message });
          return;
        }
      } else {
        const { error } = await supabase.
        from('withdrawal_requests').
        update({
          status,
          reviewed_by: currentAdminRow?.id ?? null,
          reviewed_at: nowIso(),
          rejection_reason: reason || null
        }).
        eq('id', id);
        if (error) {
          toast.error('Could not update withdrawal', { description: error.message });
          return;
        }
      }

      setWithdrawalList((current) =>
      current.map((item) => item.id === id ? { ...item, status, decision: { by: currentAdmin.name, at: nowIso(), reason } } : item)
      );
      await writeAudit(intent === 'approve' ? 'withdrawal_approved' : 'withdrawal_rejected', 'withdrawal_requests', id, reason);
      toast.success(`${target.reference} ${intent === 'approve' ? 'approved' : 'rejected'}`, {
        description: `${naira(target.amount)} · ${target.requesterName}`
      });
    },
    [withdrawalList, currentAdminRow, currentAdmin.name, writeAudit]
  );

  const decideVerification = React.useCallback<AdminState['decideVerification']>(
    async (kind, id, intent, reason) => {
      const pool = kind === 'vendor' ? vendorChecks : riderChecks;
      const target = pool.find((item) => item.id === id);
      if (!target) return;
      const table = kind === 'vendor' ? 'vendor_profiles' : 'rider_profiles';
      const verification_status = intent === 'approve' ? 'verified' : 'rejected';
      const { error } = await supabase.
      from(table).
      update({ verification_status, verified_at: nowIso(), verified_by: currentAdminRow?.id ?? null }).
      eq('id', id);
      if (error) {
        toast.error('Could not update verification', { description: error.message });
        return;
      }
      const setter = kind === 'vendor' ? setVendorChecks : setRiderChecks;
      setter((current) => current.filter((item) => item.id !== id));
      if (intent === 'approve') {
        if (kind === 'vendor') setVendors((c) => c.map((v) => v.id === id ? { ...v, status: 'active' } : v));
        else setRiders((c) => c.map((r) => r.id === id ? { ...r, status: 'active' } : r));
      }
      await writeAudit(intent === 'approve' ? 'verification_approved' : 'verification_rejected', table, id, reason);
      toast.success(`${target.subjectName} ${intent === 'approve' ? 'verified' : 'rejected'}`);
    },
    [vendorChecks, riderChecks, currentAdminRow, writeAudit]
  );

  const decideModeration = React.useCallback<AdminState['decideModeration']>(
    async (id, intent, reason) => {
      const target = moderation.find((item) => item.id === id);
      if (!target) return;
      const status = intent === 'remove' ? 'actioned' : 'dismissed';
      const { error } = await supabase.
      from('content_reports').
      update({ status, reviewed_by: currentAdminRow?.id ?? null, reviewed_at: nowIso(), action_taken: reason || null }).
      eq('id', id);
      if (error) {
        toast.error('Could not update report', { description: error.message });
        return;
      }
      setModeration((current) => current.filter((item) => item.id !== id));
      await writeAudit(intent === 'remove' ? 'content_removed' : 'content_dismissed', 'content_reports', id, reason);
      toast.success(intent === 'remove' ? 'Content removed' : 'Reports dismissed');
    },
    [moderation, currentAdminRow, writeAudit]
  );

  const setAccountStatus = React.useCallback<AdminState['setAccountStatus']>(
    async (kind, id, status, reason) => {
      const label =
      kind === 'vendor' ?
      vendors.find((v) => v.id === id)?.name :
      kind === 'rider' ?
      riders.find((r) => r.id === id)?.name :
      customers.find((c) => c.id === id)?.name;
      const table = kind === 'vendor' ? 'vendor_profiles' : kind === 'rider' ? 'rider_profiles' : 'customer_profiles';
      // vendor_profiles.status and customer_profiles.status are real
      // dedicated status columns. rider_profiles has no separate one —
      // verification_status is reused here (see brief section 4 gap note).
      const updatePayload =
      kind === 'rider' ?
      { verification_status: status === 'active' ? 'verified' : 'rejected' } :
      { status };
      const { error } = await supabase.from(table).update(updatePayload).eq('id', id);
      if (error) {
        toast.error('Could not update account', { description: error.message });
        return;
      }
      if (kind === 'vendor') setVendors((c) => c.map((v) => v.id === id ? { ...v, status } : v));
      else if (kind === 'rider') setRiders((c) => c.map((r) => r.id === id ? { ...r, status, online: status === 'active' ? r.online : false } : r));
      else setCustomers((c) => c.map((cust) => cust.id === id ? { ...cust, status } : cust));
      const verb = status === 'suspended' ? 'suspended' : status === 'banned' ? 'banned' : 'reactivated';
      await writeAudit(`account_${verb}`, table, id, reason);
      toast.success(`${label ?? 'Account'} ${verb}`);
    },
    [vendors, riders, customers, writeAudit]
  );

  const overrideOrderStatus = React.useCallback<AdminState['overrideOrderStatus']>(
    async (orderId, status, reason) => {
      const target = orders.find((order) => order.id === orderId);
      if (!target) return;
      const { error } = await supabase.
      from('orders').
      update({ status, cancelled_reason: status === 'cancelled' ? reason || null : null, cancelled_by: status === 'cancelled' ? currentAdminRow?.id ?? null : null }).
      eq('id', orderId);
      if (error) {
        toast.error('Could not override order', { description: error.message });
        return;
      }
      setOrders((current) =>
      current.map((order) =>
      order.id === orderId ?
      { ...order, stalledMinutes: undefined, timeline: [...order.timeline, { id: `t_${Math.random().toString(36).slice(2, 8)}`, label: `Status overridden to ${titleCase(status)}`, actor: currentAdmin.name, at: nowIso(), state: 'done' as const, detail: reason }] } :
      order
      )
      );
      await writeAudit('order_status_overridden', 'orders', orderId, reason);
      toast.success(`${target.code} set to ${titleCase(status)}`);
    },
    [orders, currentAdminRow, currentAdmin.name, writeAudit]
  );

  const issueRefund = React.useCallback<AdminState['issueRefund']>(
    async (orderId, amount, method, reason) => {
      const target = orders.find((order) => order.id === orderId);
      if (!target) return;
      // Whether a refund returns money externally (via the payment
      // processor) or as platform credit is an open product decision —
      // there's no customer wallet in the schema today, so this only
      // records the refund_amount/refund_reason on the order itself.
      // See brief section 8 follow-up note.
      const { error } = await supabase.
      from('orders').
      update({ refund_amount: amount, refund_reason: reason || null }).
      eq('id', orderId);
      if (error) {
        toast.error('Could not issue refund', { description: error.message });
        return;
      }
      setOrders((current) =>
      current.map((order) =>
      order.id === orderId ?
      { ...order, timeline: [...order.timeline, { id: `t_${Math.random().toString(36).slice(2, 8)}`, label: method === 'refund' ? `Refund of ${naira(amount)} issued` : `Wallet credit of ${naira(amount)} issued`, actor: currentAdmin.name, at: nowIso(), state: 'done' as const, detail: reason }] } :
      order
      )
      );
      await writeAudit('refund_issued', 'orders', orderId, reason);
      toast.success(`${naira(amount)} ${method === 'refund' ? 'refunded' : 'credited'}`, { description: `${target.customerName} · ${target.code}` });
    },
    [orders, currentAdmin.name, writeAudit]
  );

  // ------------------------------------------------------------ config CRUD

  const addServiceZone = React.useCallback(
    async (state: string, city: string) => {
      const { data, error } = await supabase.from('service_areas').insert({ state, city, is_active: true }).select().single();
      if (error) {
        toast.error('Could not add zone', { description: error.message });
        return;
      }
      setServiceZones((c) => [...c, mapServiceZone(data)]);
      await writeAudit('service_area_added', 'service_areas', data.id, `${city}, ${state}`);
      toast.success(`${city} added`);
    },
    [writeAudit]
  );

  const toggleServiceZone = React.useCallback(
    async (id: string, isActive: boolean) => {
      const { error } = await supabase.from('service_areas').update({ is_active: isActive }).eq('id', id);
      if (error) {
        toast.error('Could not update zone', { description: error.message });
        return;
      }
      setServiceZones((c) => c.map((z) => z.id === id ? { ...z, status: isActive ? 'live' : 'paused' } : z));
      await writeAudit(isActive ? 'service_area_enabled' : 'service_area_paused', 'service_areas', id);
    },
    [writeAudit]
  );

  const updateServiceZone = React.useCallback(
    async (id: string, state: string, city: string) => {
      const { error } = await supabase.from('service_areas').update({ state, city }).eq('id', id);
      if (error) {
        toast.error('Could not update zone', { description: error.message });
        return;
      }
      // Editing city changes which vendors/orders count toward this zone
      // (matched on city, see reload's vendorsByCity/ordersByCity) — a
      // full reload keeps those numbers honest rather than patching the
      // local zone object and leaving stale counts on screen.
      setServiceZones((c) => c.map((z) => z.id === id ? { ...z, name: city, city } : z));
      await writeAudit('service_area_updated', 'service_areas', id, `${city}, ${state}`);
      toast.success(`${city} updated`);
      await reload();
    },
    [writeAudit, reload]
  );

  const addFeeRule = React.useCallback(
    async (serviceAreaId: string, baseFee: number, perKmRate: number, minOrderValue: number) => {
      const { data, error } = await supabase.
      from('delivery_fee_rules').
      insert({ service_area_id: serviceAreaId, base_fee: baseFee, per_km_rate: perKmRate, min_order_value: minOrderValue, is_active: true }).
      select().
      single();
      if (error) {
        toast.error('Could not add fee rule', { description: error.message });
        return;
      }
      const zoneLabel = serviceZones.find((z) => z.id === serviceAreaId)?.name ?? '—';
      setFeeRules((c) => [...c, mapFeeRule(data, zoneLabel)]);
      await writeAudit('fee_rule_added', 'delivery_fee_rules', data.id);
      toast.success('Fee rule added');
    },
    [serviceZones, writeAudit]
  );

  const updateFeeRule = React.useCallback(
    async (id: string, baseFee: number, perKmRate: number) => {
      const { error } = await supabase.from('delivery_fee_rules').update({ base_fee: baseFee, per_km_rate: perKmRate }).eq('id', id);
      if (error) {
        toast.error('Could not update fee rule', { description: error.message });
        return;
      }
      setFeeRules((c) => c.map((f) => f.id === id ? { ...f, baseFee, perKm: perKmRate } : f));
      await writeAudit('fee_rule_updated', 'delivery_fee_rules', id);
    },
    [writeAudit]
  );

  const toggleFeeRule = React.useCallback(
    async (id: string, active: boolean) => {
      const { error } = await supabase.from('delivery_fee_rules').update({ is_active: active }).eq('id', id);
      if (error) {
        toast.error('Could not update fee rule', { description: error.message });
        return;
      }
      setFeeRules((c) => c.map((f) => f.id === id ? { ...f, active } : f));
      await writeAudit(active ? 'fee_rule_enabled' : 'fee_rule_disabled', 'delivery_fee_rules', id);
    },
    [writeAudit]
  );

  /**
   * admin_users has no name/email column (only id/user_id/role/is_active/
   * created_at), so those can't be persisted here — only role/is_active are
   * written. It also does NOT create the person's Supabase Auth user, and
   * has no user_id yet (null until that account exists and is linked) —
   * both need an invite-flow Edge Function with service-role access, out of
   * scope for client code (see brief section 6). The entered name/email are
   * shown locally for this session only, so the admin's intent is visible
   * immediately, but they are not saved anywhere.
   */
  const inviteAdmin = React.useCallback(
    async (name: string, email: string, role: AdminUser['role']) => {
      const { data, error } = await supabase.from('admin_users').insert({ role, is_active: false }).select().single();
      if (error) {
        toast.error('Could not invite admin', { description: error.message });
        return;
      }
      setAdminTeam((c) => [...c, { ...mapAdminUser(data), name, email }]);
      await writeAudit('admin_invited', 'admin_users', data.id, email);
      toast.success(`Invited ${name}`, { description: 'They still need a Supabase account created via an invite Edge Function before they can sign in.' });
    },
    [writeAudit]
  );

  const setAdminActive = React.useCallback(
    async (id: string, isActive: boolean) => {
      const { error } = await supabase.from('admin_users').update({ is_active: isActive }).eq('id', id);
      if (error) {
        toast.error('Could not update team member', { description: error.message });
        return;
      }
      setAdminTeam((c) => c.map((a) => a.id === id ? { ...a, status: isActive ? 'active' : 'disabled' } : a));
      await writeAudit(isActive ? 'admin_restored' : 'admin_disabled', 'admin_users', id);
    },
    [writeAudit]
  );

  // ------------------------------------------------------------ counts

  const counts = React.useMemo(() => {
    const wd = withdrawalList.filter((item) => item.status === 'pending');
    const vc = vendorChecks.filter((item) => item.status === 'pending');
    const rc = riderChecks.filter((item) => item.status === 'pending');
    const md = moderation.filter((item) => item.status === 'pending');
    const stalled = orders.filter((order) => Boolean(order.stalledMinutes));
    const urgent =
    wd.filter((i) => i.tier === 'urgent').length +
    vc.filter((i) => i.tier === 'urgent').length +
    rc.filter((i) => i.tier === 'urgent').length +
    md.filter((i) => i.tier === 'urgent').length +
    stalled.filter((o) => o.tier === 'urgent').length;
    return {
      withdrawals: wd.length,
      vendorChecks: vc.length,
      riderChecks: rc.length,
      moderation: md.length,
      orders: stalled.length,
      urgent,
      total: wd.length + vc.length + rc.length + md.length + stalled.length
    };
  }, [withdrawalList, vendorChecks, riderChecks, moderation, orders]);

  const value: AdminState = {
    currentAdmin,
    signedIn,
    authLoading,
    authError,
    signIn,
    signOut,
    dataLoading,
    withdrawals: withdrawalList,
    vendorChecks,
    riderChecks,
    moderation,
    vendors,
    riders,
    customers,
    orders,
    audit,
    serviceZones,
    feeRules,
    adminTeam,
    autoApprovalThreshold,
    counts,
    reload,
    decideWithdrawal,
    decideVerification,
    decideModeration,
    setAccountStatus,
    overrideOrderStatus,
    issueRefund,
    logAction,
    addServiceZone,
    toggleServiceZone,
    updateServiceZone,
    addFeeRule,
    toggleFeeRule,
    updateFeeRule,
    inviteAdmin,
    setAdminActive
  };

  return <AdminContext.Provider value={value}>{children}</AdminContext.Provider>;
}

export function useAdmin(): AdminState {
  const context = React.useContext(AdminContext);
  if (!context) throw new Error('useAdmin must be used inside AdminProvider');
  return context;
}
