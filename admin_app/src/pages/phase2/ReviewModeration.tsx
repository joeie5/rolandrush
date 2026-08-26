import React from 'react';
import { ModerationQueue } from '../moderation/ModerationQueue';

export function ReviewModeration() {
  return (
    <ModerationQueue
      only="review"
      phaseTwo
      title="Review moderation"
      subtitle="Reported customer reviews only. Reviews on unverified orders never publish, so everything here is tied to a real order." />);


}