type ChipColor = 'success' | 'info' | 'warning' | 'error' | 'default';

export function statusColor(status: string): ChipColor {
  switch (status) {
    case 'Thriving':
      return 'success';
    case 'Stable':
      return 'info';
    case 'Struggling':
      return 'warning';
    case 'Critical':
      return 'error';
    default:
      return 'default';
  }
}
