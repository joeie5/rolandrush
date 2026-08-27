import type { ServiceZone } from '../types';

// serviceZones below is still real mock data — it's the source for the
// phase2 Analytics page only (explicitly out of scope, left on mock data
// per the original admin-wiring brief). feeRules and adminTeam mock
// arrays that used to live in this file are gone — the live equivalents
// (same names) now come from AdminContext, backed by real
// delivery_fee_rules / admin_users tables.
export const serviceZones: ServiceZone[] = [
{
  id: 'z_osogbo',
  name: 'Osogbo Central',
  city: 'Osogbo',
  status: 'live',
  vendors: 74,
  riders: 41,
  orders7d: 2418,
  baseFee: 900,
  radiusKm: 8
},
{
  id: 'z_ife',
  name: 'Ile-Ife',
  city: 'Ile-Ife',
  status: 'live',
  vendors: 46,
  riders: 22,
  orders7d: 1290,
  baseFee: 1100,
  radiusKm: 9
},
{
  id: 'z_ilesa',
  name: 'Ilesa',
  city: 'Ilesa',
  status: 'live',
  vendors: 28,
  riders: 14,
  orders7d: 620,
  baseFee: 800,
  radiusKm: 7
},
{
  id: 'z_ede',
  name: 'Ede',
  city: 'Ede',
  status: 'live',
  vendors: 19,
  riders: 9,
  orders7d: 344,
  baseFee: 700,
  radiusKm: 6
},
{
  id: 'z_ikirun',
  name: 'Ikirun',
  city: 'Ikirun',
  status: 'live',
  vendors: 12,
  riders: 6,
  orders7d: 188,
  baseFee: 700,
  radiusKm: 5
},
{
  id: 'z_iwo',
  name: 'Iwo',
  city: 'Iwo',
  status: 'paused',
  vendors: 8,
  riders: 3,
  orders7d: 41,
  baseFee: 800,
  radiusKm: 6
},
{
  id: 'z_gbongan',
  name: 'Gbongan',
  city: 'Gbongan',
  status: 'planned',
  vendors: 2,
  riders: 2,
  orders7d: 0,
  baseFee: 750,
  radiusKm: 5
},
{
  id: 'z_ikire',
  name: 'Ikire',
  city: 'Ikire',
  status: 'planned',
  vendors: 3,
  riders: 2,
  orders7d: 0,
  baseFee: 750,
  radiusKm: 5
}];

export const ROLE_PERMISSIONS: {
  role: string;
  approvePayouts: string;
  refunds: string;
  accounts: string;
  config: string;
}[] = [
{
  role: 'Founder',
  approvePayouts: 'Any amount',
  refunds: 'Any amount',
  accounts: 'Suspend & ban',
  config: 'Full access'
},
{
  role: 'Ops Lead',
  approvePayouts: 'Up to ₦250,000',
  refunds: 'Up to ₦50,000',
  accounts: 'Suspend only',
  config: 'Fees & zones'
},
{
  role: 'Finance',
  approvePayouts: 'Any amount',
  refunds: 'Up to ₦100,000',
  accounts: 'View only',
  config: 'View only'
},
{
  role: 'Support Agent',
  approvePayouts: 'None',
  refunds: 'Up to ₦10,000',
  accounts: 'View only',
  config: 'View only'
}];