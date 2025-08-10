import { NextRequest, NextResponse } from 'next/server';
import { ethers } from 'ethers';
import { MongoClient } from 'mongodb';

// MongoDB connection
const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const client = new MongoClient(uri);

interface LoginRequest {
  id: string;
  domain: string;
  random: string;
  timestamp: number;
  serverAddress: string;
  signature: string;
  status: 'pending' | 'completed';
}

export async function POST(request: NextRequest) {
  try {
    // Generate server wallet
    const serverWallet = ethers.Wallet.createRandom();
    const serverAddress = serverWallet.address;
    
    // Generate random data
    const random = ethers.hexlify(ethers.randomBytes(32));
    const timestamp = Math.floor(Date.now() / 1000);
    const domain = 'ethereum-login-app.com';
    
    // Create message to sign
    const message = `${domain}${random}${timestamp}${serverAddress}`;
    
    // Sign the message
    const signature = await serverWallet.signMessage(message);
    
    // Create login request
    const loginRequest: LoginRequest = {
      id: ethers.hexlify(ethers.randomBytes(16)),
      domain,
      random,
      timestamp,
      serverAddress,
      signature,
      status: 'pending'
    };
    
    // Store in MongoDB
    await client.connect();
    const db = client.db('ethereum-login');
    const collection = db.collection('login-requests');
    
    await collection.insertOne({
      ...loginRequest,
      createdAt: new Date(),
      expiresAt: new Date((timestamp + 600) * 1000) // 10 minutes
    });
    
    // Return the login request (without sensitive data)
    return NextResponse.json({
      id: loginRequest.id,
      domain: loginRequest.domain,
      random: loginRequest.random,
      timestamp: loginRequest.timestamp,
      serverAddress: loginRequest.serverAddress,
      signature: loginRequest.signature,
      status: loginRequest.status
    });
    
  } catch (error) {
    console.error('Error generating login request:', error);
    return NextResponse.json(
      { error: 'Failed to generate login request' },
      { status: 500 }
    );
  } finally {
    await client.close();
  }
}
