export type BugPlatform = 'web' | 'ios';

export interface BugReportRequest {
	description: string;
	place: string;
	platform: BugPlatform;
	version?: string;
	system?: string;
	screenshot?: string;
	website?: string;
}

export interface Screenshot {
	base64: string;
	extension: 'png' | 'jpg';
}

export interface BugReport {
	description: string;
	place: string;
	platform: BugPlatform;
	version: string;
	system: string;
	screenshot?: Screenshot;
}
