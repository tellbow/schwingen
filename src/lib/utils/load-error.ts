import { error } from '@sveltejs/kit';

export function throwLoadError(cause: unknown, notFound: string): never {
	if ((cause as { status?: number } | null)?.status === 404) throw error(404, notFound);
	console.error(cause);
	throw error(503, 'Data temporarily unavailable');
}
