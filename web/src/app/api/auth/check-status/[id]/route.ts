import { NextRequest, NextResponse } from 'next/server';
import { MongoClient } from 'mongodb';

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const client = new MongoClient(uri);

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    await client.connect();
    const db = client.db('ethereum-login');
    const collection = db.collection('login-requests');
    
    const loginRequest = await collection.findOne({ id });
    
    if (!loginRequest) {
      return NextResponse.json(
        { error: 'Login request not found' },
        { status: 404 }
      );
    }
    
    // Check if expired
    if (new Date() > loginRequest.expiresAt) {
      return NextResponse.json(
        { error: 'Login request expired' },
        { status: 410 }
      );
    }
    
    return NextResponse.json({
      id: loginRequest.id,
      status: loginRequest.status,
      userAddress: loginRequest.userAddress,
      jwt: loginRequest.jwt
    });
    
  } catch (error) {
    console.error('Error checking login status:', error);
    return NextResponse.json(
      { error: 'Failed to check login status' },
      { status: 500 }
    );
  } finally {
    await client.close();
  }
}
