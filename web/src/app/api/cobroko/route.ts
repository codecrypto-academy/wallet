import { NextRequest, NextResponse } from 'next/server';
import { MongoClient } from 'mongodb';

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const client = new MongoClient(uri);

interface CobrokoRequest {
  from: string;
  to: string;
  amount: string;
  endpoint: string;
  error?: string;
  transactionId?: string;
}

export async function POST(request: NextRequest) {
  try {
    const body: CobrokoRequest = await request.json();
    const { from, to, amount, endpoint, error, transactionId } = body;
    
    // Validate required fields
    if (!from || !to || !amount || !endpoint) {
      return NextResponse.json(
        { error: 'Missing required fields: from, to, amount, endpoint' },
        { status: 400 }
      );
    }
    
    await client.connect();
    const db = client.db('ethereum-payment');
    const collection = db.collection('payment-requests');
    
    let updateResult;
    
    if (transactionId) {
      // Update existing transaction
      updateResult = await collection.updateOne(
        { transactionId },
        {
          $set: {
            status: 'failed',
            error: error || 'Transaction failed or was cancelled by user',
            failedAt: new Date(),
            updatedAt: new Date(),
          }
        }
      );
    } else {
      // Create new failed transaction record (fallback)
      const failedTransactionId = `tx_failed_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      const failedPaymentRequest = {
        transactionId: failedTransactionId,
        from,
        to,
        amount,
        endpoint,
        status: 'failed',
        error: error || 'Transaction failed or was cancelled by user',
        createdAt: new Date(),
        failedAt: new Date(),
        updatedAt: new Date(),
      };
      
      updateResult = await collection.insertOne(failedPaymentRequest);
    }
    
    console.log('Payment failure recorded:', {
      transactionId: transactionId || 'new_failed_transaction',
      from,
      to,
      amount,
      endpoint,
      error: error || 'Transaction failed or was cancelled by user'
    });
    
    return NextResponse.json({
      success: true,
      message: 'Payment failure recorded successfully',
      data: {
        transactionId: transactionId || 'new_failed_transaction',
        from,
        to,
        amount,
        endpoint,
        status: 'failed',
        error: error || 'Transaction failed or was cancelled by user'
      }
    });
    
  } catch (error) {
    console.error('Error recording payment failure:', error);
    return NextResponse.json(
      { error: 'Failed to record payment failure' },
      { status: 500 }
    );
  } finally {
    await client.close();
  }
}
