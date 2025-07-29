import 'package:flutter_test/flutter_test.dart';
import 'package:blockchain_lib/blockchain_lib.dart';
import 'dart:typed_data';

void main() {
  group('BlockchainService Tests', () {
    late BlockchainService blockchainService;

    setUp(() {
      blockchainService = BlockchainService();
    });

    group('BIP39 - Mnemonic Tests', () {
      test('should generate valid mnemonic', () {
        final mnemonic = blockchainService.generateMnemonic();
        expect(mnemonic, isNotEmpty);
        expect(blockchainService.validateMnemonic(mnemonic), isTrue);
      });

      test('should validate correct mnemonic', () {
        const validMnemonic =
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        expect(blockchainService.validateMnemonic(validMnemonic), isTrue);
      });

      test('should reject invalid mnemonic', () {
        const invalidMnemonic = 'invalid mnemonic phrase';
        expect(blockchainService.validateMnemonic(invalidMnemonic), isFalse);
      });

      test('should convert mnemonic to seed', () {
        const mnemonic =
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        final seed = blockchainService.mnemonicToSeed(mnemonic);
        expect(seed, isA<Uint8List>());
        expect(seed.length, 64);
      });
    });

    group('BIP44 - Path Generation Tests', () {
      test('should generate valid Ethereum path', () {
        final path = blockchainService.generateEthereumPath(0);
        expect(path, equals("m/44'/60'/0'/0/0"));
      });

      test('should generate valid Solana path', () {
        final path = blockchainService.generateSolanaPath(0);
        expect(path, equals("m/44'/501'/0'/0/0"));
      });

      test('should validate correct derivation path', () {
        const validPath = "m/44'/60'/0'/0/0";
        expect(blockchainService.isValidDerivationPath(validPath), isTrue);
      });

      test('should reject invalid derivation path', () {
        const invalidPath = "invalid/path";
        expect(blockchainService.isValidDerivationPath(invalidPath), isFalse);
      });

      test('should extract derivation index', () {
        const path = "m/44'/60'/0'/0/5";
        final index = blockchainService.extractDerivationIndex(path);
        expect(index, equals(5));
      });
    });

    group('Ethereum Address Validation Tests', () {
      test('should validate correct Ethereum address', () {
        const validAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
        expect(blockchainService.isValidEthereumAddress(validAddress), isTrue);
      });

      test('should reject invalid Ethereum address', () {
        const invalidAddress = 'invalid-address';
        expect(
          blockchainService.isValidEthereumAddress(invalidAddress),
          isFalse,
        );
      });

      test('should reject address without 0x prefix', () {
        const invalidAddress = '742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
        expect(
          blockchainService.isValidEthereumAddress(invalidAddress),
          isFalse,
        );
      });

      test('should reject address with wrong length', () {
        const invalidAddress = '0x123';
        expect(
          blockchainService.isValidEthereumAddress(invalidAddress),
          isFalse,
        );
      });
    });

    group('Solana Path Detection Tests', () {
      test('should detect Solana path', () {
        const solanaPath = "m/44'/501'/0'/0/0";
        expect(blockchainService.isSolanaPath(solanaPath), isTrue);
      });

      test('should not detect Ethereum path as Solana', () {
        const ethereumPath = "m/44'/60'/0'/0/0";
        expect(blockchainService.isSolanaPath(ethereumPath), isFalse);
      });
    });

    group('Utility Functions Tests', () {
      test('should validate correct amount', () {
        expect(blockchainService.isValidAmount('1.5'), isTrue);
        expect(blockchainService.isValidAmount('0.1'), isTrue);
        expect(blockchainService.isValidAmount('100'), isTrue);
      });

      test('should reject invalid amount', () {
        expect(blockchainService.isValidAmount(''), isFalse);
        expect(blockchainService.isValidAmount('invalid'), isFalse);
        expect(blockchainService.isValidAmount('-1'), isFalse);
        expect(blockchainService.isValidAmount('0'), isFalse);
      });
    });

    group('Account Generation Tests', () {
      test('should generate Ethereum account from mnemonic', () {
        const mnemonic =
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        final ethPath = blockchainService.generateEthereumPath(0);

        final account = blockchainService.generateAccountFromMnemonic(
          mnemonic,
          ethPath,
        );

        expect(account, isA<Map<String, dynamic>>());
        expect(account['address'], isNotEmpty);
        expect(account['privateKey'], isNotEmpty);
        expect(account['derivationPath'], equals(ethPath));
        expect(account['derivationIndex'], equals(0));
        expect(account['address'].startsWith('0x'), isTrue);
      });

      test('should generate Solana account from mnemonic', () {
        const mnemonic =
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        final solPath = blockchainService.generateSolanaPath(0);

        final account = blockchainService.generateAccountFromMnemonic(
          mnemonic,
          solPath,
        );

        expect(account, isA<Map<String, dynamic>>());
        expect(account['address'], isNotEmpty);
        expect(account['privateKey'], isNotEmpty);
        expect(account['derivationPath'], equals(solPath));
        expect(account['derivationIndex'], equals(0));
      });
    });

    group('BS58 Tests', () {
      test('should encode and decode base58', () {
        final originalBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final encoded = blockchainService.encodeBase58(originalBytes);
        final decoded = blockchainService.decodeBase58(encoded);

        expect(decoded, equals(originalBytes));
      });
    });
  });
}
