'use client';

import React, { useState, useEffect } from 'react';
import { useGlobalContext } from '../contexts/GlobalContext';
import QRCode from 'react-qr-code';

interface LoginRequest {
  id: string;
  domain: string;
  random: string;
  timestamp: number;
  serverAddress: string;
  signature: string;
  status: 'pending' | 'completed';
}

const LoginForm: React.FC = () => {
  const { login } = useGlobalContext();
  const [loginRequest, setLoginRequest] = useState<LoginRequest | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pollingInterval, setPollingInterval] = useState<NodeJS.Timeout | null>(null);

  const generateLoginRequest = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const response = await fetch('/api/auth/generate-login', {
        method: 'POST',
      });
      
      if (!response.ok) {
        throw new Error('Failed to generate login request');
      }
      
      const data = await response.json();
      setLoginRequest(data);
      
      // Start polling for status updates
      startPolling(data.id);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  const startPolling = (requestId: string) => {
    const interval = setInterval(async () => {
      try {
        const response = await fetch(`/api/auth/check-status/${requestId}`);
        if (response.ok) {
          const data = await response.json();
          
          if (data.status === 'completed') {
            // Login successful
            clearInterval(interval);
            setPollingInterval(null);
            
            // Store JWT
            localStorage.setItem('jwt', data.jwt);
            document.cookie = `jwt=${data.jwt}; path=/; max-age=180;`; // 3 minutes
            
            // Update global context
            login(data.userAddress);
            
            // Clean up
            setLoginRequest(null);
          }
        }
      } catch (err) {
        console.error('Polling error:', err);
      }
    }, 1000);
    
    setPollingInterval(interval);
  };

  const stopPolling = () => {
    if (pollingInterval) {
      clearInterval(pollingInterval);
      setPollingInterval(null);
    }
  };

  useEffect(() => {
    return () => {
      stopPolling();
    };
  }, []);

  const generateDeepLink = (request: LoginRequest) => {
    const params = new URLSearchParams({
      aleatorio: request.random,
      timestamp: request.timestamp.toString(),
      address: request.serverAddress,
      signature: request.signature,
    });
    
    return `login://${request.domain}?${params.toString()}`;
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Generating login request...</p>
        </div>
      </div>
    );
  }

  if (loginRequest) {
    const deepLink = generateDeepLink(loginRequest);
    
    return (
      <div className="max-w-md mx-auto bg-white rounded-lg shadow-lg p-6">
        <div className="text-center mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Scan QR Code</h2>
          <p className="text-gray-600">
            Scan this QR code with your Ethereum wallet to login
          </p>
        </div>
        
        <div className="flex justify-center mb-6">
          <div className="bg-white p-4 rounded-lg border-2 border-gray-200">
            <QRCode value={deepLink} size={200} />
          </div>
        </div>
        
        <div className="text-center">
          <p className="text-sm text-gray-500 mb-2">Or copy the deep link:</p>
          <div className="bg-gray-100 p-3 rounded-md">
            <code className="text-xs break-all text-gray-700">{deepLink}</code>
          </div>
        </div>
        
        <div className="mt-6 text-center">
          <button
            onClick={() => {
              stopPolling();
              setLoginRequest(null);
            }}
            className="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
          >
            Cancel
          </button>
        </div>
        
        <div className="mt-4 text-center">
          <div className="inline-flex items-center text-sm text-blue-600">
            <div className="animate-pulse w-2 h-2 bg-blue-600 rounded-full mr-2"></div>
            Waiting for wallet signature...
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto bg-white rounded-lg shadow-lg p-6">
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Login with Ethereum</h2>
        <p className="text-gray-600">
          Generate a QR code to authenticate with your Ethereum wallet
        </p>
      </div>
      
      {error && (
        <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-md text-sm">
          {error}
        </div>
      )}
      
      <button
        onClick={generateLoginRequest}
        className="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        Generate Login QR Code
      </button>
    </div>
  );
};

export default LoginForm;
