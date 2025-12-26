import { useEffect, useRef } from 'react';

const isDebug = typeof (window as any).GetParentResourceName !== 'function';

export const debugData: Record<string, unknown> = {
  open: {
    licenses: [
      { id: 'driver', label: 'Driver License', price: 50, description: 'Required to drive vehicles' },
      { id: 'id_card', label: 'ID Card', price: 25, description: 'Official identification' },
      { id: 'weapon', label: 'Weapon License', price: 150, description: 'Required to carry firearms' }
    ],
    jobs: [
      { id: 'news', label: 'News Reporter', description: 'Report on breaking news events' },
      { id: 'trucker', label: 'Trucker', description: 'Transport cargo across the map' },
      { id: 'taxi', label: 'Taxi Driver', description: 'Provide transportation services' },
      { id: 'tow', label: 'Tow Truck Driver', description: 'Recover and tow vehicles' },
      { id: 'garbage', label: 'Garbage Collector', description: 'Collect waste from the city' },
      { id: 'bus', label: 'Bus Driver', description: 'Operate public bus routes' }
    ]
  }
};

export function debugNuiEvent(action: string, data: unknown) {
  window.dispatchEvent(new MessageEvent('message', { data: { action, ...data } }));
}

export function useNuiEvent<T = unknown>(action: string, handler: (data: T) => void) {
  const savedHandler = useRef(handler);
  useEffect(() => { savedHandler.current = handler; }, [handler]);
  useEffect(() => {
    function eventListener(event: MessageEvent) {
      const eventData = event.data || {};
      if (eventData.action === action) {
        // If data has a 'data' property, use that, otherwise use rest of properties
        const payload = eventData.data !== undefined ? eventData.data : eventData;
        savedHandler.current(payload as T);
      }
    }
    window.addEventListener('message', eventListener);
    return () => window.removeEventListener('message', eventListener);
  }, [action]);
}

export async function fetchNui<T = unknown>(eventName: string, data: Record<string, unknown> = {}): Promise<T> {
  if (isDebug) {
    const mock = debugData[eventName];
    if (mock !== undefined) return mock as T;
    console.warn(`[Debug] No mock for '${eventName}'. Add to debugData.`);
    return {} as T;
  }
  const resourceName = (window as any).GetParentResourceName();
  const response = await fetch(`https://${resourceName}/${eventName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return response.json();
}

if (isDebug) {
  setTimeout(() => debugNuiEvent('open', debugData.open), 100);
}
