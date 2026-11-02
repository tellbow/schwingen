import type { Locale } from '#lib/i18n/translations.js';

declare global {
	const __APP_VERSION__: string;

	namespace App {
		interface Locals {
			locale: Locale;
		}
	}
}

export {};
