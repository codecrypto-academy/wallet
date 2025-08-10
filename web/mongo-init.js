// MongoDB initialization script
db = db.getSiblingDB('ethereum-login');

// Create collections
db.createCollection('login-requests');

// Create indexes for better performance
db.login-requests.createIndex({ "id": 1 }, { unique: true });
db.login-requests.createIndex({ "random": 1 });
db.login-requests.createIndex({ "status": 1 });
db.login-requests.createIndex({ "expiresAt": 1 });

// Create TTL index to automatically remove expired requests
db.login-requests.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 });

print('MongoDB initialized successfully for ethereum-login app');
