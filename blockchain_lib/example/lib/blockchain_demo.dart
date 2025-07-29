import 'package:flutter/material.dart';
import 'package:blockchain_lib/blockchain_lib.dart';

/// Demostración completa de las funcionalidades de blockchain
class BlockchainDemo extends StatefulWidget {
  const BlockchainDemo({super.key});

  @override
  State<BlockchainDemo> createState() => _BlockchainDemoState();
}

class _BlockchainDemoState extends State<BlockchainDemo> {
  final BlockchainService _blockchainService = BlockchainService();

  // Mnemonic de prueba proporcionado
  static const String testMnemonic =
      'test test test test test test test test test test test junk';

  // Endpoints de prueba
  static const String ethereumEndpoint = 'http://localhost:8545';
  static const String solanaEndpoint = 'http://localhost:8899';

  Map<String, dynamic>? _ethereumAccount1;
  Map<String, dynamic>? _ethereumAccount2;
  Map<String, dynamic>? _solanaAccount1;
  Map<String, dynamic>? _solanaAccount2;

  String _ethereumBalance1 = '';
  String _ethereumBalance2 = '';
  String _solanaBalance1 = '';
  String _solanaBalance2 = '';

  String _ethereumTransferResult = '';
  String _solanaTransferResult = '';
  String _ethereumAirdropResult = '';
  String _solanaAirdropResult = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateAccounts();
  }

  void _generateAccounts() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generar cuentas Ethereum
      final ethPath1 = _blockchainService.generateEthereumPath(
        0,
        addressIndex: 0,
      );
      final ethPath2 = _blockchainService.generateEthereumPath(
        0,
        addressIndex: 1,
      );

      _ethereumAccount1 = _blockchainService.generateAccountFromMnemonic(
        testMnemonic,
        ethPath1,
      );
      _ethereumAccount2 = _blockchainService.generateAccountFromMnemonic(
        testMnemonic,
        ethPath2,
      );

      // Generar cuentas Solana
      final solPath1 = _blockchainService.generateSolanaPath(0);
      final solPath2 = _blockchainService.generateSolanaPath(1);

      _solanaAccount1 = _blockchainService.generateAccountFromMnemonic(
        testMnemonic,
        solPath1,
      );
      _solanaAccount2 = _blockchainService.generateAccountFromMnemonic(
        testMnemonic,
        solPath2,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error generando cuentas: $e');
    }
  }

  Future<void> _getEthereumBalances() async {
    if (_ethereumAccount1 == null || _ethereumAccount2 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final balance1 = await _blockchainService.getEthereumBalance(
        _ethereumAccount1!['address'],
        ethereumEndpoint,
      );
      final balance2 = await _blockchainService.getEthereumBalance(
        _ethereumAccount2!['address'],
        ethereumEndpoint,
      );

      setState(() {
        _ethereumBalance1 = balance1;
        _ethereumBalance2 = balance2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error obteniendo balances Ethereum: $e');
    }
  }

  Future<void> _getSolanaBalances() async {
    if (_solanaAccount1 == null || _solanaAccount2 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final balance1 = await _blockchainService.getSolanaBalance(
        _solanaAccount1!['address'],
        solanaEndpoint,
      );
      final balance2 = await _blockchainService.getSolanaBalance(
        _solanaAccount2!['address'],
        solanaEndpoint,
      );

      setState(() {
        _solanaBalance1 = balance1;
        _solanaBalance2 = balance2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error obteniendo balances Solana: $e');
    }
  }

  Future<void> _transferEthereum() async {
    if (_ethereumAccount1 == null || _ethereumAccount2 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _blockchainService.transferEthereum(
        _ethereumAccount1!,
        _ethereumAccount2!['address'],
        '0.001', // 0.001 ETH
        ethereumEndpoint,
      );

      setState(() {
        _ethereumTransferResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error en transferencia Ethereum: $e');
    }
  }

  Future<void> _transferSolana() async {
    if (_solanaAccount1 == null || _solanaAccount2 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _blockchainService.transferSolana(
        _solanaAccount1!,
        _solanaAccount2!['address'],
        '0.1', // 0.1 SOL
        solanaEndpoint,
      );

      setState(() {
        _solanaTransferResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error en transferencia Solana: $e');
    }
  }

  Future<void> _airdropEthereum() async {
    if (_ethereumAccount1 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _blockchainService.airdropEthereum(
        _ethereumAccount1!['address'],
        '1.0', // 1 ETH
        ethereumEndpoint,
      );

      setState(() {
        _ethereumAirdropResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error en airdrop Ethereum: $e');
    }
  }

  Future<void> _airdropSolana() async {
    if (_solanaAccount1 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _blockchainService.airdropSolana(
        _solanaAccount1!['address'],
        '1.0', // 1 SOL
        solanaEndpoint,
      );

      setState(() {
        _solanaAirdropResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error en airdrop Solana: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del mnemonic
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mnemonic de Prueba',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testMnemonic,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateAccounts,
                      child: const Text('Regenerar Cuentas'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Cuentas Ethereum
              if (_ethereumAccount1 != null && _ethereumAccount2 != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cuentas Ethereum',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cuenta 1
                        Text('Cuenta 1: ${_ethereumAccount1!['address']}'),
                        Text('Balance: $_ethereumBalance1 ETH'),
                        const SizedBox(height: 8),

                        // Cuenta 2
                        Text('Cuenta 2: ${_ethereumAccount2!['address']}'),
                        Text('Balance: $_ethereumBalance2 ETH'),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _getEthereumBalances,
                              child: const Text('Obtener Balances'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _transferEthereum,
                              child: const Text('Transferir 0.001 ETH'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _airdropEthereum,
                              child: const Text('Airdrop 1 ETH'),
                            ),
                          ],
                        ),

                        if (_ethereumTransferResult.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Transferencia: $_ethereumTransferResult'),
                        ],

                        if (_ethereumAirdropResult.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Airdrop: $_ethereumAirdropResult'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Cuentas Solana
              if (_solanaAccount1 != null && _solanaAccount2 != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cuentas Solana',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cuenta 1
                        Text('Cuenta 1: ${_solanaAccount1!['address']}'),
                        Text('Balance: $_solanaBalance1 SOL'),
                        const SizedBox(height: 8),

                        // Cuenta 2
                        Text('Cuenta 2: ${_solanaAccount2!['address']}'),
                        Text('Balance: $_solanaBalance2 SOL'),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _getSolanaBalances,
                              child: const Text('Obtener Balances'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _transferSolana,
                              child: const Text('Transferir 0.1 SOL'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _airdropSolana,
                              child: const Text('Airdrop 1 SOL'),
                            ),
                          ],
                        ),

                        if (_solanaTransferResult.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Transferencia: $_solanaTransferResult'),
                        ],

                        if (_solanaAirdropResult.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Airdrop: $_solanaAirdropResult'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
