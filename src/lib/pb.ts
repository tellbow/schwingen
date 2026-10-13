import PocketBase from 'pocketbase';

// Server-side PocketBase URL (direct connection, no CORS)
export const PB_URL =
	typeof process !== 'undefined' && process.env?.PB_URL
		? process.env.PB_URL
		: 'http://127.0.0.1:8090';

// Create a PocketBase instance for server-side use
export function createServerPb(): PocketBase {
	return new PocketBase(PB_URL);
}

// Client-side PocketBase instance (through proxy to avoid CORS)
let clientPb: PocketBase | null = null;

export function getClientPb(): PocketBase {
	if (!clientPb) {
		// In browser, use relative URL (goes through SvelteKit proxy)
		const base = typeof window !== 'undefined' ? '/api/pb' : PB_URL;
		clientPb = new PocketBase(base).autoCancellation(false);
	}
	return clientPb;
}
