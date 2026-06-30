import { apiJson } from './client';
import type { Player } from './players';

export function buyFood(type: string, quantity: number): Promise<Player> {
  return apiJson<Player>('/api/food', {
    method: 'POST',
    body: JSON.stringify({ type, quantity }),
  });
}
