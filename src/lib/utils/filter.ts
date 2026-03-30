export const escapeFilterValue = (value: string): string => {
	if (!value) return '';

	return value
		.replace(/['"\\]/g, '')
		.replace(/[;()]/g, '')
		.trim();
};

export const buildFilterString = (filters: Record<string, string>): string => {
	const filterParts = Object.entries(filters)
		.filter(([, value]) => value && value.trim() !== '')
		.map(([field, value]) => {
			const escapedValue = escapeFilterValue(value);
			return `${field} ~ "${escapedValue}"`;
		});

	return filterParts.join(' && ');
};

export const validateRouteParam = (param: string | string[]): string => {
	const value = Array.isArray(param) ? param[0] : param;

	if (!value || typeof value !== 'string') {
		throw new Error('Invalid route parameter');
	}

	if (!/^[a-zA-Z0-9_-]+$/.test(value)) {
		throw new Error('Invalid route parameter format');
	}

	return value;
};
