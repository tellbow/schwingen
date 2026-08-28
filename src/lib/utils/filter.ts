export const escapeFilterValue = (value: string): string => {
	if (!value) return '';

	return value
		.replace(/['"\\]/g, '')
		.replace(/[;()]/g, '')
		.trim();
};

export type SafeFilterField =
	| { param: string; column: string; match: 'contains' | 'equals' }
	| { param: string; column: string; match: 'boolean' }
	| { param: string; enum: Record<string, string> };

export const buildSafeFilter = (searchParams: URLSearchParams, fields: SafeFilterField[]): string => {
	const parts: string[] = [];

	for (const field of fields) {
		if ('enum' in field) {
			const value = searchParams.get(field.param);
			if (value && Object.hasOwn(field.enum, value)) parts.push(field.enum[value]);
			continue;
		}

		const value = searchParams.get(field.param);
		if (!value) continue;

		if (field.match === 'boolean') {
			if (value === 'true') parts.push(`${field.column} = true`);
			continue;
		}

		const escaped = escapeFilterValue(value);
		if (!escaped) continue;

		parts.push(`${field.column} ${field.match === 'equals' ? '=' : '~'} "${escaped}"`);
	}

	return parts.join(' && ');
};

export const buildQuickSearchFilter = (searchParams: URLSearchParams, columns: string[]): string => {
	const value = searchParams.get('q');
	if (!value) return '';

	const escaped = escapeFilterValue(value);
	if (!escaped) return '';

	return `(${columns.map((column) => `${column} ~ "${escaped}"`).join(' || ')})`;
};

const SORT_PATTERN = /^-?[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)?(,-?[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)?)*$/;

export const sanitizeSort = (value: string | null, fallback: string): string =>
	value && SORT_PATTERN.test(value) ? value : fallback;

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

export const WRESTLER_STATUS_FILTERS: Record<string, string> = {
	eidgenoss: "status.symbol = '***'",
	teilverband: "status.symbol = '**'",
	kantonal: "status.symbol = '*'",
	ohne: "status.symbol = ''"
};

export const WRESTLER_STATUS_OPTIONS: { value: string; labelKey: string }[] = [
	{ value: '', labelKey: 'wrestler.statusAll' },
	{ value: 'eidgenoss', labelKey: 'wrestler.statusEidgenoss' },
	{ value: 'teilverband', labelKey: 'wrestler.statusTeilverband' },
	{ value: 'kantonal', labelKey: 'wrestler.statusKantonal' },
	{ value: 'ohne', labelKey: 'wrestler.statusOhne' }
];
