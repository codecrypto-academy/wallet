'use client';

import React from 'react';
import { useGlobalContext } from '../contexts/GlobalContext';

const Header: React.FC = () => {
  const { user, logout, isAuthenticated } = useGlobalContext();

  return (
    <header className="bg-white shadow-md border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <h1 className="text-xl font-semibold text-gray-900">
              Ethereum Login App
            </h1>
          </div>
          
          <div className="flex items-center space-x-4">
            {isAuthenticated ? (
              <div className="flex items-center space-x-4">
                <div className="text-sm text-gray-700">
                  <span className="font-medium">Address:</span>
                  <span className="ml-2 font-mono text-xs bg-gray-100 px-2 py-1 rounded">
                    {user?.address}
                  </span>
                </div>
                <button
                  onClick={logout}
                  className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Logout
                </button>
              </div>
            ) : (
              <div className="text-sm text-gray-500">
                Not authenticated
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
