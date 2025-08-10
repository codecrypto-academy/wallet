import { NextRequest, NextResponse } from 'next/server';
import { ethers } from 'ethers';
import { MongoClient } from 'mongodb';
import jwt from 'jsonwebtoken';

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const client = new MongoClient(uri);
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

interface VerifyRequest {
  random: string;
  address: string;
  signature: string;
}

export async function POST(request: NextRequest) {
  try {
    const body: VerifyRequest = await request.json();
    const { random, address, signature } = body;
    
    await client.connect();
    const db = client.db('ethereum-login');
    const collection = db.collection('login-requests');
    
    // Find the login request by random value
    const loginRequest = await collection.findOne({ 
      random,
      status: 'pending',
      expiresAt: { $gt: new Date() }
    });
    
    if (!loginRequest) {
      return NextResponse.json(
        { error: 'Invalid or expired login request' },
        { status: 400 }
      );
    }
    
    // Verify the signature
    const message = `${loginRequest.domain}${random}${loginRequest.timestamp}${loginRequest.serverAddress}`;
    const recoveredAddress = ethers.verifyMessage(message, signature);
    
    if (recoveredAddress.toLowerCase() !== address.toLowerCase()) {
      return NextResponse.json(
        { error: 'Invalid signature' },
        { status: 400 }
      );
    }
    
    // Generate JWT
    const token = jwt.sign(
      { 
        address,
        timestamp: Math.floor(Date.now() / 1000)
      },
      JWT_SECRET,
      { expiresIn: '3m' } // 3 minutes
    );
    
    // Update the login request
    await collection.updateOne(
      { _id: loginRequest._id },
      {
        $set: {
          status: 'completed',
          userAddress: address,
          jwt: token,
          completedAt: new Date()
        }
      }
    );
    
    return NextResponse.json({
      success: true,
      message: 'Authentication successful'
    });
    
  } catch (error) {
    console.error('Error verifying signature:', error);
    return NextResponse.json(
      { error: 'Failed to verify signature' },
      { status: 500 }
    );
  } finally {
    await client.close();
  }
}
