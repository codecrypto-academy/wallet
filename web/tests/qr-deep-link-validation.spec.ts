import { test, expect } from '@playwright/test';

test.describe('QR Code and Deep Link Generation', () => {
  test('should generate QR code and deep link correctly', async ({ page }) => {
    // Navigate to login page
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Verify initial state
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

    // Validate deep link format
    expect(deepLink).toContain('login://');
    
    // Parse the deep link parameters
    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    // Verify all required parameters are present
    expect(random).toBeTruthy();
    expect(timestamp).toBeTruthy();
    expect(serverAddress).toBeTruthy();
    expect(signature).toBeTruthy();

    // Verify parameter formats
    expect(random).toMatch(/^0x[a-fA-F0-9]{64}$/); // 32 bytes hex
    expect(parseInt(timestamp)).toBeGreaterThan(0);
    expect(serverAddress).toMatch(/^0x[a-fA-F0-9]{40}$/); // Ethereum address
    expect(signature).toMatch(/^0x[a-fA-F0-9]{130}$/); // 65 bytes hex

    // Verify timestamp is recent (within last 5 minutes)
    const currentTime = Math.floor(Date.now() / 1000);
    const linkTime = parseInt(timestamp);
    const timeDiff = Math.abs(currentTime - linkTime);
    expect(timeDiff).toBeLessThan(300); // 5 minutes

    console.log('✅ Deep link validation passed:');
    console.log('Random:', random);
    console.log('Timestamp:', timestamp, `(${new Date(linkTime * 1000).toISOString()})`);
    console.log('Server Address:', serverAddress);
    console.log('Signature:', signature);
    console.log('Time difference:', timeDiff, 'seconds');
  });

  test('should show correct UI elements after QR generation', async ({ page }) => {
    await page.goto('/');
    await page.click('text=Generate Login QR Code');
    
    // Verify all expected elements are visible
    await expect(page.locator('text=Scan QR Code')).toBeVisible();
    await expect(page.locator('main svg')).toBeVisible();
    await expect(page.locator('code')).toBeVisible();
    
    // Verify the QR code SVG has proper dimensions
    const svgElement = page.locator('main svg');
    const svgBox = await svgElement.boundingBox();
    expect(svgBox).toBeTruthy();
    expect(svgBox?.width).toBeGreaterThan(100);
    expect(svgBox?.height).toBeGreaterThan(100);
    
    // Verify the deep link code element is properly formatted
    const codeElement = page.locator('code');
    const codeText = await codeElement.textContent();
    expect(codeText).toContain('login://');
    expect(codeText?.length).toBeGreaterThan(100); // Should be a substantial deep link
  });
});
