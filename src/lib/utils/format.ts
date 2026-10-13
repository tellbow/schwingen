import type { Locale } from '$lib/i18n/translations';

export function yearOnly(value: string | null | undefined): string {
	return value ? value.split('-')[0] : '';
}

export function formatDate(value: string | null | undefined, locale: Locale = 'de'): string {
	if (!value) return '';
	const date = new Date(value);
	if (isNaN(date.getTime())) return value;
	return new Intl.DateTimeFormat(locale, {
		day: '2-digit',
		month: '2-digit',
		year: 'numeric'
	}).format(date);
}
