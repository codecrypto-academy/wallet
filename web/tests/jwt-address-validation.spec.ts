import { test, expect } from '@playwright/test';
import { spawn } from 'child_process';

test.describe('JWT Address Validation', () => {
  test('should store JWT with correct Ethereum address after authentication', async ({ page }) => {
    // Step 1: Generate login request and get deep link
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    await page.click('text=Generate Login QR Code');
    
    // Wait for the state to change and QR code to appear
    await expect(page.locator('text=Scan QR Code')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('main svg')).toBeVisible();
    
    const deepLinkElement = page.locator('code');
    await expect(deepLinkElement).toBeVisible();
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    console.log('Generated deep link:', deepLink);

    // Step 2: Execute test-login.ts to complete authentication
    const testResult = await executeTestLogin(deepLink);
    expect(testResult.success).toBe(true);
    expect(testResult.output).toContain('✅ Authentication completed successfully!');

    // Step 3: Wait for authentication to complete in UI
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });
    
    // Step 4: Get the authenticated address from the dashboard
    const dashboardAddressElement = page.locator('main').locator('text=/0x[a-fA-F0-9]{40}/');
    await expect(dashboardAddressElement).toBeVisible();
    const dashboardAddress = await dashboardAddressElement.textContent();
    
    if (!dashboardAddress) {
      throw new Error('Dashboard address not found');
    }

    console.log('Dashboard shows address:', dashboardAddress);

    // Step 5: Verify JWT storage in localStorage
    const jwt = await page.evaluate(() => localStorage.getItem('jwt'));
    expect(jwt).toBeTruthy();
    expect(typeof jwt).toBe('string');

    const storedAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    expect(storedAddress).toBe(dashboardAddress);

    // Step 6: Decode and verify JWT content
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
    expect(jwtPayload.iat).toBeTruthy();
    expect(jwtPayload.exp).toBeTruthy();

    // Step 7: Verify JWT is also stored in cookies
    const cookies = await page.context().cookies();
    const jwtCookie = cookies.find(cookie => cookie.name === 'jwt');
    expect(jwtCookie).toBeTruthy();
    expect(jwtCookie?.value).toBe(jwt);

    // Step 8: Verify the complete flow - the stored token contains the correct address
    console.log('✅ JWT Address Validation Complete!');
    console.log('Dashboard Address:', dashboardAddress);
    console.log('localStorage Address:', storedAddress);
    console.log('JWT Payload Address:', jwtPayload.address);
    console.log('JWT Token:', jwt);
    console.log('Cookie JWT:', jwtCookie?.value);
    
    // Final assertion: The stored token contains the correct Ethereum address
    expect(jwtPayload.address).toBe(dashboardAddress);
    expect(storedAddress).toBe(dashboardAddress);
    expect(jwtPayload.address).toMatch(/^0x[a-fA-F0-9]{40}$/);
  });

  test('should maintain JWT consistency across page reloads', async ({ page }) => {
    // This test verifies that the JWT persists and remains valid after page reloads
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Generate login request and complete authentication
    await page.click('text=Generate Login QR Code');
    await expect(page.locator('text=Scan QR Code')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('main svg')).toBeVisible();
    
    const deepLinkElement = page.locator('code');
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    // Complete authentication
    const testResult = await executeTestLogin(deepLink);
    expect(testResult.success).toBe(true);

    // Wait for dashboard
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible({ timeout: 30000 });
    
    // Get initial JWT and address
    const initialJwt = await page.evaluate(() => localStorage.getItem('jwt'));
    const initialAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    
    expect(initialJwt).toBeTruthy();
    expect(initialAddress).toBeTruthy();

    // Reload the page
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Verify JWT and address persist
    const reloadedJwt = await page.evaluate(() => localStorage.getItem('jwt'));
    const reloadedAddress = await page.evaluate(() => localStorage.getItem('userAddress'));
    
    expect(reloadedJwt).toBe(initialJwt);
    expect(reloadedAddress).toBe(initialAddress);

    // Verify we're still on dashboard
    await expect(page.locator('text=Welcome to Your Dashboard')).toBeVisible();
    
    console.log('✅ JWT persistence test passed');
    console.log('Initial JWT:', initialJwt);
    console.log('Reloaded JWT:', reloadedJwt);
    console.log('Address consistency:', initialAddress === reloadedAddress);
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
