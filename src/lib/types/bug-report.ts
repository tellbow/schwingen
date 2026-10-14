export type BugPlatform = 'web' | 'ios';

export interface BugReportRequest {
	description: string;
	place: string;
	platform: BugPlatform;
	version?: string;
	system?: string;
	website?: string;
}

export interface BugReport {
	description: string;
	place: string;
	platform: BugPlatform;
	version: string;
	system: string;
}
