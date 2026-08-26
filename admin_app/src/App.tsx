import React from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { Toaster } from 'sonner';
import { AdminProvider, useAdmin } from './contexts/AdminContext';
import { AdminLayout } from './components/layout/AdminLayout';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { WithdrawalQueue } from './pages/withdrawals/WithdrawalQueue';
import { WithdrawalDetail } from './pages/withdrawals/WithdrawalDetail';
import { ApprovalLog } from './pages/withdrawals/ApprovalLog';
import { OrderLookup } from './pages/orders/OrderLookup';
import { OrderDetail } from './pages/orders/OrderDetail';
import { Refunds } from './pages/orders/Refunds';
import { VerificationQueue } from './pages/verification/VerificationQueue';
import { VendorList } from './pages/directory/VendorList';
import { VendorDetail } from './pages/directory/VendorDetail';
import { RiderList } from './pages/directory/RiderList';
import { RiderDetail } from './pages/directory/RiderDetail';
import { CustomerList } from './pages/directory/CustomerList';
import { CustomerDetail } from './pages/directory/CustomerDetail';
import { ModerationQueue } from './pages/moderation/ModerationQueue';
import { ServiceAreas } from './pages/config/ServiceAreas';
import { DeliveryFees } from './pages/config/DeliveryFees';
import { AdminTeam } from './pages/config/AdminTeam';
import { AuditLog } from './pages/AuditLog';
import { LiveOrders } from './pages/phase2/LiveOrders';
import { Disputes } from './pages/phase2/Disputes';
import { Ledger } from './pages/phase2/Ledger';
import { Commission } from './pages/phase2/Commission';
import { AdCampaigns } from './pages/phase2/AdCampaigns';
import { Promos } from './pages/phase2/Promos';
import { Broadcasts } from './pages/phase2/Broadcasts';
import { Analytics } from './pages/phase2/Analytics';
import { RiderMap } from './pages/phase2/RiderMap';
import { ReviewModeration } from './pages/phase2/ReviewModeration';

function Shell() {
  const { signedIn, authLoading } = useAdmin();
  if (authLoading) return <div className="flex min-h-screen items-center justify-center text-ink-muted">Loading…</div>;
  if (!signedIn) return <Login />;
  return <AdminLayout />;
}

function LoginRoute() {
  const { signedIn, authLoading } = useAdmin();
  if (authLoading) return <div className="flex min-h-screen items-center justify-center text-ink-muted">Loading…</div>;
  if (signedIn) return <Navigate to="/" replace />;
  return <Login />;
}

export function App() {
  return (
    <AdminProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginRoute />} />
          <Route element={<Shell />}>
            <Route path="/" element={<Dashboard />} />

            <Route path="/withdrawals" element={<WithdrawalQueue />} />
            <Route path="/withdrawals/audit" element={<ApprovalLog />} />
            <Route path="/withdrawals/:id" element={<WithdrawalDetail />} />

            <Route path="/orders" element={<OrderLookup />} />
            <Route path="/orders/:id" element={<OrderDetail />} />
            <Route path="/refunds" element={<Refunds />} />

            <Route
              path="/verification/vendors"
              element={<VerificationQueue kind="vendor" />} />
            
            <Route
              path="/verification/riders"
              element={<VerificationQueue kind="rider" />} />
            

            <Route path="/vendors" element={<VendorList />} />
            <Route path="/vendors/:id" element={<VendorDetail />} />
            <Route path="/riders" element={<RiderList />} />
            <Route path="/riders/:id" element={<RiderDetail />} />
            <Route path="/customers" element={<CustomerList />} />
            <Route path="/customers/:id" element={<CustomerDetail />} />

            <Route path="/moderation" element={<ModerationQueue />} />

            <Route path="/config/zones" element={<ServiceAreas />} />
            <Route path="/config/fees" element={<DeliveryFees />} />
            <Route path="/config/team" element={<AdminTeam />} />
            <Route path="/audit" element={<AuditLog />} />

            <Route path="/live-orders" element={<LiveOrders />} />
            <Route path="/disputes" element={<Disputes />} />
            <Route path="/ledger" element={<Ledger />} />
            <Route path="/commission" element={<Commission />} />
            <Route path="/ads" element={<AdCampaigns />} />
            <Route path="/promos" element={<Promos />} />
            <Route path="/broadcasts" element={<Broadcasts />} />
            <Route path="/analytics" element={<Analytics />} />
            <Route path="/rider-map" element={<RiderMap />} />
            <Route path="/reviews" element={<ReviewModeration />} />

            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
      <Toaster
        position="bottom-right"
        toastOptions={{
          style: {
            borderRadius: '10px',
            border: '1px solid #E7E7E8',
            fontSize: '14px'
          }
        }} />
      
    </AdminProvider>);

}