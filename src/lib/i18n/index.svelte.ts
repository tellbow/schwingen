import { translations, type Locale } from "./translations";

export { type Locale };

export const LOCALES: Locale[] = ["de", "fr"];

let locale = $state<Locale>("de");

export function initLocale(): void {
	const stored = localStorage.getItem("locale") as Locale | null;
	if (stored && (LOCALES as string[]).includes(stored)) {
		locale = stored;
	}
}

export function getLocale(): Locale {
	return locale;
}

export function setLocale(l: Locale): void {
	locale = l;
	localStorage.setItem("locale", l);
}

export function t(key: string): string {
	const parts = key.split(".");
	let val: unknown = translations[locale];
	for (const p of parts) {
		val = (val as Record<string, unknown>)?.[p];
	}
	return typeof val === "string" ? val : key;
}
