import { test, expect } from '@playwright/test';

test.describe('Debug Tests', () => {
  test('should show login form initially', async ({ page }) => {
    await page.goto('/');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Take screenshot for debugging
    await page.screenshot({ path: 'debug-initial-state.png' });
    
    // Check if we can see the login form
    await expect(page.locator('text=Login with Ethereum')).toBeVisible();
    
    // Check if the button is visible
    await expect(page.locator('text=Generate Login QR Code')).toBeVisible();
  });

  test('should generate QR code after clicking button', async ({ page }) => {
    await page.goto('/');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Click the button
    await page.click('text=Generate Login QR Code');
    
    // Wait a bit for the request to complete
    await page.waitForTimeout(2000);
    
    // Take screenshot for debugging
    await page.screenshot({ path: 'debug-after-click.png' });
    
    // Check if we can see the QR code section
    await expect(page.locator('text=Scan QR Code')).toBeVisible();
    
    // Check if SVG is present
    await expect(page.locator('svg')).toBeVisible();
    
    // Check if deep link is present
    await expect(page.locator('code')).toBeVisible();
  });

  test('should show page content', async ({ page }) => {
    await page.goto('/');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Log page content for debugging
    const content = await page.content();
    console.log('Page content:', content.substring(0, 1000));
    
    // Check if we can see any text
    await expect(page.locator('body')).toBeVisible();
  });
});
