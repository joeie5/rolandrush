export type JobTag = 'nearby' | 'high-pay';

export interface Job {
  id: string;
  restaurant: string;
  restaurantArea: string;
  pickupLat: number;
  pickupLng: number;
  dropoffArea: string;
  dropoffLat: number;
  dropoffLng: number;
  distanceKm: number;
  payout: number;
  items: number;
  minutes: number;
  customerName: string;
  customerPhone: string;
  restaurantPhone: string;
  tags: JobTag[];
}

export type DeliveryStep = 0 | 1 | 2 | 3;

export interface EarningRow {
  id: string;
  label: string;
  area: string;
  time: string;
  amount: number;
}

export interface DayBar {
  label: string;
  amount: number;
}

export interface DocumentItem {
  id: string;
  label: string;
  status: 'verified' | 'pending' | 'missing';
  detail: string;
}

export interface WithdrawalRow {
  id: string;
  amount: number;
  date: string;
  status: 'paid' | 'processing';
}