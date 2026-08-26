import type { ModerationItem } from '../types';

const FEED_THUMB = "/4223597d-8d83-4f2c-aff9-fb45532c88af.jpg";


export const moderationItems: ModerationItem[] = [
{
  id: 'md_88',
  kind: 'feed_video',
  subject: 'Feed video — “₦500 full plate today only”',
  author: 'Pepper Pot Iwo',
  createdAt: '2026-08-25T07:10:00',
  reportCount: 9,
  reportedBy: '9 customers',
  reason: 'Misleading price — the item is listed at ₦3,200 in the store',
  tier: 'urgent',
  status: 'pending',
  routingReason: 'One report short of the auto-removal threshold, still climbing',
  excerpt:
  'Vendor promises a ₦500 full plate in the video, but no matching item exists on the menu.',
  thumbnail: FEED_THUMB
},
{
  id: 'md_87',
  kind: 'review',
  subject: 'Review on Shawarma Republic — 1★',
  author: 'Nike Balogun',
  createdAt: '2026-08-25T06:32:00',
  reportCount: 3,
  reportedBy: 'Shawarma Republic (vendor)',
  reason: 'Abusive language directed at a named staff member',
  tier: 'urgent',
  status: 'pending',
  routingReason: 'Contains a named individual plus flagged language',
  excerpt:
  '“The girl at the counter is a thief, she [redacted]. Don’t ever order from these people.”'
},
{
  id: 'md_86',
  kind: 'feed_video',
  subject: 'Feed video — kitchen tour',
  author: 'Amala Sky Buffet',
  createdAt: '2026-08-24T19:02:00',
  reportCount: 2,
  reportedBy: '2 customers',
  reason: 'Hygiene concern raised about food preparation surface',
  tier: 'review',
  status: 'pending',
  routingReason: 'Below the report threshold, needs a human judgement call',
  excerpt:
  'Reporters point at 0:14 where raw meat is on the same board as ready plates.',
  thumbnail: FEED_THUMB
},
{
  id: 'md_85',
  kind: 'review',
  subject: 'Review on Ife Grill House — 2★',
  author: 'Ibrahim Salaudeen',
  createdAt: '2026-08-24T14:44:00',
  reportCount: 1,
  reportedBy: 'Ife Grill House (vendor)',
  reason: 'Vendor claims the review is about a different restaurant',
  tier: 'review',
  status: 'pending',
  routingReason: 'Single vendor-side report on a verified order',
  excerpt:
  '“Suya was cold and the drink was missing. Second time this week.”'
},
{
  id: 'md_84',
  kind: 'profile',
  subject: 'Rider profile photo — Yusuf Ibrahim',
  author: 'Yusuf Ibrahim',
  createdAt: '2026-08-24T10:20:00',
  reportCount: 1,
  reportedBy: 'Ops sweep',
  reason: 'Profile photo does not match verification selfie',
  tier: 'review',
  status: 'pending',
  routingReason: 'Identity mismatch flagged during a routine sweep',
  excerpt: 'Photo appears to be a stock image rather than the rider.'
},
{
  id: 'md_83',
  kind: 'feed_video',
  subject: 'Feed video — “Rice giveaway”',
  author: 'Naija Bites Ilesa',
  createdAt: '2026-08-23T15:40:00',
  reportCount: 12,
  reportedBy: '12 customers',
  reason: 'Misleading promotion, no giveaway existed',
  tier: 'auto',
  status: 'auto_removed',
  routingReason: 'Report threshold of 10 reached within one hour',
  excerpt: 'Removed automatically and the vendor was notified.',
  thumbnail: FEED_THUMB,
  decision: { by: 'Automated rule', at: '2026-08-23T16:10:00' }
},
{
  id: 'md_82',
  kind: 'review',
  subject: 'Review on The Bowl Company — 1★',
  author: 'Anonymous customer',
  createdAt: '2026-08-20T18:02:00',
  reportCount: 4,
  reportedBy: 'The Bowl Company (vendor)',
  reason: 'Suspected competitor review-bombing',
  tier: 'review',
  status: 'dismissed',
  routingReason: 'Vendor-side report, needed a human check on account origins',
  excerpt: '“Worst food in Osogbo, they use expired oil.”',
  decision: {
    by: 'Ngozi Eze',
    at: '2026-08-20T18:44:00',
    reason: 'Reports came from a single competing vendor’s accounts.'
  }
},
{
  id: 'md_81',
  kind: 'feed_video',
  subject: 'Feed video — new menu launch',
  author: 'Iya Basira Kitchen',
  createdAt: '2026-08-19T12:00:00',
  reportCount: 11,
  reportedBy: '11 customers',
  reason: 'Loud audio / spam reposting',
  tier: 'auto',
  status: 'auto_removed',
  routingReason: 'Same clip posted 6 times in one day, spam rule triggered',
  excerpt: 'Removed automatically; vendor asked to post once per day.',
  thumbnail: FEED_THUMB,
  decision: { by: 'Automated rule', at: '2026-08-19T12:30:00' }
}];