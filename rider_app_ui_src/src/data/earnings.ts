import type { DayBar, EarningRow, WithdrawalRow } from '../types';

export const todayDeliveries: EarningRow[] = [
{ id: 'RR-4810', label: 'Iya Basira Amala Spot', area: 'Alekuwodo', time: '2:14 PM', amount: 1850 },
{ id: 'RR-4806', label: 'Sizzle & Spice Grill', area: 'Ilesa Garage', time: '1:02 PM', amount: 3200 },
{ id: 'RR-4799', label: 'Crunchies Osogbo', area: 'Dada Estate', time: '11:48 AM', amount: 2250 },
{ id: 'RR-4791', label: 'Roland Shawarma House', area: 'Oke-Baale', time: '10:20 AM', amount: 1400 },
{ id: 'RR-4788', label: 'Mama Titi Kitchen', area: 'UNIOSUN Campus', time: '9:35 AM', amount: 4100 }];


export const weekBars: DayBar[] = [
{ label: 'M', amount: 9200 },
{ label: 'T', amount: 12400 },
{ label: 'W', amount: 7600 },
{ label: 'T', amount: 15800 },
{ label: 'F', amount: 18200 },
{ label: 'S', amount: 21400 },
{ label: 'S', amount: 12800 }];


export const withdrawals: WithdrawalRow[] = [
{ id: 'w1', amount: 45000, date: 'Aug 18, 2026', status: 'paid' },
{ id: 'w2', amount: 32000, date: 'Aug 11, 2026', status: 'paid' },
{ id: 'w3', amount: 28500, date: 'Aug 4, 2026', status: 'paid' }];