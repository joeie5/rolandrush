import type { AdminUser, FeeRule, ServiceZone } from '../types';

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


export const feeRules: FeeRule[] = [
{
  id: 'f_osogbo',
  name: 'Osogbo standard',
  zone: 'Osogbo Central',
  baseFee: 900,
  perKm: 120,
  minFee: 700,
  maxFee: 2500,
  surgeMultiplier: 1,
  active: true
},
{
  id: 'f_osogbo_peak',
  name: 'Osogbo evening peak (6–9pm)',
  zone: 'Osogbo Central',
  baseFee: 900,
  perKm: 120,
  minFee: 900,
  maxFee: 3200,
  surgeMultiplier: 1.3,
  active: true
},
{
  id: 'f_ife',
  name: 'Ile-Ife standard',
  zone: 'Ile-Ife',
  baseFee: 1100,
  perKm: 140,
  minFee: 900,
  maxFee: 3000,
  surgeMultiplier: 1,
  active: true
},
{
  id: 'f_ilesa',
  name: 'Ilesa standard',
  zone: 'Ilesa',
  baseFee: 800,
  perKm: 110,
  minFee: 700,
  maxFee: 2400,
  surgeMultiplier: 1,
  active: true
},
{
  id: 'f_ede',
  name: 'Ede standard',
  zone: 'Ede',
  baseFee: 700,
  perKm: 110,
  minFee: 600,
  maxFee: 2200,
  surgeMultiplier: 1,
  active: true
},
{
  id: 'f_rain',
  name: 'Rain surcharge (all live zones)',
  zone: 'All live zones',
  baseFee: 0,
  perKm: 0,
  minFee: 0,
  maxFee: 500,
  surgeMultiplier: 1.15,
  active: false
}];


export const adminTeam: AdminUser[] = [
{
  id: 'u_josh',
  name: 'Josh Adeyemi',
  email: 'josh@rolandrush.ng',
  role: 'Founder',
  status: 'active',
  lastActiveAt: '2026-08-25T10:38:00',
  actions30d: 412
},
{
  id: 'u_ngozi',
  name: 'Ngozi Eze',
  email: 'ngozi@rolandrush.ng',
  role: 'Ops Lead',
  status: 'active',
  lastActiveAt: '2026-08-25T09:12:00',
  actions30d: 188
},
{
  id: 'u_kunle',
  name: 'Kunle Bello',
  email: 'kunle@rolandrush.ng',
  role: 'Support Agent',
  status: 'active',
  lastActiveAt: '2026-08-24T21:02:00',
  actions30d: 96
},
{
  id: 'u_amaka',
  name: 'Amaka Duru',
  email: 'amaka@rolandrush.ng',
  role: 'Finance',
  status: 'invited',
  lastActiveAt: '2026-08-22T17:12:00',
  actions30d: 0
},
{
  id: 'u_deji',
  name: 'Deji Rotimi',
  email: 'deji@rolandrush.ng',
  role: 'Support Agent',
  status: 'disabled',
  lastActiveAt: '2026-06-30T14:00:00',
  actions30d: 0
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