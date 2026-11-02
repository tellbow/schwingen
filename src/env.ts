import { defineEnvVars } from '@sveltejs/kit/env';

export const variables = defineEnvVars({
	GITHUB_FEEDBACK_TOKEN: { schema: (input) => input ?? '' },
	GITHUB_FEEDBACK_REPO: { schema: (input) => input ?? '' }
});
