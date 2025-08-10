import { ethers } from 'ethers';

interface LoginDeepLink {
  domain: string;
  random: string;
  timestamp: number;
  address: string;
  signature: string;
}

class LoginTester {
  private wallet: ethers.HDNodeWallet;

  constructor() {
    // Generate a new Ethereum wallet for testing
    this.wallet = ethers.Wallet.createRandom();
    console.log('Generated test wallet:');
    console.log('Private Key:', this.wallet.privateKey);
    console.log('Address:', this.wallet.address);
    console.log('---');
  }

  parseDeepLink(deepLink: string): LoginDeepLink {
    try {
      // Parse the deep link: login://dominio?aleatorio=...&timestamp=...&address=...&signature=...
      const url = new URL(deepLink.replace('login://', 'http://'));
      const params = new URLSearchParams(url.search);
      
      return {
        domain: url.hostname,
        random: params.get('aleatorio') || '',
        timestamp: parseInt(params.get('timestamp') || '0'),
        address: params.get('address') || '',
        signature: params.get('signature') || ''
      };
    } catch (error) {
      throw new Error(`Invalid deep link format: ${error}`);
    }
  }

  validateSignature(deepLink: LoginDeepLink): boolean {
    try {
      // Recreate the message that was signed
      const message = `${deepLink.domain}${deepLink.random}${deepLink.timestamp}${deepLink.address}`;
      
      // Verify the signature
      const recoveredAddress = ethers.verifyMessage(message, deepLink.signature);
      
      // Check if the recovered address matches the server address
      const isValid = recoveredAddress.toLowerCase() === deepLink.address.toLowerCase();
      
      console.log('Signature validation:');
      console.log('Message:', message);
      console.log('Recovered address:', recoveredAddress);
      console.log('Server address:', deepLink.address);
      console.log('Signature valid:', isValid);
      console.log('---');
      
      return isValid;
    } catch (error) {
      console.error('Error validating signature:', error);
      return false;
    }
  }

  async authenticateWithServer(deepLink: LoginDeepLink): Promise<boolean> {
    try {
      // Create the message to sign with our wallet
      const message = `${deepLink.domain}${deepLink.random}${deepLink.timestamp}${deepLink.address}`;
      
      // Sign the message with our wallet
      const signature = await this.wallet.signMessage(message);
      
      console.log('Client authentication:');
      console.log('Message to sign:', message);
      console.log('Client signature:', signature);
      console.log('---');
      
      // Make POST request to the server
      const response = await fetch('http://localhost:3000/api/auth/verify-signature', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          random: deepLink.random,
          address: this.wallet.address,
          signature: signature
        })
      });
      
      if (response.ok) {
        const result = await response.json();
        console.log('Server response:', result);
        console.log('Authentication successful!');
        return true;
      } else {
        const error = await response.text();
        console.error('Authentication failed:', error);
        return false;
      }
    } catch (error) {
      console.error('Error during authentication:', error);
      return false;
    }
  }

  async testLoginFlow(deepLinkString: string): Promise<void> {
    console.log('=== Ethereum Login Test ===');
    console.log('Deep link:', deepLinkString);
    console.log('---');
    
    try {
      // Step 1: Parse the deep link
      const deepLink = this.parseDeepLink(deepLinkString);
      console.log('Parsed deep link:', deepLink);
      console.log('---');
      
      // Step 2: Validate the signature
      const isSignatureValid = this.validateSignature(deepLink);
      if (!isSignatureValid) {
        console.error('❌ Signature validation failed');
        return;
      }
      console.log('✅ Signature validation passed');
      console.log('---');
      
      // Step 3: Check timestamp expiration (10 minutes)
      const currentTime = Math.floor(Date.now() / 1000);
      const timeDiff = currentTime - deepLink.timestamp;
      const isExpired = timeDiff > 600; // 10 minutes
      
      if (isExpired) {
        console.error('❌ Deep link expired');
        console.log(`Timestamp: ${deepLink.timestamp} (${new Date(deepLink.timestamp * 1000).toISOString()})`);
        console.log(`Current time: ${currentTime} (${new Date().toISOString()})`);
        console.log(`Time difference: ${timeDiff} seconds`);
        return;
      }
      console.log('✅ Deep link is still valid');
      console.log(`Time difference: ${timeDiff} seconds`);
      console.log('---');
      
      // Step 4: Authenticate with the server
      const authSuccess = await this.authenticateWithServer(deepLink);
      if (authSuccess) {
        console.log('✅ Authentication completed successfully!');
        console.log(`User address: ${this.wallet.address}`);
      } else {
        console.error('❌ Authentication failed');
      }
      
    } catch (error) {
      console.error('❌ Test failed:', error);
    }
    
    console.log('=== Test Complete ===');
  }
}

// Example usage
async function main() {
  const tester = new LoginTester();
  
  // Get deep link from command line arguments
  const args = process.argv.slice(2);
  let deepLink: string;
  
  if (args.length > 0) {
    deepLink = args[0];
    console.log('Using deep link from command line argument');
  } else {
    // Example deep link (replace with actual deep link from your app)
    deepLink = 'login://ethereum-login-app.com?aleatorio=0x3ff583a8d2d95de01ea2aca665d3e77036956d9314652497992f087a363f7fd5&timestamp=1754814774&address=0x8d3d7ee38990cf9DdbaB0366073Ad510794fA6D6&signature=0xbf889a29dfe9967190f16ff7af36dde23e40d16c35113e4aeadfd3cdb92f2b7117d73eab9da6e51d8b262addc249ed48fc2b9267aad5aee3551f5709f04de5f41c';
    console.log('No deep link provided, using example deep link');
    console.log('Usage: npm run test:login <deep-link>');
    console.log('Example: npm run test:login "login://ethereum-login-app.com?aleatorio=...&timestamp=...&address=...&signature=..."');
    console.log('---');
  }
  
  console.log('Note: This is a test program. To use with your actual app:');
  console.log('1. Start your Next.js app');
  console.log('2. Generate a login QR code');
  console.log('3. Copy the deep link and pass it as a command line argument');
  console.log('4. Run this program');
  console.log('---');
  
  await tester.testLoginFlow(deepLink);
}

if (require.main === module) {
  main().catch(console.error);
}

export { LoginTester };
