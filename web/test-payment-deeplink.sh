#!/bin/bash

# Test script for payment deeplink
# This script generates and executes the payment deeplink command for iOS simulator

# Configuration
FROM_ADDRESS="0x742d35cc6634c0532925a3b8d3c8f4f6e3c1c6f7"
TO_ADDRESS="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
AMOUNT="10"
ENDPOINT="http://localhost:8545"

# Generate the deeplink URL
DEEPLINK="tx://?txType=transfer&from=${FROM_ADDRESS}&to=${TO_ADDRESS}&amount=${AMOUNT}&endpoint=${ENDPOINT}"

echo "🚀 Testing Payment Deeplink"
echo "================================="
echo "From: ${FROM_ADDRESS}"
echo "To: ${TO_ADDRESS}"
echo "Amount: ${AMOUNT} ETH"
echo "Endpoint: ${ENDPOINT}"
echo "================================="
echo ""
echo "Generated Deeplink:"
echo "${DEEPLINK}"
echo ""
echo "Executing iOS Simulator Command:"
echo ""

# Execute the command for iOS simulator
xcrun simctl openurl booted "${DEEPLINK}"

echo "✅ Command executed successfully!"
echo ""
echo "If the Flutter app is running in the iOS simulator, it should handle this deeplink."
echo "Check the Flutter app logs for deeplink processing information."
