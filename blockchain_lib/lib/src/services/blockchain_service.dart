import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart' as web3;
import 'package:bs58/bs58.dart';
import 'package:solana/solana.dart' as solana;
import 'package:solana/encoder.dart' as encoder;
import 'package:flutter/foundation.dart';

/// Servicio centralizado para todas las operaciones relacionadas con blockchain
/// Incluye funciones para BIP32, BIP39, BIP44, Web3Dart, Solana y BS58
class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  // ============================================================================
  // BIP39 - Mnemonic Functions
  // ============================================================================

  /// Genera una nueva frase mnemotécnica usando BIP39
  /// @return String - Frase mnemotécnica generada
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  /// Valida si una frase mnemotécnica es válida según BIP39
  /// @param mnemonic - La frase mnemotécnica a validar
  /// @return bool - true si es válida, false en caso contrario
  bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// Convierte una frase mnemotécnica a seed usando BIP39
  /// @param mnemonic - La frase mnemotécnica
  /// @return Uint8List - El seed generado
  Uint8List mnemonicToSeed(String mnemonic) {
    return bip39.mnemonicToSeed(mnemonic);
  }

  /// Convierte una frase mnemotécnica a seed con passphrase usando BIP39
  /// @param mnemonic - La frase mnemotécnica
  /// @param passphrase - La passphrase opcional
  /// @return Uint8List - El seed generado
  Uint8List mnemonicToSeedWithPassphrase(String mnemonic, String passphrase) {
    return bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
  }

  // ============================================================================
  // BIP32 - Hierarchical Deterministic Wallets
  // ============================================================================

  /// Crea un nodo raíz BIP32 desde un seed
  /// @param seed - El seed generado desde el mnemonic
  /// @return BIP32 - El nodo raíz BIP32
  bip32.BIP32 createBIP32Root(Uint8List seed) {
    return bip32.BIP32.fromSeed(seed);
  }

  /// Deriva un nodo hijo usando una ruta de derivación
  /// @param root - El nodo raíz BIP32
  /// @param path - La ruta de derivación (ej: "m/44'/60'/0'/0/0")
  /// @return BIP32 - El nodo hijo derivado
  bip32.BIP32 derivePath(bip32.BIP32 root, String path) {
    return root.derivePath(path);
  }

  /// Deriva un nodo hijo usando un índice
  /// @param parent - El nodo padre
  /// @param index - El índice de derivación
  /// @return BIP32 - El nodo hijo derivado
  bip32.BIP32 deriveChild(bip32.BIP32 parent, int index) {
    return parent.derive(index);
  }

  // ============================================================================
  // BIP44 - Multi-Account Hierarchy
  // ============================================================================

  /// Genera una ruta de derivación BIP44 para Ethereum
  /// @param accountIndex - Índice de la cuenta
  /// @param changeIndex - Índice de cambio (0 para recibir, 1 para cambio)
  /// @param addressIndex - Índice de la dirección
  /// @return String - Ruta de derivación completa
  String generateEthereumPath(
    int accountIndex, {
    int changeIndex = 0,
    int addressIndex = 0,
  }) {
    return "m/44'/60'/$accountIndex'/$changeIndex/$addressIndex";
  }

  /// Genera una ruta de derivación BIP44 para Solana
  /// @param accountIndex - Índice de la cuenta
  /// @param changeIndex - Índice de cambio (0 para recibir, 1 para cambio)
  /// @param addressIndex - Índice de la dirección
  /// @return String - Ruta de derivación completa
  String generateSolanaPath(
    int accountIndex, {
    int changeIndex = 0,
    int addressIndex = 0,
  }) {
    return "m/44'/501'/$accountIndex'/$changeIndex/$addressIndex";
  }

  /// Valida el formato de una ruta de derivación BIP44
  /// @param path - La ruta de derivación a validar
  /// @return bool - true si es válida, false en caso contrario
  bool isValidDerivationPath(String path) {
    final pattern = RegExp(r"^m/44'/\d+'/\d+'/\d+/\d+$");
    return pattern.hasMatch(path);
  }

  /// Extrae el índice de derivación de una ruta BIP44
  /// @param path - La ruta de derivación
  /// @return int - El índice extraído
  int extractDerivationIndex(String path) {
    final pathParts = path.split('/');
    final indexPart = pathParts.last;
    return int.tryParse(indexPart) ?? 0;
  }

  // ============================================================================
  // Ethereum (Web3Dart) Functions
  // ============================================================================

  /// Crea una clave privada Ethereum desde bytes
  /// @param privateKeyBytes - Los bytes de la clave privada
  /// @return EthPrivateKey - La clave privada Ethereum
  web3.EthPrivateKey createEthereumPrivateKey(Uint8List privateKeyBytes) {
    return web3.EthPrivateKey(privateKeyBytes);
  }

  /// Crea una clave privada Ethereum desde string hexadecimal
  /// @param privateKeyHex - La clave privada en formato hexadecimal
  /// @return EthPrivateKey - La clave privada Ethereum
  web3.EthPrivateKey createEthereumPrivateKeyFromHex(String privateKeyHex) {
    return web3.EthPrivateKey.fromHex(privateKeyHex);
  }

  /// Obtiene la dirección Ethereum desde una clave privada
  /// @param privateKey - La clave privada Ethereum
  /// @return String - La dirección Ethereum en formato hexadecimal
  String getEthereumAddress(web3.EthPrivateKey privateKey) {
    return privateKey.address.hex;
  }

  /// Convierte bytes de clave privada a formato hexadecimal
  /// @param privateKeyBytes - Los bytes de la clave privada
  /// @return String - La clave privada en formato hexadecimal con prefijo 0x
  String privateKeyBytesToHex(Uint8List privateKeyBytes) {
    return '0x${privateKeyBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
  }

  /// Valida si una dirección Ethereum es válida
  /// @param address - La dirección a validar
  /// @return bool - true si es válida, false en caso contrario
  bool isValidEthereumAddress(String address) {
    if (address.length != 42 || !address.startsWith('0x')) {
      return false;
    }
    final hexPattern = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return hexPattern.hasMatch(address);
  }

  /// Crea un cliente Web3 para Ethereum
  /// @param endpointUrl - La URL del endpoint
  /// @return Web3Client - El cliente Web3
  web3.Web3Client createEthereumClient(String endpointUrl) {
    final httpClient = http.Client();
    return web3.Web3Client(endpointUrl, httpClient);
  }

  /// Obtiene el balance de una dirección Ethereum
  /// @param address - La dirección Ethereum
  /// @param endpointUrl - La URL del endpoint
  /// @return String - El balance en ETH
  Future<String> getEthereumBalance(String address, String endpointUrl) async {
    try {
      final payload = {
        'jsonrpc': '2.0',
        'method': 'eth_getBalance',
        'params': [address, 'latest'],
        'id': 1,
      };

      final response = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['error'] != null) {
          throw Exception('Error RPC: ${data['error']['message']}');
        }

        final balanceHex = data['result'] as String;
        if (balanceHex == '0x') {
          return '0';
        }

        final balanceWei = BigInt.parse(balanceHex.substring(2), radix: 16);
        final balanceEther = balanceWei / BigInt.from(10).pow(18);
        final remainder = balanceWei % BigInt.from(10).pow(18);

        return '$balanceEther.${remainder.toString().padLeft(18, '0').substring(0, 6)}';
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo balance: $e');
    }
  }

  // ============================================================================
  // Solana Functions
  // ============================================================================

  /// Detecta si una ruta de derivación es para Solana
  /// @param path - La ruta de derivación
  /// @return bool - true si es una ruta de Solana, false en caso contrario
  bool isSolanaPath(String path) {
    return path.contains('501');
  }

  /// Genera una dirección de Solana desde bytes de clave privada
  /// @param privateKeyBytes - Los bytes de la clave privada
  /// @return String - La dirección de Solana en formato base58
  String generateSolanaAddress(Uint8List privateKeyBytes) {
    // Nota: Esta es una implementación simplificada
    // En una implementación real, necesitarías usar la biblioteca de Solana correctamente
    return base58.encode(privateKeyBytes);
  }

  // ============================================================================
  // BS58 Functions
  // ============================================================================

  /// Codifica bytes a formato base58
  /// @param bytes - Los bytes a codificar
  /// @return String - La cadena codificada en base58
  String encodeBase58(Uint8List bytes) {
    return base58.encode(bytes);
  }

  /// Decodifica una cadena base58 a bytes
  /// @param encoded - La cadena codificada en base58
  /// @return Uint8List - Los bytes decodificados
  Uint8List decodeBase58(String encoded) {
    return base58.decode(encoded);
  }

  // ============================================================================
  // Utility Functions
  // ============================================================================

  /// Valida si una cantidad es válida
  /// @param amount - La cantidad a validar
  /// @return bool - true si es válida, false en caso contrario
  bool isValidAmount(String amount) {
    try {
      final value = double.tryParse(amount);
      return value != null && value > 0;
    } catch (e) {
      return false;
    }
  }

  /// Genera una cuenta completa desde un mnemonic y ruta de derivación
  /// @param mnemonic - La frase mnemotécnica
  /// @param derivationPath - La ruta de derivación
  /// @return Map<String, dynamic> - Mapa con address, privateKey, derivationIndex y derivationPath
  Map<String, dynamic> generateAccountFromMnemonic(
    String mnemonic,
    String derivationPath,
  ) {
    try {
      final seed = bip39.mnemonicToSeed(mnemonic);
      final root = bip32.BIP32.fromSeed(seed);
      final child = root.derivePath(derivationPath);

      final privateKeyHex = privateKeyBytesToHex(child.privateKey!);
      String address;

      if (isSolanaPath(derivationPath)) {
        address = generateSolanaAddressFromBytes(child.privateKey!);
      } else {
        final ethPrivateKey = web3.EthPrivateKey(child.privateKey!);
        address = ethPrivateKey.address.hex;
      }

      return {
        'address': address,
        'privateKey': privateKeyHex,
        'derivationIndex': extractDerivationIndex(derivationPath),
        'derivationPath': derivationPath,
      };
    } catch (e) {
      throw Exception('Error generando cuenta: $e');
    }
  }

  /// Obtiene información de la cadena desde un endpoint
  /// @param endpointUrl - La URL del endpoint
  /// @return Map<String, dynamic> - Información de la cadena
  Future<Map<String, dynamic>> getChainInfo(String endpointUrl) async {
    try {
      final payload = {
        'jsonrpc': '2.0',
        'method': 'eth_chainId',
        'params': [],
        'id': 1,
      };

      final response = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception('Error RPC: ${data['error']['message']}');
        }

        final chainIdHex = data['result'] as String;
        final chainId = BigInt.parse(chainIdHex.substring(2), radix: 16);

        return {
          'chainId': chainId.toInt(),
          'chainIdHex': chainIdHex,
          'endpointUrl': endpointUrl,
        };
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo información de la cadena: $e');
    }
  }

  // ============================================================================
  // Enhanced Ethereum Functions
  // ============================================================================

  /// Transfiere ETH entre cuentas
  /// @param fromAccount - La cuenta origen (Map con address y privateKey)
  /// @param toAddress - La dirección destino
  /// @param amount - La cantidad a enviar en ETH
  /// @param endpointUrl - La URL del endpoint
  /// @return String - El hash de la transacción
  Future<String> transferEthereum(
    Map<String, dynamic> fromAccount,
    String toAddress,
    String amount,
    String endpointUrl,
  ) async {
    try {
      final httpClient = http.Client();
      final ethClient = web3.Web3Client(endpointUrl, httpClient);

      final web3.EthPrivateKey credentials = web3.EthPrivateKey.fromHex(
        fromAccount['privateKey'],
      );
      final web3.EthereumAddress senderAddress = credentials.address;
      final web3.EthereumAddress receiverAddress = web3.EthereumAddress.fromHex(
        toAddress,
      );

      // Convertir cantidad de ETH a Wei
      final amountInWei = BigInt.from(double.parse(amount) * 1e18);
      final web3.EtherAmount amountToSend = web3.EtherAmount.fromBigInt(
        web3.EtherUnit.wei,
        amountInWei,
      );

      final web3.EtherAmount gasPrice = await ethClient.getGasPrice();
      final BigInt chainId = await ethClient.getChainId();

      final transaction = web3.Transaction(
        to: receiverAddress,
        from: senderAddress,
        value: amountToSend,
        gasPrice: gasPrice,
        maxGas: 21000,
      );

      final Uint8List signedRawTransactionBytes = await ethClient
          .signTransaction(credentials, transaction, chainId: chainId.toInt());

      final String transactionHash = await ethClient.sendRawTransaction(
        signedRawTransactionBytes,
      );
      ethClient.dispose();

      return transactionHash;
    } catch (e) {
      throw Exception('Error en transferencia Ethereum: $e');
    }
  }

  /// Realiza airdrop de ETH a una cuenta (solo para redes de prueba)
  /// @param toAddress - La dirección destino
  /// @param amount - La cantidad a enviar en ETH
  /// @param endpointUrl - La URL del endpoint
  /// @return String - El hash de la transacción
  Future<String> airdropEthereum(
    String toAddress,
    String amount,
    String endpointUrl,
  ) async {
    try {
      final payload = {
        'jsonrpc': '2.0',
        'method': 'eth_sendTransaction',
        'params': [
          {
            'from': '0x0000000000000000000000000000000000000000',
            'to': toAddress,
            'value':
                '0x${BigInt.from(double.parse(amount) * 1e18).toRadixString(16)}',
          },
        ],
        'id': 1,
      };

      final response = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception('Error RPC: ${data['error']['message']}');
        }
        return data['result'] as String;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en airdrop Ethereum: $e');
    }
  }

  // ============================================================================
  // Enhanced Solana Functions
  // ============================================================================

  /// Genera una dirección de Solana desde bytes de clave privada (implementación simplificada)
  /// @param privateKeyBytes - Los bytes de la clave privada
  /// @return String - La dirección de Solana en formato base58
  String generateSolanaAddressFromBytes(Uint8List privateKeyBytes) {
    try {
      // Implementación simplificada usando base58
      // En una implementación real, necesitarías usar la librería de Solana correctamente
      return base58.encode(privateKeyBytes);
    } catch (e) {
      throw Exception('Error generando dirección Solana: $e');
    }
  }

  /// Obtiene el balance de una cuenta Solana usando RPC directo
  /// @param address - La dirección de Solana
  /// @param endpointUrl - La URL del endpoint
  /// @return String - El balance en SOL
  Future<String> getSolanaBalance(String address, String endpointUrl) async {
    try {
      final payload = {
        'jsonrpc': '2.0',
        'method': 'getBalance',
        'params': [
          address,
          {'commitment': 'confirmed'},
        ],
        'id': 1,
      };

      final response = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception('Error RPC: ${data['error']['message']}');
        }

        final balanceLamports = data['result']['value'] as int;
        // Convertir lamports a SOL (1 SOL = 1,000,000,000 lamports)
        final balanceInSol = balanceLamports / 1e9;
        return balanceInSol.toString();
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo balance Solana: $e');
    }
  }

  /// Transfiere SOL entre cuentas usando RPC directo
  /// @param fromAccount - La cuenta origen (Map con address y privateKey)
  /// @param toAddress - La dirección destino
  /// @param amount - La cantidad a enviar en SOL
  /// @param endpointUrl - La URL del endpoint
  /// @return String - El signature de la transacción
  Future<String> transferSolana(
    Map<String, dynamic> fromAccount,
    String toAddress,
    String amount,
    String endpointUrl,
  ) async {
    final rpcClient = solana.RpcClient(endpointUrl);
    debugPrint('fromAccount: $fromAccount');
    debugPrint('toAddress: $toAddress');
    debugPrint('amount: $amount');
    debugPrint('endpointUrl: $endpointUrl');

    final wallet = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: fromAccount['privateKey'],
    );

    // Convertir dirección de destino a Ed25519HDPublicKey
    final fromPubkey = solana.Ed25519HDPublicKey.fromBase58(
      fromAccount['address'],
    );
    final toPubkey = solana.Ed25519HDPublicKey.fromBase58(toAddress);
    debugPrint('fromPubkey: $fromPubkey');
    debugPrint('toPubkey: $toPubkey');
    final instruction = solana.SystemInstruction.transfer(
      fundingAccount: fromPubkey,
      recipientAccount: toPubkey,
      lamports: int.parse(amount) * 1000000000,
    );
    debugPrint('instruction: ${instruction}');
    final blockhash = await rpcClient.getLatestBlockhash();
    debugPrint('blockhash: $blockhash');
    final message = solana.Message(instructions: [instruction]);
    debugPrint('message: $message');
    final signature = await rpcClient.signAndSendTransaction(
      message,
      [wallet], // El Keypair del remitente es el firmante
      commitment: solana.Commitment.confirmed, // Nivel de confirmación deseado
    );

    return signature;
  }

  /// Realiza airdrop de SOL a una cuenta usando RPC directo
  /// @param toAddress - La dirección destino
  /// @param amount - La cantidad a enviar en SOL
  /// @param endpointUrl - La URL del endpoint
  /// @return String - El signature de la transacción
  Future<String> airdropSolana(
    String toAddress,
    String amount,
    String endpointUrl,
  ) async {
    try {
      // Convertir cantidad de SOL a lamports
      final amountInLamports = (double.parse(amount) * 1e9).toInt();

      final payload = {
        'jsonrpc': '2.0',
        'method': 'requestAirdrop',
        'params': [
          toAddress,
          amountInLamports,
          {'commitment': 'confirmed'},
        ],
        'id': 1,
      };

      final response = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception('Error RPC: ${data['error']['message']}');
        }
        return data['result'] as String;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en airdrop Solana: $e');
    }
  }
}
