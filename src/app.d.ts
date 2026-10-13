import type { Locale } from '$lib/i18n/translations';

declare global {
	namespace App {
		interface Locals {
			locale: Locale;
		}
	}
}

export {};
