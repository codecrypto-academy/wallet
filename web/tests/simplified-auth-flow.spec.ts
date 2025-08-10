import { test, expect } from '@playwright/test';
import { createAuthHelper, AuthHelper } from './utils/auth-helpers';

test.describe('Simplified Authentication Flow with Helpers', () => {
  let authHelper: AuthHelper;

  test.beforeEach(async () => {
    authHelper = createAuthHelper();
  });

  test('should complete full authentication flow and verify JWT integrity', async ({ page }) => {
    // Generate login request and get parameters
    const params = await authHelper.generateLoginRequest(page);
    
    // Complete authentication
    await authHelper.completeAuthentication(page, params);
    
    // Verify we're on dashboard
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible();
    await expect(page.locator('text=You are successfully authenticated with your Ethereum wallet')).toBeVisible();
    
    // Get stored JWT and address
    const jwt = await authHelper.getStoredJWT(page);
    const storedAddress = await authHelper.getStoredAddress(page);
    
    // Verify JWT exists and address matches
    expect(jwt).toBeTruthy();
    expect(storedAddress).toBe(authHelper.getWalletAddress());
    
    // Verify JWT structure and content
    await authHelper.verifyJWTStructure(jwt!);
    
    // Decode JWT and verify address
    const payload = await authHelper.decodeJWT(jwt!);
    expect(payload.address).toBe(authHelper.getWalletAddress());
    
    // Verify JWT is stored in cookies too
    const cookieJWT = await authHelper.getJWTCookie(page);
    expect(cookieJWT).toBe(jwt);
    
    // Verify address is displayed on dashboard (in main content, not header)
    await expect(page.locator('main').locator(`text=${authHelper.getWalletAddress()}`)).toBeVisible();
  });

  test('should handle logout and clear all storage', async ({ page }) => {
    // Complete authentication first
    const params = await authHelper.generateLoginRequest(page);
    await authHelper.completeAuthentication(page, params);
    
    // Verify we're authenticated
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible();
    
    // Clear storage (simulate logout)
    await authHelper.clearStorage(page);
    await page.reload();
    
    // Verify we're back to login
    await expect(page.locator('text=Login with Ethereum')).toBeVisible();
    
    // Verify storage is cleared
    const jwt = await authHelper.getStoredJWT(page);
    const address = await authHelper.getStoredAddress(page);
    const cookieJWT = await authHelper.getJWTCookie(page);
    
    expect(jwt).toBeNull();
    expect(address).toBeNull();
    expect(cookieJWT).toBeNull();
  });

  test('should work with multiple different wallets', async ({ page }) => {
    // First authentication
    const firstParams = await authHelper.generateLoginRequest(page);
    await authHelper.completeAuthentication(page, firstParams);
    
    const firstJWT = await authHelper.getStoredJWT(page);
    const firstAddress = await authHelper.getStoredAddress(page);
    
    expect(firstAddress).toBe(authHelper.getWalletAddress());
    
    // Clear and create new helper (new wallet)
    await authHelper.clearStorage(page);
    await page.reload();
    
    const secondAuthHelper = createAuthHelper();
    
    // Second authentication with different wallet
    const secondParams = await secondAuthHelper.generateLoginRequest(page);
    await secondAuthHelper.completeAuthentication(page, secondParams);
    
    const secondJWT = await secondAuthHelper.getStoredJWT(page);
    const secondAddress = await secondAuthHelper.getStoredAddress(page);
    
    // Verify addresses are different
    expect(firstAddress).not.toBe(secondAddress);
    expect(secondAddress).toBe(secondAuthHelper.getWalletAddress());
    
    // Verify JWT payloads contain correct addresses
    const firstPayload = await authHelper.decodeJWT(firstJWT!);
    const secondPayload = await secondAuthHelper.decodeJWT(secondJWT!);
    
    expect(firstPayload.address).toBe(firstAddress);
    expect(secondPayload.address).toBe(secondAddress);
    expect(firstPayload.address).not.toBe(secondPayload.address);
  });

  test('should verify JWT expiration and timestamps', async ({ page }) => {
    const params = await authHelper.generateLoginRequest(page);
    await authHelper.completeAuthentication(page, params);
    
    const jwt = await authHelper.getStoredJWT(page);
    expect(jwt).toBeTruthy();
    
    // Decode and verify timestamps
    const payload = await authHelper.decodeJWT(jwt!);
    const currentTime = Math.floor(Date.now() / 1000);
    
    // Verify timestamp is recent
    expect(payload.timestamp).toBeLessThanOrEqual(currentTime);
    expect(payload.timestamp).toBeGreaterThan(currentTime - 60);
    
    // Verify JWT expiration (3 minutes from now)
    expect(payload.exp).toBeGreaterThan(currentTime);
    expect(payload.exp).toBeLessThanOrEqual(currentTime + 180);
    
    // Verify issued at time
    expect(payload.iat).toBeLessThanOrEqual(currentTime);
    expect(payload.iat).toBeGreaterThan(currentTime - 60);
  });
});
