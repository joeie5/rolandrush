import type { AuditEntry } from '../types';

/**
 * Audit entries are stored as readable sentences on purpose — the point of this
 * log is answering "who did this, and why" without translating database rows.
 */
export const auditEntries: AuditEntry[] = [
{
  id: 'a_501',
  at: '2026-08-25T08:41:20',
  actor: 'Automated rule',
  automated: true,
  area: 'orders',
  sentence:
  'released ₦9,265 in vendor earnings for order RR-88231 to Amala Sky Buffet',
  outcome: 'ok',
  target: { label: 'RR-88231', href: '/orders/o_88231' }
},
{
  id: 'a_500',
  at: '2026-08-24T20:41:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'orders',
  sentence:
  'issued a ₦1,600 partial refund to Adaeze Nwosu on order RR-88213',
  reason: 'Missing items confirmed by the vendor’s own packing note.',
  outcome: 'warn',
  target: { label: 'RR-88213', href: '/orders/o_88213' }
},
{
  id: 'a_499',
  at: '2026-08-24T19:40:00',
  actor: 'Automated rule',
  automated: true,
  area: 'withdrawals',
  sentence: 'auto-approved a ₦28,400 withdrawal for Segun Bamidele',
  reason: 'Known account, under ₦50,000, 22 clean payouts.',
  outcome: 'ok',
  target: { label: 'RR-WD-1037', href: '/withdrawals/wd_1037' }
},
{
  id: 'a_498',
  at: '2026-08-24T18:15:00',
  actor: 'Automated rule',
  automated: true,
  area: 'orders',
  sentence: 'auto-refunded ₦4,350 to Seyi Ogunbiyi after a vendor rejection',
  reason: 'Vendor rejected within 5 minutes of the order being placed.',
  outcome: 'ok',
  target: { label: 'RR-88205', href: '/orders/o_88205' }
},
{
  id: 'a_497',
  at: '2026-08-24T15:02:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'withdrawals',
  sentence: 'approved a ₦226,000 withdrawal for Ife Grill House',
  reason: 'Balance and order volume reconcile, account details unchanged.',
  outcome: 'ok',
  target: { label: 'RR-WD-1034', href: '/withdrawals/wd_1034' }
},
{
  id: 'a_496',
  at: '2026-08-24T12:15:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'withdrawals',
  sentence: 'rejected a ₦58,000 withdrawal for Yusuf Ibrahim',
  reason:
  'Bank account name does not match the rider’s verified identity. Asked rider to submit an account in his own name.',
  outcome: 'urgent',
  target: { label: 'RR-WD-1033', href: '/withdrawals/wd_1033' }
},
{
  id: 'a_495',
  at: '2026-08-24T11:04:00',
  actor: 'Ngozi Eze',
  automated: false,
  area: 'accounts',
  sentence: 'suspended the rider account of Yusuf Ibrahim',
  reason: 'Second identity mismatch in 30 days, pending document re-submission.',
  outcome: 'urgent',
  target: { label: 'Yusuf Ibrahim', href: '/riders/r_yusuf' }
},
{
  id: 'a_494',
  at: '2026-08-24T10:22:00',
  actor: 'Ngozi Eze',
  automated: false,
  area: 'verification',
  sentence: 'approved the vendor verification for Sweet Sip Smoothies',
  reason: 'CAC number verified against the registry, ID matches the owner.',
  outcome: 'ok'
},
{
  id: 'a_493',
  at: '2026-08-24T09:15:00',
  actor: 'Automated rule',
  automated: true,
  area: 'withdrawals',
  sentence: 'auto-approved a ₦42,300 withdrawal for Sweet Sip Smoothies',
  outcome: 'ok',
  target: { label: 'RR-WD-1032', href: '/withdrawals/wd_1032' }
},
{
  id: 'a_492',
  at: '2026-08-23T17:40:00',
  actor: 'Ngozi Eze',
  automated: false,
  area: 'withdrawals',
  sentence: 'approved a ₦133,400 withdrawal for Shawarma Republic',
  reason: 'Routine payout, history clean.',
  outcome: 'ok',
  target: { label: 'RR-WD-1030', href: '/withdrawals/wd_1030' }
},
{
  id: 'a_491',
  at: '2026-08-23T16:10:00',
  actor: 'Automated rule',
  automated: true,
  area: 'moderation',
  sentence:
  'auto-removed a feed video from Naija Bites Ilesa after 12 reports for misleading pricing',
  reason: 'Report threshold of 10 reached within one hour.',
  outcome: 'ok'
},
{
  id: 'a_490',
  at: '2026-08-23T14:55:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'accounts',
  sentence: 'suspended the vendor account of Naija Bites Ilesa',
  reason:
  'Three confirmed cases of substituting items without telling the customer.',
  outcome: 'urgent',
  target: { label: 'Naija Bites Ilesa', href: '/vendors/v_naijabites' }
},
{
  id: 'a_489',
  at: '2026-08-23T11:30:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'config',
  sentence:
  'raised the Ile-Ife base delivery fee from ₦900 to ₦1,100',
  reason: 'Fuel price change and longer average trip distance in the zone.',
  outcome: 'info'
},
{
  id: 'a_488',
  at: '2026-08-22T17:12:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'team',
  sentence: 'invited ngozi@rolandrush.ng as an Ops Lead',
  outcome: 'info'
},
{
  id: 'a_487',
  at: '2026-08-22T09:40:00',
  actor: 'Josh Adeyemi',
  automated: false,
  area: 'config',
  sentence: 'opened the Gbongan service zone for vendor sign-ups',
  reason: 'Six vendors on the waitlist and two riders already onboarded.',
  outcome: 'info'
},
{
  id: 'a_486',
  at: '2026-08-21T15:08:00',
  actor: 'Ngozi Eze',
  automated: false,
  area: 'orders',
  sentence:
  'overrode order RR-88102 from In transit to Delivered',
  reason:
  'Customer confirmed receipt on the phone, rider’s app crashed before confirming.',
  outcome: 'warn'
},
{
  id: 'a_485',
  at: '2026-08-21T10:02:00',
  actor: 'Automated rule',
  automated: true,
  area: 'verification',
  sentence:
  'auto-approved the rider verification for Kemi Oyelaran after a clean document check',
  outcome: 'ok'
},
{
  id: 'a_484',
  at: '2026-08-20T18:44:00',
  actor: 'Ngozi Eze',
  automated: false,
  area: 'moderation',
  sentence: 'dismissed 4 reports on a review of The Bowl Company',
  reason: 'Reports came from a single competing vendor’s accounts.',
  outcome: 'neutral'
}];