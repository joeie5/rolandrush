import type { AdCampaign, Dispute, LedgerEntry, PromoCode } from '../types';

export const disputes: Dispute[] = [
{
  id: 'dp_77',
  orderCode: 'RR-88213',
  raisedBy: 'Adaeze Nwosu',
  party: 'customer',
  openedAt: '2026-08-24T20:11:00',
  category: 'Missing items',
  tier: 'urgent',
  status: 'open',
  amountAtRisk: 18400,
  summary:
  'Rider payout held while vendor and customer disagree on what was packed.'
},
{
  id: 'dp_76',
  orderCode: 'RR-88190',
  raisedBy: 'Ife Grill House',
  party: 'vendor',
  openedAt: '2026-08-24T15:02:00',
  category: 'Chargeback',
  tier: 'urgent',
  status: 'open',
  amountAtRisk: 42000,
  summary: 'Card chargeback filed 6 days after a delivered order.'
},
{
  id: 'dp_75',
  orderCode: 'RR-88144',
  raisedBy: 'Tunde Afolabi',
  party: 'rider',
  openedAt: '2026-08-23T19:20:00',
  category: 'Fee disagreement',
  tier: 'review',
  status: 'waiting',
  amountAtRisk: 2400,
  summary: 'Rider says the trip distance was under-calculated by 3km.'
},
{
  id: 'dp_74',
  orderCode: 'RR-88102',
  raisedBy: 'Nike Balogun',
  party: 'customer',
  openedAt: '2026-08-21T14:10:00',
  category: 'Refund abuse review',
  tier: 'review',
  status: 'waiting',
  amountAtRisk: 12800,
  summary: '14 refund requests in 30 days from the same customer.'
},
{
  id: 'dp_73',
  orderCode: 'RR-88044',
  raisedBy: 'Seyi Ogunbiyi',
  party: 'customer',
  openedAt: '2026-08-19T11:02:00',
  category: 'Late delivery',
  tier: 'auto',
  status: 'resolved',
  amountAtRisk: 700,
  summary: 'Delivery fee auto-refunded under the 60-minute guarantee.'
}];


export const ledger: LedgerEntry[] = [
{
  id: 'lg_9',
  date: '2026-08-25T09:52:31',
  reference: 'RR-88240',
  type: 'order',
  party: 'Folake Adebayo',
  inflow: 15250,
  outflow: 0,
  balance: 4182400
},
{
  id: 'lg_8',
  date: '2026-08-25T08:41:20',
  reference: 'RR-88231',
  type: 'payout',
  party: 'Amala Sky Buffet',
  inflow: 0,
  outflow: 9265,
  balance: 4167150
},
{
  id: 'lg_7',
  date: '2026-08-25T08:41:20',
  reference: 'RR-88231',
  type: 'commission',
  party: 'RolandRush',
  inflow: 1635,
  outflow: 0,
  balance: 4176415
},
{
  id: 'lg_6',
  date: '2026-08-24T20:41:00',
  reference: 'RR-88213',
  type: 'refund',
  party: 'Adaeze Nwosu',
  inflow: 0,
  outflow: 1600,
  balance: 4174780
},
{
  id: 'lg_5',
  date: '2026-08-24T19:40:00',
  reference: 'RR-WD-1037',
  type: 'payout',
  party: 'Segun Bamidele',
  inflow: 0,
  outflow: 28400,
  balance: 4176380
},
{
  id: 'lg_4',
  date: '2026-08-24T18:15:00',
  reference: 'RR-88205',
  type: 'refund',
  party: 'Seyi Ogunbiyi',
  inflow: 0,
  outflow: 4350,
  balance: 4204780
},
{
  id: 'lg_3',
  date: '2026-08-24T15:02:00',
  reference: 'RR-WD-1034',
  type: 'payout',
  party: 'Ife Grill House',
  inflow: 0,
  outflow: 226000,
  balance: 4209130
},
{
  id: 'lg_2',
  date: '2026-08-24T12:00:00',
  reference: 'AD-2201',
  type: 'ad_spend',
  party: 'Shawarma Republic',
  inflow: 35000,
  outflow: 0,
  balance: 4435130
},
{
  id: 'lg_1',
  date: '2026-08-24T09:15:00',
  reference: 'RR-WD-1032',
  type: 'payout',
  party: 'Sweet Sip Smoothies',
  inflow: 0,
  outflow: 42300,
  balance: 4400130
}];


export const promoCodes: PromoCode[] = [
{
  id: 'pc_1',
  code: 'RUSH10',
  type: 'percent',
  value: 10,
  redemptions: 1842,
  cap: 5000,
  expiresAt: '2026-09-30T23:59:00',
  status: 'active'
},
{
  id: 'pc_2',
  code: 'IFEFREE',
  type: 'free_delivery',
  value: 0,
  redemptions: 612,
  cap: 1000,
  expiresAt: '2026-09-05T23:59:00',
  status: 'active'
},
{
  id: 'pc_3',
  code: 'NEWBUKA',
  type: 'fixed',
  value: 1000,
  redemptions: 0,
  cap: 2000,
  expiresAt: '2026-10-15T23:59:00',
  status: 'scheduled'
},
{
  id: 'pc_4',
  code: 'EIDRUSH',
  type: 'percent',
  value: 15,
  redemptions: 2988,
  cap: 3000,
  expiresAt: '2026-06-20T23:59:00',
  status: 'expired'
}];


export const adCampaigns: AdCampaign[] = [
{
  id: 'ad_9',
  vendor: 'Pepper Pot Iwo',
  title: '“₦500 full plate” feed promo',
  budget: 20000,
  spend: 0,
  impressions: 0,
  clicks: 0,
  tier: 'urgent',
  status: 'pending',
  submittedAt: '2026-08-25T07:20:00'
},
{
  id: 'ad_8',
  vendor: 'The Bowl Company',
  title: 'Weekend bowl bundle — homepage banner',
  budget: 60000,
  spend: 0,
  impressions: 0,
  clicks: 0,
  tier: 'review',
  status: 'pending',
  submittedAt: '2026-08-24T17:40:00'
},
{
  id: 'ad_7',
  vendor: 'Shawarma Republic',
  title: 'Late-night shawarma push',
  budget: 45000,
  spend: 35000,
  impressions: 128400,
  clicks: 4210,
  tier: 'auto',
  status: 'running',
  submittedAt: '2026-08-20T10:00:00'
},
{
  id: 'ad_6',
  vendor: 'Iya Basira Kitchen',
  title: 'Ofada Friday',
  budget: 30000,
  spend: 30000,
  impressions: 98200,
  clicks: 3980,
  tier: 'auto',
  status: 'finished',
  submittedAt: '2026-08-12T10:00:00'
}];


export const ordersPerDay = [
{ day: 'Tue', orders: 612, gmv: 5.9 },
{ day: 'Wed', orders: 648, gmv: 6.2 },
{ day: 'Thu', orders: 701, gmv: 6.8 },
{ day: 'Fri', orders: 884, gmv: 8.9 },
{ day: 'Sat', orders: 942, gmv: 9.6 },
{ day: 'Sun', orders: 811, gmv: 8.1 },
{ day: 'Mon', orders: 588, gmv: 5.6 }];


export const supplyTrend = [
{ week: 'W26', vendors: 142, riders: 71 },
{ week: 'W27', vendors: 148, riders: 74 },
{ week: 'W28', vendors: 157, riders: 79 },
{ week: 'W29', vendors: 166, riders: 84 },
{ week: 'W30', vendors: 174, riders: 88 },
{ week: 'W31', vendors: 182, riders: 93 },
{ week: 'W32', vendors: 190, riders: 97 }];