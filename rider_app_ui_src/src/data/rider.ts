import type { DocumentItem } from '../types';

export const rider = {
  name: 'Kunle Adeyemi',
  phone: '+234 803 442 1170',
  riderId: 'RR-RID-2291',
  area: 'Osogbo, Osun State',
  rating: 4.9,
  totalDeliveries: 1284,
  joined: 'March 2025',
  vehicle: {
    type: 'Motorcycle',
    make: 'Bajaj Boxer 100',
    plate: 'OSN-482-KJA',
    color: 'Red / Black',
    year: '2023'
  },
  bank: {
    bankName: 'Opay',
    accountName: 'Kunle Adeyemi',
    accountNumber: '8034421170',
    masked: '•••• 1170'
  }
};

export const documents: DocumentItem[] = [
{ id: 'license', label: "Driver's licence", status: 'verified', detail: 'Expires Nov 2028' },
{ id: 'nin', label: 'NIN slip', status: 'verified', detail: 'Verified Mar 2025' },
{ id: 'vehicle', label: 'Vehicle registration', status: 'verified', detail: 'OSN-482-KJA' },
{ id: 'insurance', label: 'Bike insurance', status: 'pending', detail: 'Uploaded 2 days ago' },
{ id: 'photo', label: 'Profile photo', status: 'verified', detail: 'Updated Jun 2026' }];