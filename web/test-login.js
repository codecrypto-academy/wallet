"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LoginTester = void 0;
var ethers_1 = require("ethers");
var LoginTester = /** @class */ (function () {
    function LoginTester() {
        // Generate a new Ethereum wallet for testing
        this.wallet = ethers_1.ethers.Wallet.createRandom();
        console.log('Generated test wallet:');
        console.log('Private Key:', this.wallet.privateKey);
        console.log('Address:', this.wallet.address);
        console.log('---');
    }
    LoginTester.prototype.parseDeepLink = function (deepLink) {
        try {
            // Parse the deep link: login://dominio?aleatorio=...&timestamp=...&address=...&signature=...
            var url = new URL(deepLink.replace('login://', 'http://'));
            var params = new URLSearchParams(url.search);
            return {
                domain: url.hostname,
                random: params.get('aleatorio') || '',
                timestamp: parseInt(params.get('timestamp') || '0'),
                address: params.get('address') || '',
                signature: params.get('signature') || ''
            };
        }
        catch (error) {
            throw new Error("Invalid deep link format: ".concat(error));
        }
    };
    LoginTester.prototype.validateSignature = function (deepLink) {
        try {
            // Recreate the message that was signed
            var message = "".concat(deepLink.domain).concat(deepLink.random).concat(deepLink.timestamp).concat(deepLink.address);
            // Verify the signature
            var recoveredAddress = ethers_1.ethers.verifyMessage(message, deepLink.signature);
            // Check if the recovered address matches the server address
            var isValid = recoveredAddress.toLowerCase() === deepLink.address.toLowerCase();
            console.log('Signature validation:');
            console.log('Message:', message);
            console.log('Recovered address:', recoveredAddress);
            console.log('Server address:', deepLink.address);
            console.log('Signature valid:', isValid);
            console.log('---');
            return isValid;
        }
        catch (error) {
            console.error('Error validating signature:', error);
            return false;
        }
    };
    LoginTester.prototype.authenticateWithServer = function (deepLink) {
        return __awaiter(this, void 0, void 0, function () {
            var message, signature, response, result, error, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 7, , 8]);
                        message = "".concat(deepLink.domain).concat(deepLink.random).concat(deepLink.timestamp).concat(deepLink.address);
                        return [4 /*yield*/, this.wallet.signMessage(message)];
                    case 1:
                        signature = _a.sent();
                        console.log('Client authentication:');
                        console.log('Message to sign:', message);
                        console.log('Client signature:', signature);
                        console.log('---');
                        return [4 /*yield*/, fetch('/api/auth/verify-signature', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify({
                                    random: deepLink.random,
                                    address: this.wallet.address,
                                    signature: signature
                                })
                            })];
                    case 2:
                        response = _a.sent();
                        if (!response.ok) return [3 /*break*/, 4];
                        return [4 /*yield*/, response.json()];
                    case 3:
                        result = _a.sent();
                        console.log('Server response:', result);
                        console.log('Authentication successful!');
                        return [2 /*return*/, true];
                    case 4: return [4 /*yield*/, response.text()];
                    case 5:
                        error = _a.sent();
                        console.error('Authentication failed:', error);
                        return [2 /*return*/, false];
                    case 6: return [3 /*break*/, 8];
                    case 7:
                        error_1 = _a.sent();
                        console.error('Error during authentication:', error_1);
                        return [2 /*return*/, false];
                    case 8: return [2 /*return*/];
                }
            });
        });
    };
    LoginTester.prototype.testLoginFlow = function (deepLinkString) {
        return __awaiter(this, void 0, void 0, function () {
            var deepLink, isSignatureValid, currentTime, timeDiff, isExpired, authSuccess, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        console.log('=== Ethereum Login Test ===');
                        console.log('Deep link:', deepLinkString);
                        console.log('---');
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        deepLink = this.parseDeepLink(deepLinkString);
                        console.log('Parsed deep link:', deepLink);
                        console.log('---');
                        isSignatureValid = this.validateSignature(deepLink);
                        if (!isSignatureValid) {
                            console.error('❌ Signature validation failed');
                            return [2 /*return*/];
                        }
                        console.log('✅ Signature validation passed');
                        console.log('---');
                        currentTime = Math.floor(Date.now() / 1000);
                        timeDiff = currentTime - deepLink.timestamp;
                        isExpired = timeDiff > 600;
                        if (isExpired) {
                            console.error('❌ Deep link expired');
                            console.log("Timestamp: ".concat(deepLink.timestamp, " (").concat(new Date(deepLink.timestamp * 1000).toISOString(), ")"));
                            console.log("Current time: ".concat(currentTime, " (").concat(new Date().toISOString(), ")"));
                            console.log("Time difference: ".concat(timeDiff, " seconds"));
                            return [2 /*return*/];
                        }
                        console.log('✅ Deep link is still valid');
                        console.log("Time difference: ".concat(timeDiff, " seconds"));
                        console.log('---');
                        return [4 /*yield*/, this.authenticateWithServer(deepLink)];
                    case 2:
                        authSuccess = _a.sent();
                        if (authSuccess) {
                            console.log('✅ Authentication completed successfully!');
                            console.log("User address: ".concat(this.wallet.address));
                        }
                        else {
                            console.error('❌ Authentication failed');
                        }
                        return [3 /*break*/, 4];
                    case 3:
                        error_2 = _a.sent();
                        console.error('❌ Test failed:', error_2);
                        return [3 /*break*/, 4];
                    case 4:
                        console.log('=== Test Complete ===');
                        return [2 /*return*/];
                }
            });
        });
    };
    return LoginTester;
}());
exports.LoginTester = LoginTester;
// Example usage
function main() {
    return __awaiter(this, void 0, void 0, function () {
        var tester, exampleDeepLink;
        return __generator(this, function (_a) {
            tester = new LoginTester();
            exampleDeepLink = 'login://ethereum-login-app.com?aleatorio=0x57e7e2d69b0ad96fcc29584c40125091818f70af6da43f372b65c7b394c7cbe4&timestamp=1754814112&address=0x42fb8149Cd4b09F9Adfc4c312b9849b21c060f49&signature=0x544c3bc1b7b8abe37a31b26c8e4b93caeccdc44856484ce3cc89f50f395eb5cd697bf2987718c541f80829ff5829b19f1a1e748d962b7f34cb4574f353db4f0c1c';
            console.log('Note: This is a test program. To use with your actual app:');
            console.log('1. Start your Next.js app');
            console.log('2. Generate a login QR code');
            console.log('3. Copy the deep link and replace the exampleDeepLink variable');
            console.log('4. Run this program');
            console.log('---');
            return [2 /*return*/];
        });
    });
}
if (require.main === module) {
    main().catch(console.error);
}
