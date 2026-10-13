export function buildSearchParams(
	filters: Record<string, string | boolean>,
	page: number
): URLSearchParams {
	const params = new URLSearchParams();
	for (const [key, value] of Object.entries(filters)) {
		if (value) params.set(key, value === true ? 'true' : value);
	}
	if (page > 1) params.set('page', String(page));
	return params;
}
