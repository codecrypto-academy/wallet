import { NextRequest, NextResponse } from 'next/server';
import { MongoClient } from 'mongodb';

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const client = new MongoClient(uri);

interface CobroRequest {
  from: string;
  to: string;
  amount: string;
  endpoint: string;
}

export async function POST(request: NextRequest) {
  try {
    const body: CobroRequest = await request.json();
    const { from, to, amount, endpoint } = body;
    
    // Validate required fields
    if (!from || !to || !amount || !endpoint) {
      return NextResponse.json(
        { error: 'Missing required fields: from, to, amount, endpoint' },
        { status: 400 }
      );
    }
    
    // Validate Ethereum addresses
    const addressRegex = /^0x[a-fA-F0-9]{40}$/;
    if (!addressRegex.test(from) || !addressRegex.test(to)) {
      return NextResponse.json(
        { error: 'Invalid Ethereum address format' },
        { status: 400 }
      );
    }
    
    // Validate amount is a positive number
    const amountNum = parseFloat(amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      return NextResponse.json(
        { error: 'Amount must be a positive number' },
        { status: 400 }
      );
    }
    
    // Generate transaction ID
    const transactionId = `tx_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    await client.connect();
    const db = client.db('ethereum-payment');
    const collection = db.collection('payment-requests');
    
    // Create payment request record
    const paymentRequest = {
      transactionId,
      from,
      to,
      amount,
      endpoint,
      status: 'initiated',
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    
    await collection.insertOne(paymentRequest);
    
    console.log('Payment request initiated:', {
      transactionId,
      from,
      to,
      amount,
      endpoint
    });
    
    return NextResponse.json({
      success: true,
      message: 'Payment request initiated successfully',
      transactionId,
      data: {
        from,
        to,
        amount,
        endpoint
      }
    });
    
  } catch (error) {
    console.error('Error initiating payment:', error);
    return NextResponse.json(
      { error: 'Failed to initiate payment request' },
      { status: 500 }
    );
  } finally {
    await client.close();
  }
}
