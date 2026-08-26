import type { Order } from '../types';

export const orders: Order[] = [
{
  id: 'o_88240',
  code: 'RR-88240',
  placedAt: '2026-08-25T09:52:00',
  status: 'in_transit',
  tier: 'urgent',
  customerId: 'c_folake',
  customerName: 'Folake Adebayo',
  customerPhone: '+234 803 114 2288',
  address: '14 Oke Fia Road, Osogbo',
  zone: 'Osogbo Central',
  vendorId: 'v_thebowl',
  vendorName: 'The Bowl Company',
  riderId: 'r_tunde',
  riderName: 'Tunde Afolabi',
  lines: [
  { name: 'Jollof rice bowl (large)', qty: 2, price: 4500 },
  { name: 'Peppered turkey', qty: 1, price: 3800 },
  { name: 'Chapman (50cl)', qty: 2, price: 1200 }],

  totals: {
    subtotal: 14000,
    deliveryFee: 900,
    serviceFee: 350,
    discount: 0,
    total: 15250
  },
  payment: {
    method: 'card',
    status: 'paid',
    reference: 'PSK-9F21A8',
    settledAt: '2026-08-25T09:52:31'
  },
  stalledMinutes: 38,
  note: 'Rider has not moved for 38 minutes — flagged by the stall rule.',
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Folake Adebayo',
    at: '2026-08-25T09:52:00',
    state: 'done',
    detail: '3 items · ₦15,250 · card'
  },
  {
    id: 't2',
    label: 'Payment authorised',
    actor: 'Paystack',
    at: '2026-08-25T09:52:31',
    state: 'done',
    automated: true,
    detail: 'Reference PSK-9F21A8'
  },
  {
    id: 't3',
    label: 'Vendor accepted',
    actor: 'The Bowl Company',
    at: '2026-08-25T09:54:12',
    state: 'done',
    detail: 'Prep estimate 18 minutes'
  },
  {
    id: 't4',
    label: 'Rider assigned',
    actor: 'Dispatch engine',
    at: '2026-08-25T09:58:40',
    state: 'done',
    automated: true,
    detail: 'Tunde Afolabi · 1.2km from vendor'
  },
  {
    id: 't5',
    label: 'Picked up',
    actor: 'Tunde Afolabi',
    at: '2026-08-25T10:14:05',
    state: 'done'
  },
  {
    id: 't6',
    label: 'In transit — stalled',
    actor: 'Tunde Afolabi',
    at: '2026-08-25T10:16:00',
    state: 'failed',
    detail: 'No GPS movement since 10:16am. Customer has messaged twice.'
  },
  {
    id: 't7',
    label: 'Delivered',
    actor: 'Rider',
    at: null,
    state: 'pending'
  },
  {
    id: 't8',
    label: 'Vendor payout queued',
    actor: 'Ledger',
    at: null,
    state: 'pending'
  }],

  chat: [
  {
    id: 'm1',
    from: 'customer',
    name: 'Folake Adebayo',
    at: '2026-08-25T10:31:00',
    body: 'Hello, the app says my rider is 5 minutes away but nothing has changed for half an hour.'
  },
  {
    id: 'm2',
    from: 'customer',
    name: 'Folake Adebayo',
    at: '2026-08-25T10:44:00',
    body: 'Please can someone call the rider? The food will be cold.'
  },
  {
    id: 'm3',
    from: 'rider',
    name: 'Tunde Afolabi',
    at: '2026-08-25T10:46:00',
    body: 'My bike has a flat tyre at Ola Iya junction. Trying to fix it now.'
  }]

},
{
  id: 'o_88237',
  code: 'RR-88237',
  placedAt: '2026-08-25T09:20:00',
  status: 'awaiting_rider',
  tier: 'review',
  customerId: 'c_ibrahim',
  customerName: 'Ibrahim Salaudeen',
  customerPhone: '+234 811 552 7710',
  address: '7 Mayfair Close, Ile-Ife',
  zone: 'Ile-Ife',
  vendorId: 'v_grillhouse',
  vendorName: 'Ife Grill House',
  riderId: null,
  riderName: null,
  lines: [
  { name: 'Suya platter', qty: 1, price: 6500 },
  { name: 'Plantain side', qty: 2, price: 1000 }],

  totals: {
    subtotal: 8500,
    deliveryFee: 1100,
    serviceFee: 250,
    discount: 500,
    total: 9350
  },
  payment: {
    method: 'transfer',
    status: 'paid',
    reference: 'PSK-77BB01',
    settledAt: '2026-08-25T09:21:10'
  },
  stalledMinutes: 22,
  note: 'No rider accepted after 4 dispatch rounds.',
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Ibrahim Salaudeen',
    at: '2026-08-25T09:20:00',
    state: 'done'
  },
  {
    id: 't2',
    label: 'Payment settled',
    actor: 'Paystack',
    at: '2026-08-25T09:21:10',
    state: 'done',
    automated: true
  },
  {
    id: 't3',
    label: 'Vendor accepted',
    actor: 'Ife Grill House',
    at: '2026-08-25T09:23:44',
    state: 'done'
  },
  {
    id: 't4',
    label: 'Awaiting rider — 4 rounds, no acceptance',
    actor: 'Dispatch engine',
    at: '2026-08-25T09:38:00',
    state: 'active',
    automated: true,
    detail: 'Only 2 riders online in Ile-Ife zone.'
  },
  { id: 't5', label: 'Picked up', actor: 'Rider', at: null, state: 'pending' },
  { id: 't6', label: 'Delivered', actor: 'Rider', at: null, state: 'pending' }],

  chat: [
  {
    id: 'm1',
    from: 'vendor',
    name: 'Ife Grill House',
    at: '2026-08-25T09:40:00',
    body: 'Food is ready and packed, waiting for a rider.'
  }]

},
{
  id: 'o_88231',
  code: 'RR-88231',
  placedAt: '2026-08-25T08:05:00',
  status: 'delivered',
  tier: 'auto',
  customerId: 'c_tolu',
  customerName: 'Tolu Ariyo',
  customerPhone: '+234 806 220 9931',
  address: '22 Ereja Square, Ilesa',
  zone: 'Ilesa',
  vendorId: 'v_amala',
  vendorName: 'Amala Sky Buffet',
  riderId: 'r_kemi',
  riderName: 'Kemi Oyelaran',
  lines: [
  { name: 'Amala & ewedu combo', qty: 2, price: 3200 },
  { name: 'Assorted meat', qty: 3, price: 1500 }],

  totals: {
    subtotal: 10900,
    deliveryFee: 800,
    serviceFee: 300,
    discount: 0,
    total: 12000
  },
  payment: {
    method: 'wallet',
    status: 'paid',
    reference: 'RRW-448120',
    settledAt: '2026-08-25T08:05:20'
  },
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Tolu Ariyo',
    at: '2026-08-25T08:05:00',
    state: 'done'
  },
  {
    id: 't2',
    label: 'Wallet debited',
    actor: 'RolandRush Wallet',
    at: '2026-08-25T08:05:20',
    state: 'done',
    automated: true
  },
  {
    id: 't3',
    label: 'Vendor accepted',
    actor: 'Amala Sky Buffet',
    at: '2026-08-25T08:06:31',
    state: 'done'
  },
  {
    id: 't4',
    label: 'Rider assigned',
    actor: 'Dispatch engine',
    at: '2026-08-25T08:09:02',
    state: 'done',
    automated: true,
    detail: 'Kemi Oyelaran'
  },
  {
    id: 't5',
    label: 'Picked up',
    actor: 'Kemi Oyelaran',
    at: '2026-08-25T08:22:40',
    state: 'done'
  },
  {
    id: 't6',
    label: 'Delivered',
    actor: 'Kemi Oyelaran',
    at: '2026-08-25T08:41:12',
    state: 'done',
    detail: 'Confirmed with delivery code 4417'
  },
  {
    id: 't7',
    label: 'Vendor earnings released',
    actor: 'Ledger',
    at: '2026-08-25T08:41:20',
    state: 'done',
    automated: true,
    detail: '₦9,265 after 15% commission'
  }],

  chat: []
},
{
  id: 'o_88213',
  code: 'RR-88213',
  placedAt: '2026-08-24T19:30:00',
  status: 'refunded',
  tier: 'review',
  customerId: 'c_adaeze',
  customerName: 'Adaeze Nwosu',
  customerPhone: '+234 809 771 0044',
  address: '5 Igbona Estate, Osogbo',
  zone: 'Osogbo Central',
  vendorId: 'v_shawarma',
  vendorName: 'Shawarma Republic',
  riderId: 'r_tunde',
  riderName: 'Tunde Afolabi',
  lines: [
  { name: 'Double chicken shawarma', qty: 2, price: 4200 },
  { name: 'Beef sausage roll', qty: 4, price: 800 },
  { name: 'Coke (35cl)', qty: 2, price: 700 }],

  totals: {
    subtotal: 12980,
    deliveryFee: 900,
    serviceFee: 320,
    discount: 0,
    total: 14200
  },
  payment: {
    method: 'card',
    status: 'refunded',
    reference: 'PSK-3C0912',
    settledAt: '2026-08-24T20:41:00'
  },
  note: 'Two sausage rolls missing on arrival — rider dispute open.',
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Adaeze Nwosu',
    at: '2026-08-24T19:30:00',
    state: 'done'
  },
  {
    id: 't2',
    label: 'Vendor accepted',
    actor: 'Shawarma Republic',
    at: '2026-08-24T19:32:00',
    state: 'done'
  },
  {
    id: 't3',
    label: 'Rider assigned',
    actor: 'Dispatch engine',
    at: '2026-08-24T19:36:00',
    state: 'done',
    automated: true
  },
  {
    id: 't4',
    label: 'Delivered',
    actor: 'Tunde Afolabi',
    at: '2026-08-24T20:04:00',
    state: 'done'
  },
  {
    id: 't5',
    label: 'Customer reported missing items',
    actor: 'Adaeze Nwosu',
    at: '2026-08-24T20:11:00',
    state: 'failed',
    detail: '2 × beef sausage roll'
  },
  {
    id: 't6',
    label: 'Partial refund issued',
    actor: 'Josh Adeyemi',
    at: '2026-08-24T20:41:00',
    state: 'done',
    detail: '₦1,600 refunded to card · reason: missing items confirmed by vendor'
  },
  {
    id: 't7',
    label: 'Rider payout held pending dispute',
    actor: 'Ledger',
    at: '2026-08-24T20:41:05',
    state: 'active',
    automated: true
  }],

  chat: [
  {
    id: 'm1',
    from: 'customer',
    name: 'Adaeze Nwosu',
    at: '2026-08-24T20:11:00',
    body: 'Two of the sausage rolls are not in the bag.'
  },
  {
    id: 'm2',
    from: 'vendor',
    name: 'Shawarma Republic',
    at: '2026-08-24T20:22:00',
    body: 'We packed 4. The rider collected the bag sealed.'
  },
  {
    id: 'm3',
    from: 'support',
    name: 'Josh Adeyemi',
    at: '2026-08-24T20:40:00',
    body: 'Refunding ₦1,600 to the customer now. Holding rider payout while we check the pickup photo.'
  }]

},
{
  id: 'o_88205',
  code: 'RR-88205',
  placedAt: '2026-08-24T18:12:00',
  status: 'cancelled',
  tier: 'auto',
  customerId: 'c_seyi',
  customerName: 'Seyi Ogunbiyi',
  customerPhone: '+234 802 448 1120',
  address: '3 Oke Gada, Ede',
  zone: 'Ede',
  vendorId: 'v_mamaput',
  vendorName: 'Mama Put Express',
  riderId: null,
  riderName: null,
  lines: [{ name: 'Efo riro & semo', qty: 1, price: 3500 }],
  totals: {
    subtotal: 3500,
    deliveryFee: 700,
    serviceFee: 150,
    discount: 0,
    total: 4350
  },
  payment: {
    method: 'card',
    status: 'refunded',
    reference: 'PSK-118DD2',
    settledAt: '2026-08-24T18:15:00'
  },
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Seyi Ogunbiyi',
    at: '2026-08-24T18:12:00',
    state: 'done'
  },
  {
    id: 't2',
    label: 'Vendor rejected — kitchen closed',
    actor: 'Mama Put Express',
    at: '2026-08-24T18:14:20',
    state: 'failed'
  },
  {
    id: 't3',
    label: 'Auto-refunded in full',
    actor: 'Refund rule',
    at: '2026-08-24T18:15:00',
    state: 'done',
    automated: true,
    detail: 'Vendor rejection within 5 minutes → automatic full refund'
  }],

  chat: []
},
{
  id: 'o_88198',
  code: 'RR-88198',
  placedAt: '2026-08-24T13:44:00',
  status: 'delivered',
  tier: 'auto',
  customerId: 'c_folake',
  customerName: 'Folake Adebayo',
  customerPhone: '+234 803 114 2288',
  address: '14 Oke Fia Road, Osogbo',
  zone: 'Osogbo Central',
  vendorId: 'v_sweetsip',
  vendorName: 'Sweet Sip Smoothies',
  riderId: 'r_segun',
  riderName: 'Segun Bamidele',
  lines: [{ name: 'Mango-berry smoothie (large)', qty: 3, price: 2500 }],
  totals: {
    subtotal: 7500,
    deliveryFee: 800,
    serviceFee: 200,
    discount: 750,
    total: 7750
  },
  payment: {
    method: 'card',
    status: 'paid',
    reference: 'PSK-55A210',
    settledAt: '2026-08-24T13:44:30'
  },
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Folake Adebayo',
    at: '2026-08-24T13:44:00',
    state: 'done',
    detail: 'Promo RUSH10 applied (−₦750)'
  },
  {
    id: 't2',
    label: 'Vendor accepted',
    actor: 'Sweet Sip Smoothies',
    at: '2026-08-24T13:45:10',
    state: 'done'
  },
  {
    id: 't3',
    label: 'Rider assigned',
    actor: 'Dispatch engine',
    at: '2026-08-24T13:47:00',
    state: 'done',
    automated: true
  },
  {
    id: 't4',
    label: 'Delivered',
    actor: 'Segun Bamidele',
    at: '2026-08-24T14:09:00',
    state: 'done'
  },
  {
    id: 't5',
    label: 'Vendor earnings released',
    actor: 'Ledger',
    at: '2026-08-24T14:09:10',
    state: 'done',
    automated: true
  }],

  chat: []
},
{
  id: 'o_88186',
  code: 'RR-88186',
  placedAt: '2026-08-24T12:02:00',
  status: 'delivered',
  tier: 'auto',
  customerId: 'c_ibrahim',
  customerName: 'Ibrahim Salaudeen',
  customerPhone: '+234 811 552 7710',
  address: '7 Mayfair Close, Ile-Ife',
  zone: 'Ile-Ife',
  vendorId: 'v_iyabasira',
  vendorName: 'Iya Basira Kitchen',
  riderId: 'r_bisi',
  riderName: 'Bisi Ogundipe',
  lines: [
  { name: 'Ofada rice & ayamase', qty: 2, price: 4000 },
  { name: 'Moin moin', qty: 2, price: 700 }],

  totals: {
    subtotal: 9400,
    deliveryFee: 1000,
    serviceFee: 250,
    discount: 0,
    total: 10650
  },
  payment: {
    method: 'transfer',
    status: 'paid',
    reference: 'PSK-9910FF',
    settledAt: '2026-08-24T12:03:00'
  },
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Ibrahim Salaudeen',
    at: '2026-08-24T12:02:00',
    state: 'done'
  },
  {
    id: 't2',
    label: 'Vendor accepted',
    actor: 'Iya Basira Kitchen',
    at: '2026-08-24T12:04:00',
    state: 'done'
  },
  {
    id: 't3',
    label: 'Rider assigned',
    actor: 'Dispatch engine',
    at: '2026-08-24T12:08:00',
    state: 'done',
    automated: true
  },
  {
    id: 't4',
    label: 'Delivered',
    actor: 'Bisi Ogundipe',
    at: '2026-08-24T12:38:00',
    state: 'done'
  }],

  chat: []
},
{
  id: 'o_88174',
  code: 'RR-88174',
  placedAt: '2026-08-23T20:15:00',
  status: 'delivered',
  tier: 'auto',
  customerId: 'c_adaeze',
  customerName: 'Adaeze Nwosu',
  customerPhone: '+234 809 771 0044',
  address: '5 Igbona Estate, Osogbo',
  zone: 'Osogbo Central',
  vendorId: 'v_thebowl',
  vendorName: 'The Bowl Company',
  riderId: 'r_lekan',
  riderName: 'Lekan Salami',
  lines: [{ name: 'Fried rice bowl', qty: 1, price: 4200 }],
  totals: {
    subtotal: 4200,
    deliveryFee: 900,
    serviceFee: 150,
    discount: 0,
    total: 5250
  },
  payment: {
    method: 'cash',
    status: 'paid',
    reference: 'CASH-88174',
    settledAt: '2026-08-23T20:52:00'
  },
  timeline: [
  {
    id: 't1',
    label: 'Order placed',
    actor: 'Adaeze Nwosu',
    at: '2026-08-23T20:15:00',
    state: 'done'
  },
  {
    id: 't2',
    label: 'Vendor accepted',
    actor: 'The Bowl Company',
    at: '2026-08-23T20:17:00',
    state: 'done'
  },
  {
    id: 't3',
    label: 'Delivered — cash collected',
    actor: 'Lekan Salami',
    at: '2026-08-23T20:52:00',
    state: 'done'
  }],

  chat: []
}];