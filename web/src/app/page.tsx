'use client';

import React from 'react';
import { useGlobalContext } from '../contexts/GlobalContext';
import Header from '../components/Header';
import LoginForm from '../components/LoginForm';
import Dashboard from '../components/Dashboard';

export default function Home() {
  const { isAuthenticated } = useGlobalContext();

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <main className="py-8">
        {isAuthenticated ? (
          <Dashboard />
        ) : (
          <LoginForm />
        )}
      </main>
    </div>
  );
}
