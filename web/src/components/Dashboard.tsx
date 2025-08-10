'use client';

import React from 'react';
import { useGlobalContext } from '../contexts/GlobalContext';

const Dashboard: React.FC = () => {
  const { user } = useGlobalContext();
   
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
