'use client';

import React, { useState, useEffect } from 'react';
import { useGlobalContext } from '../contexts/GlobalContext';
import QRCode from 'react-qr-code';

const Dashboard: React.FC = () => {
  const { user } = useGlobalContext();
  const [isProcessingPayment, setIsProcessingPayment] = useState(false);
  const [showPaymentQR, setShowPaymentQR] = useState(false);
  const [paymentDeepLink, setPaymentDeepLink] = useState<string>('');

  const handlePayment = async () => {
    if (!user?.address) {
      alert('User address not available');
      return;
    }

    setIsProcessingPayment(true);

    try {
      // Call /api/cobro endpoint before redirecting
      const cobroResponse = await fetch('/api/cobro', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: user.address,
          to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
          amount: '10',
          endpoint: 'http://localhost:8545'
        }),
      });

      if (!cobroResponse.ok) {
        throw new Error('Failed to initiate payment on server');
      }

      // Generate the deeplink for payment
      const generatedDeepLink = `tx://?txType=transfer&from=${user.address}&to=0x70997970C51812dc3A010C7d01b50e0d17dc79C8&amount=10&endpoint=http://localhost:8545`;
      
      // Store the deeplink and show QR code
      console.log('Generated payment deeplink:', generatedDeepLink);
      setPaymentDeepLink(generatedDeepLink);
      setShowPaymentQR(true);
      console.log('Payment QR should be visible now');
      
    } catch (error) {
      console.error('Payment initiation failed:', error);
      alert('Failed to initiate payment. Please try again.');
      
      // Call /api/cobroko endpoint on failure
      try {
        await fetch('/api/cobroko', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: user.address,
            to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
            amount: '10',
            endpoint: 'http://localhost:8545',
            error: error instanceof Error ? error.message : 'Unknown error'
          }),
        });
      } catch (cobrokoError) {
        console.error('Failed to report payment failure:', cobrokoError);
      }
    } finally {
      setIsProcessingPayment(false);
    }
  };

  const handleClosePaymentQR = () => {
    setShowPaymentQR(false);
    setPaymentDeepLink('');
  };

  // Debug effect to monitor state changes
  useEffect(() => {
    console.log('Dashboard state updated:', { 
      showPaymentQR, 
      paymentDeepLink: paymentDeepLink.substring(0, 50) + '...',
      isProcessingPayment 
    });
  }, [showPaymentQR, paymentDeepLink, isProcessingPayment]);
   
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="text-center mb-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Welcome to Your Dashboard
          </h2>
          <p className="text-lg text-gray-600">
            You are successfully authenticated with your Ethereum wallet
          </p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-blue-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-blue-900 mb-3">
              Wallet Information
            </h3>
            <div className="space-y-2">
              <div>
                <span className="text-sm font-medium text-blue-700">Address:</span>
                <div className="mt-1 p-2 bg-blue-100 rounded font-mono text-sm text-blue-800 break-all">
                  {user?.address}
                </div>
              </div>
              <div>
                <span className="text-sm font-medium text-blue-700">Network:</span>
                <span className="ml-2 text-sm text-blue-600">Ethereum</span>
              </div>
            </div>
          </div>
          
          <div className="bg-green-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-green-900 mb-3">
              Authentication Status
            </h3>
            <div className="space-y-2">
              <div className="flex items-center">
                <div className="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
                <span className="text-sm text-green-700">Authenticated</span>
              </div>
              <div className="text-sm text-green-600">
                JWT stored securely in cookies and localStorage
              </div>
            </div>
          </div>
        </div>
        
        <div className="mt-8 bg-purple-50 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-purple-900 mb-3">
            Payment Actions
          </h3>
          
          {!showPaymentQR ? (
            <div className="space-y-4">
              <p className="text-sm text-purple-600 mb-4">
                Make a payment of 10 ETH to the configured recipient address
              </p>
              <button
                onClick={handlePayment}
                disabled={isProcessingPayment}
                className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-purple-400 text-white px-6 py-3 rounded-md text-sm font-medium transition-colors"
              >
                {isProcessingPayment ? 'Processing Payment...' : 'Generate Payment QR Code'}
              </button>
              <div className="text-xs text-purple-500">
                <p><strong>To:</strong> 0x70997970C51812dc3A010C7d01b50e0d17dc79C8</p>
                <p><strong>Amount:</strong> 10 ETH</p>
                <p><strong>Network:</strong> http://localhost:8545</p>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="text-center mb-6">
                <h4 className="text-lg font-semibold text-purple-900 mb-2">Scan QR Code for Payment</h4>
                <p className="text-sm text-purple-600">
                  Scan this QR code with your Ethereum wallet to authorize the payment
                </p>
                <p className="text-xs text-red-500 mt-2">
                  DEBUG: QR should be visible. DeepLink length: {paymentDeepLink.length}
                </p>
              </div>
              
              <div className="flex justify-center mb-6">
                <div className="bg-white p-4 rounded-lg border-2 border-purple-200">
                  {paymentDeepLink ? (
                    <QRCode value={paymentDeepLink} size={200} />
                  ) : (
                    <div className="w-[200px] h-[200px] bg-gray-200 flex items-center justify-center text-gray-500">
                      No QR Data
                    </div>
                  )}
                </div>
              </div>
              
              <div className="text-center">
                <p className="text-sm text-purple-600 mb-2">Or copy the deep link:</p>
                <div className="bg-purple-100 p-3 rounded-md">
                  <code className="text-xs break-all text-purple-800">{paymentDeepLink}</code>
                </div>
              </div>
              
              <div className="text-center">
                <p className="text-sm text-purple-600 mb-2">iOS Simulator Command:</p>
                <div className="bg-purple-100 p-3 rounded-md">
                  <code className="text-xs break-all text-purple-800">{`xcrun simctl openurl booted "${paymentDeepLink}"`}</code>
                </div>
              </div>
              
              <div className="flex gap-3 mt-6">
                <button
                  onClick={handleClosePaymentQR}
                  className="flex-1 bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={() => window.location.href = paymentDeepLink}
                  className="flex-1 bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Open in Wallet
                </button>
              </div>
              
              <div className="text-xs text-purple-500 mt-4">
                <p><strong>To:</strong> 0x70997970C51812dc3A010C7d01b50e0d17dc79C8</p>
                <p><strong>Amount:</strong> 10 ETH</p>
                <p><strong>From:</strong> {user?.address}</p>
                <p><strong>Network:</strong> http://localhost:8545</p>
              </div>
            </div>
          )}
        </div>
        
        <div className="mt-8 bg-gray-50 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            How it Works
          </h3>
          <div className="text-sm text-gray-600 space-y-2">
            <p>1. You scanned a QR code with your Ethereum wallet</p>
            <p>2. Your wallet signed the authentication data</p>
            <p>3. The signature was verified on our servers</p>
            <p>4. You received a JWT token for secure access</p>
            <p>5. Your wallet address is now displayed in the header</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
