/**
 * Shared domain types for RolandRushAdmin.
 *
 * The single most important concept here is `RiskTier`. Every queueable item in
 * the platform is routed into one of three tiers, and the whole UI leans on it:
 *   - 'auto'   → resolved automatically, log-only, no human decision needed
 *   - 'review' → queued for batched human review at the next sitting
 *   - 'urgent' → rare, high-stakes, time-sensitive; must be noticed immediately
 */
export type RiskTier = 'auto' | 'review' | 'urgent';

export type Tone = 'ok' | 'warn' | 'urgent' | 'neutral' | 'info';

/* ------------------------------------------------------------------ money */

export type WithdrawalStatus =
'auto_approved' |
'pending' |
'approved' |
'rejected';

export interface RequesterHistory {
  accountAgeDays: number;
  completedPayouts: number;
  totalPaidOut: number;
  averagePayout: number;
  lastPayoutAt: string | null;
  openDisputes: number;
  rejectedBefore: number;
}

export interface BankAccount {
  bankName: string;
  accountName: string;
  accountNumber: string;
  verifiedAt: string | null;
  timesUsed: number;
}

export interface Withdrawal {
  id: string;
  reference: string;
  requesterType: 'vendor' | 'rider';
  requesterId: string;
  requesterName: string;
  location: string;
  amount: number;
  availableBalance: number;
  requestedAt: string;
  tier: RiskTier;
  status: WithdrawalStatus;
  routingReason: string;
  flagReason?: string;
  bank: BankAccount;
  history: RequesterHistory;
  decision?: {by: string;at: string;reason?: string;};
}

export interface LedgerEntry {
  id: string;
  date: string;
  reference: string;
  type: 'order' | 'payout' | 'refund' | 'commission' | 'ad_spend';
  party: string;
  inflow: number;
  outflow: number;
  balance: number;
}

/* ------------------------------------------------------------------ orders */

export type OrderStatus =
'placed' |
'accepted' |
'preparing' |
'awaiting_rider' |
'in_transit' |
'delivered' |
'cancelled' |
'refunded';

export interface OrderEvent {
  id: string;
  label: string;
  actor: string;
  at: string | null;
  state: 'done' | 'active' | 'failed' | 'pending';
  detail?: string;
  automated?: boolean;
}

export interface ChatMessage {
  id: string;
  from: 'customer' | 'vendor' | 'rider' | 'support';
  name: string;
  at: string;
  body: string;
}

export interface OrderLine {
  name: string;
  qty: number;
  price: number;
}

export interface Order {
  id: string;
  code: string;
  placedAt: string;
  status: OrderStatus;
  tier: RiskTier;
  customerId: string;
  customerName: string;
  customerPhone: string;
  address: string;
  zone: string;
  vendorId: string;
  vendorName: string;
  riderId: string | null;
  riderName: string | null;
  lines: OrderLine[];
  totals: {
    subtotal: number;
    deliveryFee: number;
    serviceFee: number;
    discount: number;
    total: number;
  };
  payment: {
    method: 'card' | 'transfer' | 'wallet' | 'cash';
    status: 'paid' | 'pending' | 'refunded' | 'failed';
    reference: string;
    settledAt: string | null;
  };
  timeline: OrderEvent[];
  chat: ChatMessage[];
  note?: string;
  stalledMinutes?: number;
}

/* ------------------------------------------------------- people & accounts */

export type AccountStatus = 'active' | 'pending' | 'suspended' | 'banned';

export interface Vendor {
  id: string;
  name: string;
  owner: string;
  phone: string;
  zone: string;
  tier: 'standard' | 'premium' | 'featured';
  status: AccountStatus;
  joinedAt: string;
  orders30d: number;
  gmv30d: number;
  rating: number;
  cacNumber: string;
}

export interface Rider {
  id: string;
  name: string;
  phone: string;
  zone: string;
  vehicle: 'bike' | 'motorcycle' | 'car';
  status: AccountStatus;
  online: boolean;
  joinedAt: string;
  deliveries30d: number;
  acceptanceRate: number;
  rating: number;
  plateNumber: string;
}

export interface Customer {
  id: string;
  name: string;
  phone: string;
  zone: string;
  status: AccountStatus;
  joinedAt: string;
  orders: number;
  lifetimeSpend: number;
  refunds: number;
  lastOrderAt: string;
}

/* ------------------------------------------------------------ verification */

export interface SubmittedDocument {
  label: string;
  value: string;
  kind: 'text' | 'image';
  preview?: string;
  checks: {label: string;passed: boolean;}[];
}

export interface VerificationSubmission {
  id: string;
  subjectType: 'vendor' | 'rider';
  subjectName: string;
  contact: string;
  zone: string;
  submittedAt: string;
  tier: RiskTier;
  status: 'auto_approved' | 'pending' | 'approved' | 'rejected';
  routingReason: string;
  flagReason?: string;
  documents: SubmittedDocument[];
  decision?: {by: string;at: string;reason?: string;};
}

/* ------------------------------------------------------------- moderation */

export interface ModerationItem {
  id: string;
  kind: 'feed_video' | 'review' | 'profile';
  subject: string;
  author: string;
  createdAt: string;
  reportCount: number;
  reportedBy: string;
  reason: string;
  tier: RiskTier;
  status: 'auto_removed' | 'pending' | 'removed' | 'dismissed';
  routingReason: string;
  excerpt: string;
  thumbnail?: string;
  decision?: {by: string;at: string;reason?: string;};
}

/* -------------------------------------------------------------- audit log */

export type AuditArea =
'withdrawals' |
'orders' |
'verification' |
'accounts' |
'moderation' |
'config' |
'team';

export interface AuditEntry {
  id: string;
  at: string;
  actor: string;
  automated: boolean;
  area: AuditArea;
  /** Human-readable sentence, e.g. "approved a ₦12,000 withdrawal for Iya Basira Kitchen". */
  sentence: string;
  reason?: string;
  outcome: Tone;
  target?: {label: string;href?: string;};
}

/* ------------------------------------------------------------------ config */

export interface ServiceZone {
  id: string;
  name: string;
  city: string;
  status: 'live' | 'paused' | 'planned';
  vendors: number;
  riders: number;
  orders7d: number;
  baseFee: number;
  radiusKm: number;
}

export interface FeeRule {
  id: string;
  name: string;
  zone: string;
  baseFee: number;
  perKm: number;
  minFee: number;
  maxFee: number;
  surgeMultiplier: number;
  active: boolean;
}

export type AdminRole = 'Founder' | 'Ops Lead' | 'Support Agent' | 'Finance';

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
  status: 'active' | 'invited' | 'disabled';
  lastActiveAt: string;
  actions30d: number;
}

/* ------------------------------------------------------------- phase two */

export interface Dispute {
  id: string;
  orderCode: string;
  raisedBy: string;
  party: 'customer' | 'vendor' | 'rider';
  openedAt: string;
  category: string;
  tier: RiskTier;
  status: 'open' | 'waiting' | 'resolved';
  amountAtRisk: number;
  summary: string;
}

export interface PromoCode {
  id: string;
  code: string;
  type: 'percent' | 'fixed' | 'free_delivery';
  value: number;
  redemptions: number;
  cap: number;
  expiresAt: string;
  status: 'active' | 'scheduled' | 'expired';
}

export interface AdCampaign {
  id: string;
  vendor: string;
  title: string;
  budget: number;
  spend: number;
  impressions: number;
  clicks: number;
  tier: RiskTier;
  status: 'pending' | 'running' | 'rejected' | 'finished';
  submittedAt: string;
}