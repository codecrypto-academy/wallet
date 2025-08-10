import { Page } from '@playwright/test';
import { ethers } from 'ethers';

export interface LoginRequest {
  id: string;
  domain: string;
  random: string;
  timestamp: number;
  serverAddress: string;
  signature: string;
  status: 'pending' | 'completed';
}

export interface DeepLinkParams {
  random: string;
  timestamp: string;
  address: string;
  signature: string;
}

export class AuthHelper {
  private wallet: ethers.Wallet;
  private address: string;

  constructor() {
    this.wallet = ethers.Wallet.createRandom();
    this.address = this.wallet.address;
  }

  getWalletAddress(): string {
    return this.address;
  }

  async generateLoginRequest(page: Page): Promise<DeepLinkParams> {
    // Navigate to login page
    await page.goto('/');
    
    // Click generate login button
    await page.click('text=Generate Login QR Code');
    
    // Wait for QR code to appear (SVG from react-qr-code)
    await page.waitForSelector('svg');
    await page.waitForSelector('code');
    
    // Get deep link
    const deepLinkElement = page.locator('code');
    const deepLink = await deepLinkElement.textContent();
    
    if (!deepLink) {
      throw new Error('Deep link not found');
    }

    // Parse deep link parameters
    return this.parseDeepLink(deepLink);
  }

  parseDeepLink(deepLink: string): DeepLinkParams {
    const url = new URL(deepLink.replace('login://', 'https://'));
    const params = new URLSearchParams(url.search);
    
    const random = params.get('aleatorio');
    const timestamp = params.get('timestamp');
    const serverAddress = params.get('address');
    const signature = params.get('signature');

    if (!random || !timestamp || !serverAddress || !signature) {
      throw new Error('Missing required parameters in deep link');
    }

    return {
      random,
      timestamp,
      address: serverAddress,
      signature
    };
  }

  async signMessage(params: DeepLinkParams): Promise<string> {
    const domain = 'ethereum-login-app.com';
    const message = `${domain}${params.random}${params.timestamp}${params.address}`;
    return await this.wallet.signMessage(message);
  }

  async completeAuthentication(page: Page, params: DeepLinkParams): Promise<void> {
    const userSignature = await this.signMessage(params);
    
    // Send verification request
    const response = await page.request.post('/api/auth/verify-signature', {
      data: {
        random: params.random,
        address: this.address,
        signature: userSignature
      }
    });

    if (!response.ok()) {
      throw new Error(`Authentication failed: ${response.statusText()}`);
    }

    // Wait for dashboard to appear
    await page.waitForSelector('text=Welcome to Your Dashboard', { timeout: 30000 });
  }

  async getStoredJWT(page: Page): Promise<string | null> {
    return await page.evaluate(() => localStorage.getItem('jwt'));
  }

  async getStoredAddress(page: Page): Promise<string | null> {
    return await page.evaluate(() => localStorage.getItem('userAddress'));
  }

  async clearStorage(page: Page): Promise<void> {
    await page.evaluate(() => {
      localStorage.removeItem('jwt');
      localStorage.removeItem('userAddress');
      document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    });
  }

  async decodeJWT(jwt: string): Promise<any> {
    // Simple JWT decode for testing purposes
    try {
      const base64Url = jwt.split('.')[1];
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
      const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
      }).join(''));
      return JSON.parse(jsonPayload);
    } catch (e) {
      throw new Error('Invalid JWT format');
    }
  }

  async verifyJWTStructure(jwt: string): Promise<void> {
    const payload = await this.decodeJWT(jwt);
    
    // Verify required fields
    if (!payload.address) {
      throw new Error('JWT missing address field');
    }
    if (!payload.timestamp) {
      throw new Error('JWT missing timestamp field');
    }
    if (!payload.iat) {
      throw new Error('JWT missing iat field');
    }
    if (!payload.exp) {
      throw new Error('JWT missing exp field');
    }

    // Verify address format
    if (!payload.address.match(/^0x[a-fA-F0-9]{40}$/)) {
      throw new Error('JWT address field is not a valid Ethereum address');
    }

    // Verify timestamps
    const currentTime = Math.floor(Date.now() / 1000);
    if (payload.timestamp > currentTime) {
      throw new Error('JWT timestamp is in the future');
    }
    if (payload.exp <= currentTime) {
      throw new Error('JWT has expired');
    }
  }

  async getJWTCookie(page: Page): Promise<string | null> {
    const cookies = await page.context().cookies();
    const jwtCookie = cookies.find(cookie => cookie.name === 'jwt');
    return jwtCookie?.value || null;
  }
}

export function createAuthHelper(): AuthHelper {
  return new AuthHelper();
}
