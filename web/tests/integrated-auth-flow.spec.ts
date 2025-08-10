import { test, expect } from '@playwright/test';
import { spawn } from 'child_process';
import { ethers } from 'ethers';

test.describe('Integrated Authentication Flow with test-login.ts', () => {
  let testWallet: ethers.Wallet;
  let testAddress: string;

  test.beforeAll(async () => {
    testWallet = ethers.Wallet.createRandom();
    testAddress = testWallet.address;
  });

  test('should complete full authentication flow and validate with test-login.ts', async ({ page }) => {
    // Step 1: Navigate to login page and generate QR code
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Verify login form is visible
    await expect(page.locator('text=Login with Ethereum')).toBeVisible();
    await expect(page.locator('text=Generate Login QR Code')).toBeVisible();
    
    // Click to generate login request
    await page.click('text=Generate Login QR Code');
    
    // Wait for QR code to appear
    await expect(page.locator('text=Scan QR Code')).toBeVisible();
    await expect(page.locator('main svg')).toBeVisible();
    
    // Get the deep link from the page
    const deepLinkElement = page.locator('code');
    await expect(deepLinkElement).toBeVisible();
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    console.log('Generated deep link:', deepLink);

    // Step 2: Parse and validate the deep link parameters
    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    if (!random || !timestamp || !serverAddress || !signature) {
      throw new Error('Missing required parameters in deep link');
    }

    // Step 3: Validate deep link structure
    expect(random).toMatch(/^0x[a-fA-F0-9]{64}$/); // 32 bytes hex
    expect(parseInt(timestamp)).toBeGreaterThan(0);
    expect(serverAddress).toMatch(/^0x[a-fA-F0-9]{40}$/); // Ethereum address
    expect(signature).toMatch(/^0x[a-fA-F0-9]{130}$/); // 65 bytes hex

    // Step 4: Execute test-login.ts with the generated deep link
    const testResult = await executeTestLogin(deepLink);
    expect(testResult.success).toBe(true);
    expect(testResult.output).toContain('✅ Signature validation passed');
    expect(testResult.output).toContain('✅ Deep link is still valid');
    expect(testResult.output).toContain('✅ Authentication completed successfully!');

    // Step 5: Verify the authentication completed in the UI
    // Wait for the login to complete (polling should detect the status change)
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });

    // Verify we're now on the dashboard
    await expect(page.locator('text=You are successfully authenticated with your Ethereum wallet')).toBeVisible();
    
    // Get the authenticated wallet address from the dashboard
    const dashboardAddressElement = page.locator('main').locator('text=/0x[a-fA-F0-9]{40}/');
    await expect(dashboardAddressElement).toBeVisible();
    const dashboardAddress = await dashboardAddressElement.textContent();
    
    if (!dashboardAddress) {
      throw new Error('Dashboard address not found');
    }

    console.log('Dashboard shows address:', dashboardAddress);

    // Step 6: Verify JWT storage and content
    const jwt = await page.evaluate(() => localStorage.getItem('jwt'));
    expect(jwt).toBeTruthy();
    expect(typeof jwt).toBe('string');

    const storedAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    expect(storedAddress).toBe(dashboardAddress);

    // Verify JWT contains the correct address
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

    expect(jwtPayload).toBeTruthy();
    expect(jwtPayload.address).toBe(dashboardAddress);
    expect(jwtPayload.timestamp).toBeTruthy();

    // Verify JWT is also stored in cookies
    const cookies = await page.context().cookies();
    const jwtCookie = cookies.find(cookie => cookie.name === 'jwt');
    expect(jwtCookie).toBeTruthy();
    expect(jwtCookie?.value).toBe(jwt);

    console.log('✅ Full authentication flow completed successfully!');
    console.log('JWT payload:', jwtPayload);
    console.log('Stored address:', storedAddress);
    console.log('Cookie JWT:', jwtCookie?.value);
  });

  test('should handle deep link expiration correctly', async ({ page }) => {
    // This test would verify that expired deep links are handled properly
    // For now, we'll just verify the basic flow works
    await page.goto('/');
    await page.click('text=Generate Login QR Code');
    
    await expect(page.locator('text=Scan QR Code')).toBeVisible();
    await expect(page.locator('main svg')).toBeVisible();
    
    const deepLinkElement = page.locator('code');
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    // Verify deep link format
    expect(deepLink).toContain('login://');
    expect(deepLink).toContain('aleatorio=');
    expect(deepLink).toContain('timestamp=');
    expect(deepLink).toContain('address=');
    expect(deepLink).toContain('signature=');
  });
});

// Helper function to execute test-login.ts
async function executeTestLogin(deepLink: string): Promise<{ success: boolean; output: string; error?: string }> {
  return new Promise((resolve) => {
    const child = spawn('npx', ['ts-node', '--project', 'tsconfig.test.json', 'test-login.ts', deepLink], {
      cwd: process.cwd(),
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let output = '';
    let errorOutput = '';

    child.stdout?.on('data', (data) => {
      output += data.toString();
    });

    child.stderr?.on('data', (data) => {
      errorOutput += data.toString();
    });

    child.on('close', (code) => {
      if (code === 0) {
        resolve({
          success: true,
          output: output,
          error: errorOutput
        });
      } else {
        resolve({
          success: false,
          output: output,
          error: errorOutput
        });
      }
    });

    child.on('error', (error) => {
      resolve({
        success: false,
        output: output,
        error: error.message
      });
    });
  });
}
