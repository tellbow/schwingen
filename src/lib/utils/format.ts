import { getLocale } from "$lib/i18n/index.svelte";

export function formatDate(value: string | null | undefined): string {
	if (!value) return "";
	const date = new Date(value);
	if (isNaN(date.getTime())) return value;
	return new Intl.DateTimeFormat(getLocale(), { day: "2-digit", month: "2-digit", year: "numeric" }).format(date);
}
