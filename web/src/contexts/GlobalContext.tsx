'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface User {
  address: string;
}

interface GlobalContextType {
  user: User | null;
  login: (address: string) => void;
  logout: () => void;
  isAuthenticated: boolean;
}

const GlobalContext = createContext<GlobalContextType | undefined>(undefined);

export const useGlobalContext = () => {
  const context = useContext(GlobalContext);
  if (context === undefined) {
    throw new Error('useGlobalContext must be used within a GlobalContextProvider');
  }
  return context;
};

interface GlobalContextProviderProps {
  children: ReactNode;
}

export const GlobalContextProvider: React.FC<GlobalContextProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    // Check localStorage for existing JWT on component mount
    const token = localStorage.getItem('jwt');
    const userAddress = localStorage.getItem('userAddress');
    
    if (token && userAddress) {
      setUser({ address: userAddress });
    }
  }, []);

  const login = (address: string) => {
    setUser({ address });
    localStorage.setItem('userAddress', address);
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('jwt');
    localStorage.removeItem('userAddress');
    // Clear cookie by setting it to expire
    document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
  };

  const isAuthenticated = user !== null;

  const value: GlobalContextType = {
    user,
    login,
    logout,
    isAuthenticated,
  };

  return (
    <GlobalContext.Provider value={value}>
      {children}
    </GlobalContext.Provider>
  );
};
