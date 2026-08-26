import type { Withdrawal } from '../types';

/**
 * Routing rules the platform applies before anything reaches this queue:
 *  - auto   → known account, under ₦50,000, no open disputes, 3+ clean payouts
 *  - review → first payout to a bank account, or ₦50,000–₦250,000
 *  - urgent → over ₦250,000, changed account details, or an open dispute
 */
export const withdrawals: Withdrawal[] = [
{
  id: 'wd_1042',
  reference: 'RR-WD-1042',
  requesterType: 'vendor',
  requesterId: 'v_iyabasira',
  requesterName: 'Iya Basira Kitchen',
  location: 'Osogbo — Oke Fia',
  amount: 412000,
  availableBalance: 468300,
  requestedAt: '2026-08-25T08:12:00',
  tier: 'urgent',
  status: 'pending',
  routingReason: 'Above the ₦250,000 single-payout ceiling',
  flagReason:
  'Bank account was changed 40 minutes before this request was raised.',
  bank: {
    bankName: 'Moniepoint MFB',
    accountName: 'Basirat O. Adewale',
    accountNumber: '8107744120',
    verifiedAt: '2026-08-25T07:32:00',
    timesUsed: 0
  },
  history: {
    accountAgeDays: 431,
    completedPayouts: 38,
    totalPaidOut: 6420000,
    averagePayout: 168900,
    lastPayoutAt: '2026-08-18T09:04:00',
    openDisputes: 0,
    rejectedBefore: 0
  }
},
{
  id: 'wd_1041',
  reference: 'RR-WD-1041',
  requesterType: 'rider',
  requesterId: 'r_tunde',
  requesterName: 'Tunde Afolabi',
  location: 'Ile-Ife — Mayfair',
  amount: 96500,
  availableBalance: 96500,
  requestedAt: '2026-08-25T07:48:00',
  tier: 'urgent',
  status: 'pending',
  routingReason: 'Open delivery dispute on the account',
  flagReason:
  'Rider has an unresolved ₦18,400 dispute from order RR-88213 (missing item).',
  bank: {
    bankName: 'Opay',
    accountName: 'Tunde Afolabi',
    accountNumber: '7031882204',
    verifiedAt: '2026-05-02T11:00:00',
    timesUsed: 11
  },
  history: {
    accountAgeDays: 288,
    completedPayouts: 24,
    totalPaidOut: 1104000,
    averagePayout: 46000,
    lastPayoutAt: '2026-08-19T18:22:00',
    openDisputes: 1,
    rejectedBefore: 1
  }
},
{
  id: 'wd_1040',
  reference: 'RR-WD-1040',
  requesterType: 'vendor',
  requesterId: 'v_thebowl',
  requesterName: 'The Bowl Company',
  location: 'Osogbo — Alekuwodo',
  amount: 184000,
  availableBalance: 220450,
  requestedAt: '2026-08-25T06:55:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'Amount between ₦50,000 and ₦250,000',
  bank: {
    bankName: 'GTBank',
    accountName: 'The Bowl Company Ltd',
    accountNumber: '0224419087',
    verifiedAt: '2026-02-11T10:15:00',
    timesUsed: 19
  },
  history: {
    accountAgeDays: 512,
    completedPayouts: 44,
    totalPaidOut: 7810000,
    averagePayout: 177500,
    lastPayoutAt: '2026-08-20T08:40:00',
    openDisputes: 0,
    rejectedBefore: 0
  }
},
{
  id: 'wd_1039',
  reference: 'RR-WD-1039',
  requesterType: 'rider',
  requesterId: 'r_kemi',
  requesterName: 'Kemi Oyelaran',
  location: 'Ilesa — Ereja',
  amount: 63200,
  availableBalance: 63200,
  requestedAt: '2026-08-25T06:20:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'First payout to this bank account',
  bank: {
    bankName: 'Kuda MFB',
    accountName: 'Kemi Oyelaran',
    accountNumber: '2019338471',
    verifiedAt: '2026-08-24T19:02:00',
    timesUsed: 0
  },
  history: {
    accountAgeDays: 96,
    completedPayouts: 7,
    totalPaidOut: 214000,
    averagePayout: 30500,
    lastPayoutAt: '2026-08-11T20:11:00',
    openDisputes: 0,
    rejectedBefore: 0
  }
},
{
  id: 'wd_1038',
  reference: 'RR-WD-1038',
  requesterType: 'vendor',
  requesterId: 'v_amala',
  requesterName: 'Amala Sky Buffet',
  location: 'Ede — Oke Gada',
  amount: 71500,
  availableBalance: 88000,
  requestedAt: '2026-08-24T21:05:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'Amount between ₦50,000 and ₦250,000',
  bank: {
    bankName: 'Access Bank',
    accountName: 'Amala Sky Ventures',
    accountNumber: '0771205338',
    verifiedAt: '2026-06-30T14:44:00',
    timesUsed: 6
  },
  history: {
    accountAgeDays: 204,
    completedPayouts: 14,
    totalPaidOut: 902000,
    averagePayout: 64400,
    lastPayoutAt: '2026-08-17T12:30:00',
    openDisputes: 0,
    rejectedBefore: 0
  }
},
{
  id: 'wd_1037',
  reference: 'RR-WD-1037',
  requesterType: 'rider',
  requesterId: 'r_segun',
  requesterName: 'Segun Bamidele',
  location: 'Osogbo — Igbona',
  amount: 28400,
  availableBalance: 28400,
  requestedAt: '2026-08-24T19:40:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Known account, under ₦50,000, 22 clean payouts',
  bank: {
    bankName: 'Opay',
    accountName: 'Segun Bamidele',
    accountNumber: '8022114509',
    verifiedAt: '2026-01-19T09:12:00',
    timesUsed: 22
  },
  history: {
    accountAgeDays: 398,
    completedPayouts: 22,
    totalPaidOut: 688000,
    averagePayout: 31200,
    lastPayoutAt: '2026-08-21T17:05:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: { by: 'Automated rule', at: '2026-08-24T19:40:00' }
},
{
  id: 'wd_1036',
  reference: 'RR-WD-1036',
  requesterType: 'vendor',
  requesterId: 'v_mamaput',
  requesterName: 'Mama Put Express',
  location: 'Ikirun — Central',
  amount: 34800,
  availableBalance: 51200,
  requestedAt: '2026-08-24T18:02:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Known account, under ₦50,000, 31 clean payouts',
  bank: {
    bankName: 'First Bank',
    accountName: 'Adijat Lawal',
    accountNumber: '3110029844',
    verifiedAt: '2025-11-08T08:00:00',
    timesUsed: 31
  },
  history: {
    accountAgeDays: 604,
    completedPayouts: 31,
    totalPaidOut: 1244000,
    averagePayout: 40100,
    lastPayoutAt: '2026-08-20T18:00:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: { by: 'Automated rule', at: '2026-08-24T18:02:00' }
},
{
  id: 'wd_1035',
  reference: 'RR-WD-1035',
  requesterType: 'rider',
  requesterId: 'r_bisi',
  requesterName: 'Bisi Ogundipe',
  location: 'Ile-Ife — Sabo',
  amount: 19200,
  availableBalance: 19200,
  requestedAt: '2026-08-24T16:31:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Known account, under ₦50,000, 16 clean payouts',
  bank: {
    bankName: 'PalmPay',
    accountName: 'Bisi Ogundipe',
    accountNumber: '9033118722',
    verifiedAt: '2026-03-14T10:20:00',
    timesUsed: 16
  },
  history: {
    accountAgeDays: 251,
    completedPayouts: 16,
    totalPaidOut: 372000,
    averagePayout: 23250,
    lastPayoutAt: '2026-08-22T15:00:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: { by: 'Automated rule', at: '2026-08-24T16:31:00' }
},
{
  id: 'wd_1034',
  reference: 'RR-WD-1034',
  requesterType: 'vendor',
  requesterId: 'v_grillhouse',
  requesterName: 'Ife Grill House',
  location: 'Ile-Ife — Lagere',
  amount: 226000,
  availableBalance: 226000,
  requestedAt: '2026-08-24T14:10:00',
  tier: 'review',
  status: 'approved',
  routingReason: 'Amount between ₦50,000 and ₦250,000',
  bank: {
    bankName: 'Zenith Bank',
    accountName: 'Ife Grill House Ltd',
    accountNumber: '1099442277',
    verifiedAt: '2026-04-02T09:00:00',
    timesUsed: 12
  },
  history: {
    accountAgeDays: 366,
    completedPayouts: 27,
    totalPaidOut: 4180000,
    averagePayout: 154800,
    lastPayoutAt: '2026-08-15T11:00:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: {
    by: 'Josh Adeyemi',
    at: '2026-08-24T15:02:00',
    reason: 'Balance and order volume reconcile, account details unchanged.'
  }
},
{
  id: 'wd_1033',
  reference: 'RR-WD-1033',
  requesterType: 'rider',
  requesterId: 'r_yusuf',
  requesterName: 'Yusuf Ibrahim',
  location: 'Iwo — Odo Ori',
  amount: 58000,
  availableBalance: 58000,
  requestedAt: '2026-08-24T11:22:00',
  tier: 'review',
  status: 'rejected',
  routingReason: 'First payout to this bank account',
  bank: {
    bankName: 'Moniepoint MFB',
    accountName: 'Halima Ibrahim',
    accountNumber: '8144902231',
    verifiedAt: null,
    timesUsed: 0
  },
  history: {
    accountAgeDays: 58,
    completedPayouts: 3,
    totalPaidOut: 96000,
    averagePayout: 32000,
    lastPayoutAt: '2026-08-09T13:40:00',
    openDisputes: 0,
    rejectedBefore: 1
  },
  decision: {
    by: 'Josh Adeyemi',
    at: '2026-08-24T12:15:00',
    reason:
    'Bank account name does not match the rider’s verified identity. Asked rider to submit an account in his own name.'
  }
},
{
  id: 'wd_1032',
  reference: 'RR-WD-1032',
  requesterType: 'vendor',
  requesterId: 'v_sweetsip',
  requesterName: 'Sweet Sip Smoothies',
  location: 'Osogbo — Testing Ground',
  amount: 42300,
  availableBalance: 42300,
  requestedAt: '2026-08-24T09:15:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Known account, under ₦50,000, 9 clean payouts',
  bank: {
    bankName: 'Wema Bank',
    accountName: 'Sweet Sip Ltd',
    accountNumber: '0288174430',
    verifiedAt: '2026-05-20T10:00:00',
    timesUsed: 9
  },
  history: {
    accountAgeDays: 178,
    completedPayouts: 9,
    totalPaidOut: 388000,
    averagePayout: 43100,
    lastPayoutAt: '2026-08-16T09:30:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: { by: 'Automated rule', at: '2026-08-24T09:15:00' }
},
{
  id: 'wd_1031',
  reference: 'RR-WD-1031',
  requesterType: 'rider',
  requesterId: 'r_femi',
  requesterName: 'Femi Adeoti',
  location: 'Ede — Agip Area',
  amount: 15600,
  availableBalance: 15600,
  requestedAt: '2026-08-23T20:44:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Known account, under ₦50,000, 12 clean payouts',
  bank: {
    bankName: 'Opay',
    accountName: 'Femi Adeoti',
    accountNumber: '8099227741',
    verifiedAt: '2026-04-11T12:00:00',
    timesUsed: 12
  },
  history: {
    accountAgeDays: 141,
    completedPayouts: 12,
    totalPaidOut: 218000,
    averagePayout: 18100,
    lastPayoutAt: '2026-08-20T21:10:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: { by: 'Automated rule', at: '2026-08-23T20:44:00' }
},
{
  id: 'wd_1030',
  reference: 'RR-WD-1030',
  requesterType: 'vendor',
  requesterId: 'v_shawarma',
  requesterName: 'Shawarma Republic',
  location: 'Osogbo — Ola Iya',
  amount: 133400,
  availableBalance: 133400,
  requestedAt: '2026-08-23T17:02:00',
  tier: 'review',
  status: 'approved',
  routingReason: 'Amount between ₦50,000 and ₦250,000',
  bank: {
    bankName: 'UBA',
    accountName: 'Shawarma Republic Ent.',
    accountNumber: '2144098311',
    verifiedAt: '2026-01-30T15:00:00',
    timesUsed: 21
  },
  history: {
    accountAgeDays: 470,
    completedPayouts: 33,
    totalPaidOut: 3980000,
    averagePayout: 120600,
    lastPayoutAt: '2026-08-16T16:00:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: {
    by: 'Ngozi Eze',
    at: '2026-08-23T17:40:00',
    reason: 'Routine payout, history clean.'
  }
},
{
  id: 'wd_1029',
  reference: 'RR-WD-1029',
  requesterType: 'rider',
  requesterId: 'r_lekan',
  requesterName: 'Lekan Salami',
  location: 'Ikire — Market Road',
  amount: 22800,
  availableBalance: 22800,
  requestedAt: '2026-08-23T13:18:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Known account, under ₦50,000, 19 clean payouts',
  bank: {
    bankName: 'PalmPay',
    accountName: 'Lekan Salami',
    accountNumber: '9011882203',
    verifiedAt: '2026-02-02T08:00:00',
    timesUsed: 19
  },
  history: {
    accountAgeDays: 322,
    completedPayouts: 19,
    totalPaidOut: 441000,
    averagePayout: 23200,
    lastPayoutAt: '2026-08-19T14:00:00',
    openDisputes: 0,
    rejectedBefore: 0
  },
  decision: { by: 'Automated rule', at: '2026-08-23T13:18:00' }
}];