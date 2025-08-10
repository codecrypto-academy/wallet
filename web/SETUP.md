# Ethereum Login App - Setup Instructions

## Prerequisites

1. **Node.js** (version 18 or higher)
2. **MongoDB** running locally or accessible via connection string
3. **npm** or **yarn** package manager

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create environment variables file `.env.local`:
```bash
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017

# JWT Secret (change this in production!)
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# Server Configuration
NODE_ENV=development
```

## Running the Application

1. Start the development server:
```bash
npm run dev
```

2. Open your browser and navigate to `http://localhost:3000`

## How to Test

### 1. Generate Login QR Code
- Click "Generate Login QR Code" button
- A QR code will appear with a deep link

### 2. Test with the Test Program
- Copy the deep link from the QR code
- Update the `exampleDeepLink` variable in `test-login.ts`
- Run the test program:
```bash
npx ts-node test-login.ts
```

### 3. Manual Testing
- Scan the QR code with an Ethereum wallet
- Sign the message in your wallet
- The app should automatically authenticate you

## Architecture Overview

### Frontend Components
- **GlobalContext**: Manages authentication state
- **Header**: Shows login/logout buttons and user address
- **LoginForm**: Generates QR codes and handles authentication flow
- **Dashboard**: Displays user information after authentication

### Backend APIs
- **POST /api/auth/generate-login**: Creates new login request with QR code
- **GET /api/auth/check-status/[id]**: Checks authentication status
- **POST /api/auth/verify-signature**: Verifies client signature and completes login

### Security Features
- ECDSA signature verification
- 10-minute expiration for login requests
- 3-minute JWT token expiration
- Secure storage in cookies and localStorage

## Database Schema

The application uses MongoDB with the following collection:

**login-requests**
```json
{
  "_id": "ObjectId",
  "id": "string (unique identifier)",
  "domain": "string",
  "random": "string (32 bytes hex)",
  "timestamp": "number (Unix timestamp)",
  "serverAddress": "string (Ethereum address)",
  "signature": "string (ECDSA signature)",
  "status": "string ('pending' | 'completed')",
  "userAddress": "string (client Ethereum address)",
  "jwt": "string (JWT token)",
  "createdAt": "Date",
  "expiresAt": "Date",
  "completedAt": "Date"
}
```

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check connection string in `.env.local`

2. **QR Code Not Generating**
   - Check browser console for errors
   - Verify all dependencies are installed

3. **Authentication Failing**
   - Check server logs for signature verification errors
   - Ensure timestamps are within 10-minute window

### Development Tips

- Use browser developer tools to monitor network requests
- Check MongoDB collections for data consistency
- Monitor JWT token expiration in localStorage

## Production Considerations

1. **Security**
   - Change JWT_SECRET to a strong random string
   - Use HTTPS in production
   - Implement rate limiting

2. **Database**
   - Use MongoDB Atlas or production MongoDB instance
   - Implement proper indexing
   - Add database connection pooling

3. **Monitoring**
   - Add logging for authentication attempts
   - Monitor failed login attempts
   - Implement health checks
