/// A comprehensive Flutter library for blockchain operations.
///
/// This library provides support for:
/// - BIP32: Hierarchical Deterministic Wallets
/// - BIP39: Mnemonic code for generating deterministic keys
/// - BIP44: Multi-Account Hierarchy for Deterministic Wallets
/// - Web3Dart: Ethereum blockchain interactions
/// - Solana: Solana blockchain support
/// - BS58: Base58 encoding/decoding
///
/// ## Usage
///
/// ```dart
/// import 'package:blockchain_lib/blockchain_lib.dart';
///
/// void main() {
///   final blockchainService = BlockchainService();
///
///   // Generate a new mnemonic
///   final mnemonic = blockchainService.generateMnemonic();
///
///   // Generate Ethereum account
///   final ethPath = blockchainService.generateEthereumPath(0);
///   final account = blockchainService.generateAccountFromMnemonic(mnemonic, ethPath);
///
///   print('Address: ${account.address}');
///   print('Private Key: ${account.privateKey}');
/// }
/// ```
library blockchain_lib;

export 'src/src.dart';
