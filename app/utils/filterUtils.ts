/**
 * Safely escapes a string for use in PocketBase filters
 * This helps prevent potential SQL injection vulnerabilities
 */
export const escapeFilterValue = (value: string): string => {
  if (!value) return "";

  // Remove potentially dangerous characters
  return value
    .replace(/['"\\]/g, "") // Remove quotes and backslashes
    .replace(/[;()]/g, "") // Remove semicolons and parentheses
    .trim();
};

/**
 * Builds a safe filter string for PocketBase queries
 */
export const buildFilterString = (filters: Record<string, string>): string => {
  const filterParts = Object.entries(filters)
    .filter(([_, value]) => value && value.trim() !== "")
    .map(([field, value]) => {
      const escapedValue = escapeFilterValue(value);
      return `${field} ~ "${escapedValue}"`;
    });

  return filterParts.join(" && ");
};

/**
 * Validates route parameters to ensure they are safe
 */
export const validateRouteParam = (param: string | string[]): string => {
  const value = Array.isArray(param) ? param[0] : param;

  if (!value || typeof value !== "string") {
    throw new Error("Invalid route parameter");
  }

  // Only allow alphanumeric characters, hyphens, and underscores
  if (!/^[a-zA-Z0-9_-]+$/.test(value)) {
    throw new Error("Invalid route parameter format");
  }

  return value;
};
