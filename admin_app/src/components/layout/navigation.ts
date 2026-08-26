import type { ComponentType } from 'react';
import {
  ActivityIcon,
  BanknoteIcon,
  BellRingIcon,
  BikeIcon,
  BuildingIcon,
  ClipboardListIcon,
  FileTextIcon,
  GaugeCircleIcon,
  LayoutDashboardIcon,
  MapIcon,
  MapPinIcon,
  MegaphoneIcon,
  MessageSquareWarningIcon,
  PercentIcon,
  ReceiptIcon,
  ScaleIcon,
  SearchIcon,
  ShieldCheckIcon,
  StarIcon,
  TagIcon,
  UsersIcon,
  UserSquareIcon } from
'lucide-react';

export type CountKey =
'withdrawals' |
'vendorChecks' |
'riderChecks' |
'moderation' |
'orders';

export interface NavItem {
  label: string;
  to: string;
  icon: ComponentType<{className?: string;}>;
  countKey?: CountKey;
  staticCount?: number;
  phaseTwo?: boolean;
}

export interface NavGroup {
  label: string;
  items: NavItem[];
}

export const NAV_GROUPS: NavGroup[] = [
{
  label: 'Overview',
  items: [{ label: 'Home', to: '/', icon: LayoutDashboardIcon }]
},
{
  label: 'Money',
  items: [
  {
    label: 'Withdrawals',
    to: '/withdrawals',
    icon: BanknoteIcon,
    countKey: 'withdrawals'
  },
  { label: 'Approval log', to: '/withdrawals/audit', icon: ClipboardListIcon },
  { label: 'Transaction ledger', to: '/ledger', icon: ReceiptIcon, phaseTwo: true },
  {
    label: 'Commission & fees',
    to: '/commission',
    icon: PercentIcon,
    phaseTwo: true
  }]

},
{
  label: 'Orders',
  items: [
  { label: 'Order lookup', to: '/orders', icon: SearchIcon },
  { label: 'Refunds & credits', to: '/refunds', icon: BanknoteIcon },
  {
    label: 'Live board',
    to: '/live-orders',
    icon: GaugeCircleIcon,
    countKey: 'orders',
    phaseTwo: true
  },
  {
    label: 'Disputes',
    to: '/disputes',
    icon: ScaleIcon,
    staticCount: 2,
    phaseTwo: true
  }]

},
{
  label: 'Accounts',
  items: [
  {
    label: 'Vendor checks',
    to: '/verification/vendors',
    icon: ShieldCheckIcon,
    countKey: 'vendorChecks'
  },
  {
    label: 'Rider checks',
    to: '/verification/riders',
    icon: ShieldCheckIcon,
    countKey: 'riderChecks'
  },
  { label: 'Vendors', to: '/vendors', icon: BuildingIcon },
  { label: 'Riders', to: '/riders', icon: BikeIcon },
  { label: 'Customers', to: '/customers', icon: UserSquareIcon }]

},
{
  label: 'Content',
  items: [
  {
    label: 'Moderation',
    to: '/moderation',
    icon: MessageSquareWarningIcon,
    countKey: 'moderation'
  },
  { label: 'Reviews', to: '/reviews', icon: StarIcon, phaseTwo: true },
  { label: 'Ad campaigns', to: '/ads', icon: MegaphoneIcon, phaseTwo: true }]

},
{
  label: 'Growth',
  items: [
  { label: 'Promo codes', to: '/promos', icon: TagIcon, phaseTwo: true },
  { label: 'Broadcasts', to: '/broadcasts', icon: BellRingIcon, phaseTwo: true },
  { label: 'Analytics', to: '/analytics', icon: ActivityIcon, phaseTwo: true },
  { label: 'Rider map', to: '/rider-map', icon: MapIcon, phaseTwo: true }]

},
{
  label: 'Platform',
  items: [
  { label: 'Service areas', to: '/config/zones', icon: MapPinIcon },
  { label: 'Delivery fees', to: '/config/fees', icon: PercentIcon },
  { label: 'Admin team', to: '/config/team', icon: UsersIcon },
  { label: 'Audit log', to: '/audit', icon: FileTextIcon }]

}];