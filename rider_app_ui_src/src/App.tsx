import React from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { RiderProvider } from './contexts/RiderContext';
import { PhoneShell } from './components/PhoneShell';
import { Splash } from './pages/Splash';
import { PhoneEntry } from './pages/PhoneEntry';
import { OtpVerify } from './pages/OtpVerify';
import { Signup } from './pages/Signup';
import { VerificationStatus } from './pages/VerificationStatus';
import { Home } from './pages/Home';
import { Jobs } from './pages/Jobs';
import { ActiveDelivery } from './pages/ActiveDelivery';
import { DeliveryConfirm } from './pages/DeliveryConfirm';
import { DeliverySuccess } from './pages/DeliverySuccess';
import { Earnings } from './pages/Earnings';
import { Withdraw } from './pages/Withdraw';
import { Profile } from './pages/Profile';
import { VehicleDetails } from './pages/VehicleDetails';
import { Documents } from './pages/Documents';
import { BankAccount } from './pages/BankAccount';
import { NotificationSettings } from './pages/NotificationSettings';
import { HelpSupport } from './pages/HelpSupport';
import { PrivacySecurity } from './pages/PrivacySecurity';

export function App() {
  return (
    <RiderProvider>
      <BrowserRouter>
        <Routes>
          <Route element={<PhoneShell />}>
            <Route path="/" element={<Splash />} />
            <Route path="/auth/phone" element={<PhoneEntry />} />
            <Route path="/auth/otp" element={<OtpVerify />} />
            <Route path="/auth/signup" element={<Signup />} />
            <Route path="/auth/verification" element={<VerificationStatus />} />
            <Route path="/home" element={<Home />} />
            <Route path="/jobs" element={<Jobs />} />
            <Route path="/delivery/active" element={<ActiveDelivery />} />
            <Route path="/delivery/confirm" element={<DeliveryConfirm />} />
            <Route path="/delivery/success" element={<DeliverySuccess />} />
            <Route path="/earnings" element={<Earnings />} />
            <Route path="/withdraw" element={<Withdraw />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="/profile/vehicle" element={<VehicleDetails />} />
            <Route path="/profile/documents" element={<Documents />} />
            <Route path="/profile/bank" element={<BankAccount />} />
            <Route path="/profile/notifications" element={<NotificationSettings />} />
            <Route path="/profile/support" element={<HelpSupport />} />
            <Route path="/profile/privacy" element={<PrivacySecurity />} />
            <Route path="*" element={<Navigate to="/home" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </RiderProvider>);

}