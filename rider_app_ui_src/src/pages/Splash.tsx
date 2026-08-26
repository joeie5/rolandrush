import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { BikeIcon } from 'lucide-react';

export function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = window.setTimeout(() => navigate('/auth/phone'), 1900);
    return () => window.clearTimeout(timer);
  }, [navigate]);

  return (
    <button
      type="button"
      onClick={() => navigate('/auth/phone')}
      className="flex min-h-0 flex-1 flex-col items-center justify-center gap-6 bg-coral px-8 text-white">
      
      <motion.span
        initial={{ scale: 0.96, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.28, ease: [0.23, 1, 0.32, 1] }}
        className="flex h-24 w-24 items-center justify-center rounded-[28px] bg-white">
        
        <BikeIcon className="h-14 w-14 text-coral" strokeWidth={2.6} />
      </motion.span>
      <div className="text-center">
        <p className="text-[40px] font-extrabold leading-none tracking-[-0.04em]">RolandRush</p>
        <p className="mt-2 text-[20px] font-bold tracking-[-0.01em] text-white/85">Rider</p>
      </div>
      <p className="absolute bottom-10 text-[15px] font-semibold text-white/70">
        Osun State · Ride. Deliver. Earn.
      </p>
    </button>);

}