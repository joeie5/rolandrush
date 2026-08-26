import type { VerificationSubmission } from '../types';

const ID_CARD = "/f77deb32-4935-48ad-b23e-c18cb2c2bbdb.jpg";

const CAC_CERT = "/0468928e-1267-4739-8a5b-050316849465.jpg";

const LICENSE = "/855cceb7-5fe2-4476-b8a0-654b382020a8.jpg";

const VEHICLE = "/d29575d8-6fed-4cc4-98f3-d7908e983de5.jpg";


export const vendorSubmissions: VerificationSubmission[] = [
{
  id: 'vs_301',
  subjectType: 'vendor',
  subjectName: 'Buka Fresh Gbongan',
  contact: 'Rasheed Oyeleke · +234 806 001 5528',
  zone: 'Gbongan',
  submittedAt: '2026-08-25T07:30:00',
  tier: 'urgent',
  status: 'pending',
  routingReason: 'CAC number could not be matched in the registry',
  flagReason:
  'The CAC number submitted is already attached to a vendor suspended for item substitution.',
  documents: [
  {
    label: 'CAC number',
    value: 'RC-2519004',
    kind: 'text',
    checks: [
    { label: 'Format valid', passed: true },
    { label: 'Found in registry', passed: false },
    { label: 'Not reused by another vendor', passed: false }]

  },
  {
    label: 'Registration certificate',
    value: 'buka-fresh-cac.jpg',
    kind: 'image',
    preview: CAC_CERT,
    checks: [
    { label: 'Legible scan', passed: true },
    { label: 'Business name matches application', passed: false }]

  },
  {
    label: 'Owner ID',
    value: 'NIN ending 4417',
    kind: 'image',
    preview: ID_CARD,
    checks: [
    { label: 'Face matches selfie', passed: true },
    { label: 'Name matches CAC owner', passed: true }]

  }]

},
{
  id: 'vs_300',
  subjectType: 'vendor',
  subjectName: 'Pepper Pot Iwo',
  contact: 'Halima Sanni · +234 810 220 1174',
  zone: 'Iwo',
  submittedAt: '2026-08-24T16:20:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'First-time vendor in a paused zone',
  documents: [
  {
    label: 'CAC number',
    value: 'RC-2510882',
    kind: 'text',
    checks: [
    { label: 'Format valid', passed: true },
    { label: 'Found in registry', passed: true }]

  },
  {
    label: 'Registration certificate',
    value: 'pepper-pot-cac.jpg',
    kind: 'image',
    preview: CAC_CERT,
    checks: [{ label: 'Legible scan', passed: true }]
  },
  {
    label: 'Owner ID',
    value: 'NIN ending 9021',
    kind: 'image',
    preview: ID_CARD,
    checks: [
    { label: 'Face matches selfie', passed: true },
    { label: 'Name matches CAC owner', passed: true }]

  }]

},
{
  id: 'vs_299',
  subjectType: 'vendor',
  subjectName: 'Ilesa Suya Spot',
  contact: 'Ahmed Bello · +234 803 118 7742',
  zone: 'Ilesa',
  submittedAt: '2026-08-24T11:05:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'Kitchen photos missing from the application',
  documents: [
  {
    label: 'CAC number',
    value: 'RC-2488120',
    kind: 'text',
    checks: [
    { label: 'Format valid', passed: true },
    { label: 'Found in registry', passed: true }]

  },
  {
    label: 'Owner ID',
    value: 'NIN ending 1180',
    kind: 'image',
    preview: ID_CARD,
    checks: [{ label: 'Face matches selfie', passed: true }]
  }]

},
{
  id: 'vs_298',
  subjectType: 'vendor',
  subjectName: 'Sweet Sip Smoothies',
  contact: 'Temi Bankole · +234 807 330 5521',
  zone: 'Osogbo Central',
  submittedAt: '2026-08-24T09:40:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'CAC verified in registry, ID matched, zone already live',
  documents: [
  {
    label: 'CAC number',
    value: 'RC-2401119',
    kind: 'text',
    checks: [
    { label: 'Format valid', passed: true },
    { label: 'Found in registry', passed: true }]

  },
  {
    label: 'Owner ID',
    value: 'NIN ending 3390',
    kind: 'image',
    preview: ID_CARD,
    checks: [{ label: 'Face matches selfie', passed: true }]
  }],

  decision: { by: 'Automated rule', at: '2026-08-24T09:41:00' }
},
{
  id: 'vs_297',
  subjectType: 'vendor',
  subjectName: 'Osogbo Pastry Lab',
  contact: 'Bola Adigun · +234 805 220 4471',
  zone: 'Osogbo Central',
  submittedAt: '2026-08-23T14:10:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'CAC verified in registry, ID matched, zone already live',
  documents: [
  {
    label: 'CAC number',
    value: 'RC-2377810',
    kind: 'text',
    checks: [{ label: 'Found in registry', passed: true }]
  }],

  decision: { by: 'Automated rule', at: '2026-08-23T14:11:00' }
}];


export const riderSubmissions: VerificationSubmission[] = [
{
  id: 'rs_412',
  subjectType: 'rider',
  subjectName: 'Dare Fashola',
  contact: '+234 803 771 2290 · Osogbo Central',
  zone: 'Osogbo Central',
  submittedAt: '2026-08-25T06:40:00',
  tier: 'urgent',
  status: 'pending',
  routingReason: 'Licence expired and vehicle papers do not match the plate',
  flagReason:
  'Driver’s licence expired in June 2026 and the vehicle registration names a different owner.',
  documents: [
  {
    label: 'Driver’s licence',
    value: 'Expires 12 Jun 2026',
    kind: 'image',
    preview: LICENSE,
    checks: [
    { label: 'Legible scan', passed: true },
    { label: 'Not expired', passed: false },
    { label: 'Name matches application', passed: true }]

  },
  {
    label: 'Vehicle photo & papers',
    value: 'OSU-556-OSG',
    kind: 'image',
    preview: VEHICLE,
    checks: [
    { label: 'Plate legible', passed: true },
    { label: 'Registered owner matches rider', passed: false }]

  },
  {
    label: 'National ID',
    value: 'NIN ending 7712',
    kind: 'image',
    preview: ID_CARD,
    checks: [{ label: 'Face matches selfie', passed: true }]
  }]

},
{
  id: 'rs_411',
  subjectType: 'rider',
  subjectName: 'Ridwan Alao',
  contact: '+234 811 004 2290 · Ile-Ife',
  zone: 'Ile-Ife',
  submittedAt: '2026-08-24T18:50:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'First-time rider, all documents present',
  documents: [
  {
    label: 'Driver’s licence',
    value: 'Expires 03 Apr 2029',
    kind: 'image',
    preview: LICENSE,
    checks: [
    { label: 'Not expired', passed: true },
    { label: 'Name matches application', passed: true }]

  },
  {
    label: 'Vehicle photo & papers',
    value: 'OSU-778-IFE',
    kind: 'image',
    preview: VEHICLE,
    checks: [
    { label: 'Plate legible', passed: true },
    { label: 'Registered owner matches rider', passed: true }]

  },
  {
    label: 'National ID',
    value: 'NIN ending 5510',
    kind: 'image',
    preview: ID_CARD,
    checks: [{ label: 'Face matches selfie', passed: true }]
  }]

},
{
  id: 'rs_410',
  subjectType: 'rider',
  subjectName: 'Grace Olawale',
  contact: '+234 807 118 0022 · Ilesa',
  zone: 'Ilesa',
  submittedAt: '2026-08-24T13:15:00',
  tier: 'review',
  status: 'pending',
  routingReason: 'Vehicle photo is blurred — needs a human read',
  documents: [
  {
    label: 'Driver’s licence',
    value: 'Expires 21 Nov 2028',
    kind: 'image',
    preview: LICENSE,
    checks: [{ label: 'Not expired', passed: true }]
  },
  {
    label: 'Vehicle photo & papers',
    value: 'OSU-201-ILS',
    kind: 'image',
    preview: VEHICLE,
    checks: [{ label: 'Plate legible', passed: false }]
  }]

},
{
  id: 'rs_409',
  subjectType: 'rider',
  subjectName: 'Kemi Oyelaran',
  contact: '+234 805 220 7741 · Ilesa',
  zone: 'Ilesa',
  submittedAt: '2026-08-21T09:55:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Licence, ID and vehicle papers all matched automatically',
  documents: [
  {
    label: 'Driver’s licence',
    value: 'Expires 08 Feb 2030',
    kind: 'image',
    preview: LICENSE,
    checks: [{ label: 'Not expired', passed: true }]
  }],

  decision: { by: 'Automated rule', at: '2026-08-21T10:02:00' }
},
{
  id: 'rs_408',
  subjectType: 'rider',
  subjectName: 'Musa Danjuma',
  contact: '+234 810 552 3390 · Ede',
  zone: 'Ede',
  submittedAt: '2026-08-20T16:20:00',
  tier: 'auto',
  status: 'auto_approved',
  routingReason: 'Licence, ID and vehicle papers all matched automatically',
  documents: [
  {
    label: 'Driver’s licence',
    value: 'Expires 30 Sep 2031',
    kind: 'image',
    preview: LICENSE,
    checks: [{ label: 'Not expired', passed: true }]
  }],

  decision: { by: 'Automated rule', at: '2026-08-20T16:24:00' }
}];