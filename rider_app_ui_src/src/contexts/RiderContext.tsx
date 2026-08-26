import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import { jobs as allJobs } from '../data/jobs';
import type { DeliveryStep, Job } from '../types';

interface RiderState {
  isOnline: boolean;
  setOnline: (value: boolean) => void;
  toggleOnline: () => void;
  availableJobs: Job[];
  activeJob: Job | null;
  step: DeliveryStep;
  acceptJob: (job: Job) => void;
  advanceStep: () => void;
  completeDelivery: () => void;
  lastCompleted: {job: Job;amount: number;tip: number;} | null;
  todayEarnings: number;
  todayDeliveries: number;
  onlineHours: string;
  balance: number;
  withdraw: (amount: number) => void;
}

const RiderContext = createContext<RiderState | null>(null);

export function RiderProvider({ children }: {children: React.ReactNode;}) {
  const [isOnline, setIsOnline] = useState(true);
  const [availableJobs, setAvailableJobs] = useState<Job[]>(allJobs);
  const [activeJob, setActiveJob] = useState<Job | null>(null);
  const [step, setStep] = useState<DeliveryStep>(0);
  const [lastCompleted, setLastCompleted] = useState<RiderState['lastCompleted']>(null);
  const [todayEarnings, setTodayEarnings] = useState(12800);
  const [todayDeliveries, setTodayDeliveries] = useState(5);
  const [balance, setBalance] = useState(48350);

  const acceptJob = useCallback((job: Job) => {
    setActiveJob(job);
    setStep(0);
    setAvailableJobs((prev) => prev.filter((j) => j.id !== job.id));
  }, []);

  const advanceStep = useCallback(() => {
    setStep((prev) => prev < 3 ? prev + 1 as DeliveryStep : prev);
  }, []);

  const completeDelivery = useCallback(() => {
    if (!activeJob) return;
    const tip = 200;
    setLastCompleted({ job: activeJob, amount: activeJob.payout, tip });
    setTodayEarnings((prev) => prev + activeJob.payout + tip);
    setTodayDeliveries((prev) => prev + 1);
    setBalance((prev) => prev + activeJob.payout + tip);
    setActiveJob(null);
    setStep(0);
  }, [activeJob]);

  const withdraw = useCallback((amount: number) => {
    setBalance((prev) => Math.max(0, prev - amount));
  }, []);

  const value = useMemo<RiderState>(
    () => ({
      isOnline,
      setOnline: setIsOnline,
      toggleOnline: () => setIsOnline((prev) => !prev),
      availableJobs,
      activeJob,
      step,
      acceptJob,
      advanceStep,
      completeDelivery,
      lastCompleted,
      todayEarnings,
      todayDeliveries,
      onlineHours: '6h 12m',
      balance,
      withdraw
    }),
    [
    isOnline,
    availableJobs,
    activeJob,
    step,
    acceptJob,
    advanceStep,
    completeDelivery,
    lastCompleted,
    todayEarnings,
    todayDeliveries,
    balance,
    withdraw]

  );

  return <RiderContext.Provider value={value}>{children}</RiderContext.Provider>;
}

export function useRider(): RiderState {
  const ctx = useContext(RiderContext);
  if (!ctx) throw new Error('useRider must be used inside RiderProvider');
  return ctx;
}