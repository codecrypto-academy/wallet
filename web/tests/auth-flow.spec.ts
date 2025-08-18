import { test, expect } from '@playwright/test';
import { ethers } from 'ethers';

test.describe('Ethereum Authentication Flow E2E', () => {
  let testWallet: ethers.Wallet;
  let testAddress: string;

  test.beforeAll(async () => {
    // Create a test wallet for signing
    testWallet = ethers.Wallet.createRandom() as unknown as ethers.Wallet;
    testAddress = testWallet.address;
  });

  test('should complete full authentication flow and verify correct address in token', async ({ page }) => {
    // Navigate to the login page
    await page.goto('/');
    
    // Wait for the page to load and verify we're on the login form
    await expect(page.locator('text=Login with Ethereum')).toBeVisible();
    await expect(page.locator('text=Generate Login QR Code')).toBeVisible();

    // Click to generate login request
    await page.click('text=Generate Login QR Code');

    // Wait for the QR code to appear
    await expect(page.locator('text=Scan QR Code')).toBeVisible();
    await expect(page.locator('svg').first()).toBeVisible();

    // Get the deep link from the page
    const deepLinkElement = page.locator('code');
    await expect(deepLinkElement).toBeVisible();
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    // Parse the deep link to extract parameters
    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    if (!random || !timestamp || !serverAddress || !signature) {
      throw new Error('Missing required parameters in deep link');
    }

    // Simulate wallet signing by creating a signature with our test wallet
    const domain = 'ethereum-login-app.com';
    const message = `${random}`;
    const userSignature = await testWallet.signMessage(message);

    // Send the signature verification request
    const verifyResponse = await page.request.post('/api/auth/verify-signature', {
      data: {
        random,
        address: testAddress,
        signature: userSignature
      }
    });

    expect(verifyResponse.ok()).toBeTruthy();
    const verifyData = await verifyResponse.json();
    expect(verifyData.success).toBe(true);

    // Wait for the login to complete (polling should detect the status change)
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });

    // Verify we're now on the dashboard
    await expect(page.locator('text=You are successfully authenticated with your Ethereum wallet')).toBeVisible();
    
    // Verify the wallet address is displayed correctly in the dashboard
    await expect(page.locator('main').locator(`text=${testAddress}`)).toBeVisible();

    // Check that JWT is stored in localStorage
    const jwt = await page.evaluate(() => localStorage.getItem('jwt'));
    expect(jwt).toBeTruthy();
    expect(typeof jwt).toBe('string');

    // Check that userAddress is stored in localStorage
    const storedAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    expect(storedAddress).toBe(testAddress);

    // Verify JWT contains the correct address by decoding it
    const jwtPayload = await page.evaluate((token) => {
      try {
        // Simple JWT decode (without verification for testing)
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
          return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        return JSON.parse(jsonPayload);
      } catch (e) {
        return null;
      }
    }, jwt);

    expect(jwtPayload).toBeTruthy();
    expect(jwtPayload.address).toBe(testAddress);
    expect(jwtPayload.timestamp).toBeTruthy();

    // Verify JWT is also stored in cookies
    const cookies = await page.context().cookies();
    const jwtCookie = cookies.find(cookie => cookie.name === 'jwt');
    expect(jwtCookie).toBeTruthy();
    expect(jwtCookie?.value).toBe(jwt);

    // Test logout functionality
    await page.evaluate(() => {
      // Simulate logout by clearing storage
      localStorage.removeItem('jwt');
      localStorage.removeItem('userAddress');
      document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
      window.location.reload();
    });

    // Wait for page to reload and verify we're back to login
    await expect(page.locator('text=Login with Ethereum')).toBeVisible();
    
    // Verify storage is cleared
    const jwtAfterLogout = await page.evaluate(() => localStorage.getItem('jwt'));
    const addressAfterLogout = await page.evaluate(() => localStorage.getItem('userAddress'));
    expect(jwtAfterLogout).toBeNull();
    expect(addressAfterLogout).toBeNull();
  });
});
