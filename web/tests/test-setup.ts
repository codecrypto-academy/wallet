import { test as base } from '@playwright/test';

// Extend the test to include custom fixtures if needed
export const test = base.extend({
  // Add custom fixtures here if needed in the future
});

export { expect } from '@playwright/test';

// Global setup for tests
export async function globalSetup() {
  // Set test environment variables
  process.env.NODE_ENV = 'test';
  process.env.JWT_SECRET = 'test-secret-key-for-testing-only';
  process.env.MONGODB_URI = 'mongodb://localhost:27017/ethereum-login-test';
}

// Global teardown for tests
export async function globalTeardown() {
  // Clean up test data if needed
}
