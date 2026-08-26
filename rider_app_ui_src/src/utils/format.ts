export function naira(amount: number): string {
  return `₦${amount.toLocaleString('en-NG')}`;
}

export function nairaCompact(amount: number): string {
  if (amount >= 1000) {
    const k = amount / 1000;
    return `₦${k % 1 === 0 ? k : k.toFixed(1)}k`;
  }
  return `₦${amount}`;
}