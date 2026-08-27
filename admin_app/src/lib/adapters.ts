/**
 * Maps real Supabase rows into the same TS shapes the (Magic Patterns-built)
 * UI already expects. This keeps every page component untouched — only the
 * data layer (AdminContext) changed. Fields with no real backing column are
 * defaulted honestly and commented, per the wiring brief: don't fake data
 * that looks like it came from a real signal when it didn't.
 */
import type {
  AdminUser,
  AuditArea,
  AuditEntry,
  Customer,
  FeeRule,
  ModerationItem,
  Order,
  Rider,
  RiskTier,
  ServiceZone,
  Vendor,
  VerificationSubmission,
  Withdrawal } from
'../types';

export function fullName(row: Record<string, any>, fallback = 'Unknown'): string {
  return (
    row.full_name ||
    [row.first_name, row.last_name].filter(Boolean).join(' ') ||
    row.restaurant_name ||
    row.name ||
    fallback);

}

/** amount vs the single real threshold — no urgent tier exists yet (see brief section 2). */
export function withdrawalTier(amount: number, threshold: number): RiskTier {
  return amount <= threshold ? 'auto' : 'review';
}

export function mapWithdrawal(
row: Record<string, any>,
requester: {type: 'vendor' | 'rider';id: string;name: string;location: string;bank?: Record<string, any>;} | null,
availableBalance: number,
threshold: number)
: Withdrawal {
  return {
    id: row.id,
    reference: `WD-${String(row.id).slice(0, 8).toUpperCase()}`,
    requesterType: requester?.type ?? 'vendor',
    requesterId: requester?.id ?? row.user_id,
    requesterName: requester?.name ?? 'Unknown',
    location: requester?.location ?? '—',
    amount: Number(row.amount) || 0,
    availableBalance,
    requestedAt: row.created_at,
    tier: withdrawalTier(Number(row.amount) || 0, threshold),
    status: row.status === 'approved' ? 'approved' : row.status === 'rejected' ? 'rejected' : 'pending',
    routingReason:
    Number(row.amount) <= threshold ?
    `At or below the ₦${threshold.toLocaleString()} auto-approval threshold` :
    `Above the ₦${threshold.toLocaleString()} auto-approval threshold — needs review`,
    // No bank-change-recency or disputes signal exists yet (see brief
    // section 2 follow-up note) — flagReason is always unset here rather
    // than fabricated.
    flagReason: undefined,
    bank: {
      bankName: requester?.bank?.bank_name ?? '',
      accountName: requester?.bank?.account_name ?? '',
      accountNumber: requester?.bank?.account_number ?? '',
      verifiedAt: null,
      timesUsed: 0
    },
    // No requester-history signals (payout count, account age, disputes)
    // are tracked yet — zeroed rather than invented.
    history: {
      accountAgeDays: 0,
      completedPayouts: 0,
      totalPaidOut: 0,
      averagePayout: 0,
      lastPayoutAt: null,
      openDisputes: 0,
      rejectedBefore: 0
    },
    decision: row.reviewed_by ?
    { by: row.reviewed_by, at: row.reviewed_at, reason: row.rejection_reason ?? undefined } :
    undefined
  };
}

export function mapVendor(row: Record<string, any>, orders30d: number, gmv30d: number): Vendor {
  return {
    id: row.id,
    name: row.restaurant_name ?? 'Unnamed restaurant',
    owner: fullName(row, '—'),
    phone: row.phone_number ?? '—',
    zone: [row.city, row.state].filter(Boolean).join(', ') || '—',
    // No distinct marketing-tier column exists (see brief section 4
    // follow-up) — subscription_tier is a billing tier, not a placement
    // tier; mapped through as a stand-in until a product decision is made.
    tier: row.subscription_tier?.toLowerCase().includes('premium') || row.subscription_tier?.toLowerCase() === 'gold' ? 'premium' : row.is_sponsored ? 'featured' : 'standard',
    status: row.status ?? 'active',
    joinedAt: row.created_at,
    orders30d,
    gmv30d,
    rating: Number(row.rating) || 0,
    cacNumber: row.cac_number ?? '—'
  };
}

export function mapRider(row: Record<string, any>, deliveries30d: number): Rider {
  return {
    id: row.id,
    name: fullName(row),
    phone: row.phone_number ?? '—',
    zone: [row.city, row.state].filter(Boolean).join(', ') || '—',
    vehicle: (row.vehicle_type ?? 'motorcycle') as Rider['vehicle'],
    // rider_profiles has no dedicated suspend/ban status field distinct from
    // verification_status (see brief section 4) — verification_status is
    // reused here since it's the only status-shaped column available.
    status: row.verification_status === 'rejected' ? 'suspended' : row.verification_status === 'verified' ? 'active' : 'pending',
    online: Boolean(row.is_online),
    joinedAt: row.created_at,
    deliveries30d,
    acceptanceRate: 0, // no acceptance-rate signal tracked yet
    rating: Number(row.rating) || 0,
    plateNumber: row.plate_number ?? '—'
  };
}

export function mapCustomer(row: Record<string, any>, orders: number, lifetimeSpend: number, lastOrderAt: string | null): Customer {
  return {
    id: row.id,
    name: fullName(row),
    phone: row.phone_number ?? row.phone ?? '—',
    zone: row.state ?? '—',
    status: row.status ?? 'active',
    joinedAt: row.created_at,
    orders,
    lifetimeSpend,
    refunds: 0, // not tracked per-customer yet
    lastOrderAt: lastOrderAt ?? row.created_at
  };
}

export function mapOrder(row: Record<string, any>): Order {
  const items = (row.items as any[]) ?? [];
  const lines = items.map((i) => ({ name: i.name ?? 'Item', qty: i.quantity ?? 1, price: i.price ?? 0 }));
  return {
    id: row.id,
    code: row.order_number ?? row.id,
    placedAt: row.created_at,
    deliveredAt: row.delivered_at ?? null,
    refundAmount: Number(row.refund_amount) || 0,
    status: mapOrderStatus(row.status),
    tier: row.status === 'cancelled' ? 'review' : 'auto',
    customerId: row.customer_id,
    customerName: row.customer_name ?? '—',
    customerPhone: row.customer_phone ?? '—',
    address: row.delivery_address ?? '—',
    zone: '—',
    vendorId: row.vendor_id,
    vendorName: row.restaurant_name ?? '—',
    riderId: row.rider_id ?? null,
    riderName: null,
    lines,
    totals: {
      subtotal: Number(row.subtotal) || 0,
      deliveryFee: Number(row.delivery_fee) || 0,
      serviceFee: Number(row.service_fee) || 0,
      discount: 0,
      total: Number(row.total_amount) || 0
    },
    payment: {
      method: (row.payment_method as any) ?? 'cash',
      status: (row.payment_status as any) ?? 'pending',
      reference: row.id,
      settledAt: row.payment_status === 'paid' ? row.created_at : null
    },
    timeline: [],
    chat: [],
    note: row.cancelled_reason ?? undefined,
    stalledMinutes: undefined
  };
}

function mapOrderStatus(status: string | null): Order['status'] {
  const known: Order['status'][] = ['placed', 'accepted', 'preparing', 'awaiting_rider', 'in_transit', 'delivered', 'cancelled', 'refunded'];
  return (known.includes(status as any) ? status : 'placed') as Order['status'];
}

export function mapVerification(
row: Record<string, any>,
kind: 'vendor' | 'rider')
: VerificationSubmission {
  const name = kind === 'vendor' ? row.restaurant_name ?? 'Unnamed restaurant' : fullName(row);
  return {
    id: row.id,
    subjectType: kind,
    subjectName: name,
    contact: `${fullName(row, '—')} · ${row.phone_number ?? '—'}`,
    zone: [row.city, row.state].filter(Boolean).join(', ') || '—',
    submittedAt: row.created_at,
    tier: 'review',
    status: row.verification_status === 'verified' ? 'approved' : row.verification_status === 'rejected' ? 'rejected' : 'pending',
    routingReason: 'Awaiting manual document review',
    flagReason: undefined,
    // Document images and per-field registry checks have no backing
    // storage/table yet (see brief section 3) — only the raw text fields
    // that already exist on the profile are shown, not fabricated images.
    documents: [
    kind === 'vendor' ?
    { label: 'CAC number', value: row.cac_number ?? '—', kind: 'text' as const, checks: [] } :
    { label: 'ID type', value: row.id_type ?? '—', kind: 'text' as const, checks: [] },
    { label: kind === 'vendor' ? 'ID number' : 'ID number', value: row.id_number ?? '—', kind: 'text' as const, checks: [] }],

    decision: row.verified_by ?
    { by: row.verified_by, at: row.verified_at, reason: undefined } :
    undefined
  };
}

export function mapModeration(
row: Record<string, any>,
groupCount: number,
reporterLabel: string)
: ModerationItem {
  return {
    id: row.id,
    kind: row.content_type === 'menu_item' ? 'feed_video' : row.content_type === 'review' ? 'review' : 'profile',
    subject: row.content_type ?? 'content',
    author: '—',
    createdAt: row.created_at,
    reportCount: groupCount,
    reportedBy: reporterLabel,
    reason: row.reason ?? '—',
    tier: groupCount >= 5 ? 'review' : 'auto',
    status: row.status === 'actioned' ? 'removed' : row.status === 'dismissed' ? 'dismissed' : 'pending',
    // Auto-removal-at-N-reports has no server-side trigger yet (see brief
    // section 5 follow-up) — this string only describes the count, it
    // doesn't claim an automatic action is armed.
    routingReason: `${groupCount} report${groupCount === 1 ? '' : 's'} against this content`,
    excerpt: row.reason ?? '',
    thumbnail: undefined,
    decision: row.reviewed_by ?
    { by: row.reviewed_by, at: row.reviewed_at, reason: row.action_taken ?? undefined } :
    undefined
  };
}

const AUDIT_AREA_BY_TABLE: Record<string, AuditArea> = {
  withdrawal_requests: 'withdrawals',
  orders: 'orders',
  vendor_profiles: 'verification',
  rider_profiles: 'verification',
  customer_profiles: 'accounts',
  content_reports: 'moderation',
  service_areas: 'config',
  delivery_fee_rules: 'config',
  admin_users: 'team'
};

export function mapAudit(row: Record<string, any>, actorName: string): AuditEntry {
  return {
    id: row.id,
    at: row.created_at,
    actor: actorName,
    automated: !row.admin_id,
    area: AUDIT_AREA_BY_TABLE[row.target_table as string] ?? 'config',
    sentence: `${row.action} on ${row.target_table} (${row.target_id})`,
    reason: row.reason ?? undefined,
    outcome: 'neutral',
    target: row.target_id ? { label: String(row.target_id).slice(0, 8) } : undefined
  };
}

export function mapServiceZone(
  row: Record<string, any>,
  counts?: { vendors: number; orders7d: number }
): ServiceZone {
  return {
    id: row.id,
    name: row.city ?? row.state ?? 'Unnamed',
    city: row.city ?? '—',
    status: row.is_active ? 'live' : 'paused',
    vendors: counts?.vendors ?? 0,
    // rider_profiles has no city/state column at all, so a rider can't be
    // matched to a zone today — approximating via free-text `address`
    // would be exactly the kind of fabricated-looking number this
    // codebase has deliberately avoided elsewhere. Stays 0 until riders
    // have a real zone/city field to join on.
    riders: 0,
    orders7d: counts?.orders7d ?? 0,
    // service_areas has no base_fee/radius columns — base fee actually
    // lives on delivery_fee_rules (a separate table/screen), and there's
    // no radius concept in the schema at all.
    baseFee: 0,
    radiusKm: 0
  };
}

export function mapFeeRule(row: Record<string, any>, zoneLabel: string): FeeRule {
  return {
    id: row.id,
    serviceAreaId: row.service_area_id,
    name: zoneLabel,
    zone: zoneLabel,
    baseFee: Number(row.base_fee) || 0,
    perKm: Number(row.per_km_rate) || 0,
    minFee: Number(row.min_order_value) || 0,
    maxFee: 0,
    surgeMultiplier: 1,
    active: Boolean(row.is_active)
  };
}

export function mapAdminUser(row: Record<string, any>): AdminUser {
  // admin_users only has id/user_id/role/is_active/created_at — no name or
  // email column, and auth.users isn't queryable from the client. Showing
  // another admin's real name/email needs either an admin_profiles table
  // or a server-side (service-role) lookup — flagged, not faked here.
  return {
    id: row.id,
    name: row.name ?? '(no profile on file)',
    email: row.email ?? '—',
    role: (row.role as AdminUser['role']) ?? 'Support Agent',
    status: row.is_active ? 'active' : 'disabled',
    lastActiveAt: row.last_active_at ?? row.created_at ?? new Date().toISOString(),
    actions30d: 0
  };
}
