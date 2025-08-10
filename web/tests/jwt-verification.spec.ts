import { test, expect } from '@playwright/test';
import { ethers } from 'ethers';

test.describe('JWT Token Verification', () => {
  let testWallet: ethers.Wallet;
  let testAddress: string;

  test.beforeAll(async () => {
    testWallet = ethers.Wallet.createRandom();
    testAddress = testWallet.address;
  });

  test('should generate JWT with correct wallet address', async ({ page }) => {
    // Complete authentication flow
    await page.goto('/');
    await page.click('text=Generate Login QR Code');
    
    // Get QR code parameters
    await expect(page.locator('svg')).toBeVisible();
    const deepLinkElement = page.locator('code');
    await expect(deepLinkElement).toBeVisible();
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    if (!random || !timestamp || !serverAddress || !signature) {
      throw new Error('Missing required parameters in deep link');
    }

    // Sign the message
    const domain = 'ethereum-login-app.com';
    const message = `${domain}${random}${timestamp}${serverAddress}`;
    const userSignature = await testWallet.signMessage(message);

    // Verify signature
    const verifyResponse = await page.request.post('/api/auth/verify-signature', {
      data: {
        random,
        address: testAddress,
        signature: userSignature
      }
    });

    expect(verifyResponse.ok()).toBeTruthy();

    // Wait for authentication to complete
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });

    // Get JWT from localStorage
    const jwt = await page.evaluate(() => localStorage.getItem('jwt'));
    expect(jwt).toBeTruthy();

    // Decode and verify JWT payload
    const jwtPayload = await page.evaluate((token) => {
      try {
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

    // Verify JWT structure
    expect(jwtPayload).toBeTruthy();
    expect(jwtPayload).toHaveProperty('address');
    expect(jwtPayload).toHaveProperty('timestamp');
    expect(jwtPayload).toHaveProperty('iat'); // issued at
    expect(jwtPayload).toHaveProperty('exp'); // expiration

    // Verify the address matches exactly
    expect(jwtPayload.address).toBe(testAddress);
    expect(jwtPayload.address).toMatch(/^0x[a-fA-F0-9]{40}$/); // Ethereum address format

    // Verify timestamp is recent (within last minute)
    const currentTime = Math.floor(Date.now() / 1000);
    expect(jwtPayload.timestamp).toBeLessThanOrEqual(currentTime);
    expect(jwtPayload.timestamp).toBeGreaterThan(currentTime - 60);

    // Verify JWT expiration (should be 3 minutes from now)
    expect(jwtPayload.exp).toBeGreaterThan(currentTime);
    expect(jwtPayload.exp).toBeLessThanOrEqual(currentTime + 180); // 3 minutes
  });

  test('should store JWT in both localStorage and cookies', async ({ page }) => {
    // Complete authentication flow
    await page.goto('/');
    await page.click('text=Generate Login QR Code');
    
    const deepLinkElement = page.locator('code');
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    if (!random || !timestamp || !serverAddress || !signature) {
      throw new Error('Missing required parameters in deep link');
    }

    const domain = 'ethereum-login-app.com';
    const message = `${domain}${random}${timestamp}${serverAddress}`;
    const userSignature = await testWallet.signMessage(message);

    await page.request.post('/api/auth/verify-signature', {
      data: {
        random,
        address: testAddress,
        signature: userSignature
      }
    });

    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });

    // Check localStorage
    const localStorageJWT = await page.evaluate(() => localStorage.getItem('jwt'));
    const localStorageAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    
    expect(localStorageJWT).toBeTruthy();
    expect(localStorageAddress).toBe(testAddress);

    // Check cookies
    const cookies = await page.context().cookies();
    const jwtCookie = cookies.find(cookie => cookie.name === 'jwt');
    
    expect(jwtCookie).toBeTruthy();
    expect(jwtCookie?.value).toBe(localStorageJWT);
    expect(jwtCookie?.path).toBe('/');

    // Verify both storage locations have the same JWT
    expect(localStorageJWT).toBe(jwtCookie?.value);
  });

  test('should handle multiple authentication attempts with different addresses', async ({ page }) => {
    // First authentication
    await page.goto('/');
    await page.click('text=Generate Login QR Code');
    
    const deepLinkElement = page.locator('code');
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    if (!random || !timestamp || !serverAddress || !signature) {
      throw new Error('Missing required parameters in deep link');
    }

    const domain = 'ethereum-login-app.com';
    const message = `${domain}${random}${timestamp}${serverAddress}`;
    const userSignature = await testWallet.signMessage(message);

    await page.request.post('/api/auth/verify-signature', {
      data: {
        random,
        address: testAddress,
        signature: userSignature
      }
    });

    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });

    // Verify first address
    const firstJWT = await page.evaluate(() => localStorage.getItem('jwt'));
    const firstAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    
    expect(firstAddress).toBe(testAddress);

    // Clear storage and try with a different address
    await page.evaluate(() => {
      localStorage.removeItem('jwt');
      localStorage.removeItem('userAddress');
      document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
      window.location.reload();
    });

    await expect(page.locator('text=Login with Ethereum')).toBeVisible();

    // Create a second wallet
    const secondWallet = ethers.Wallet.createRandom();
    const secondAddress = secondWallet.address;

    // Generate new login request
    await page.click('text=Generate Login QR Code');
    
    const secondDeepLinkElement = page.locator('code');
    const secondDeepLink = await secondDeepLinkElement.textContent();
    
    if (!secondDeepLink) {
      throw new Error('Second deep link not found');
    }

    const secondUrl = new URL(secondDeepLink.replace('login://', 'https://'));
    const secondParams = new URLSearchParams(secondUrl.search);
    
    const secondRandom = secondParams.get('aleatorio');
    const secondTimestamp = secondParams.get('timestamp');
    const secondServerAddress = secondParams.get('address');
    const secondSignature = secondParams.get('signature');

    if (!secondRandom || !secondTimestamp || !secondServerAddress || !secondSignature) {
      throw new Error('Missing required parameters in second deep link');
    }

    const secondMessage = `${domain}${secondRandom}${secondTimestamp}${secondServerAddress}`;
    const secondUserSignature = await secondWallet.signMessage(secondMessage);

    await page.request.post('/api/auth/verify-signature', {
      data: {
        random: secondRandom,
        address: secondAddress,
        signature: secondUserSignature
      }
    });

    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });

    // Verify second address
    const secondJWT = await page.evaluate(() => localStorage.getItem('jwt'));
    const secondStoredAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    
    expect(secondStoredAddress).toBe(secondAddress);
    expect(secondAddress).not.toBe(testAddress);

    // Verify JWT payloads are different
    const firstPayload = await page.evaluate((token) => {
      try {
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
          return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        return JSON.parse(jsonPayload);
      } catch (e) {
        return null;
      }
    }, firstJWT);

    const secondPayload = await page.evaluate((token) => {
      try {
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
          return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        return JSON.parse(jsonPayload);
      } catch (e) {
        return null;
      }
    }, secondJWT);

    expect(firstPayload.address).toBe(testAddress);
    expect(secondPayload.address).toBe(secondAddress);
    expect(firstPayload.address).not.toBe(secondPayload.address);
  });
});
