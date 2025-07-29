import 'package:flutter/material.dart';
import 'package:bdd_lib/bdd_lib.dart';

void main() {
  runApp(const BDDLibraryApp());
}

class BDDLibraryApp extends StatelessWidget {
  const BDDLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDD Library Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const BDDLibraryHomePage(),
    );
  }
}

class BDDLibraryHomePage extends StatefulWidget {
  const BDDLibraryHomePage({super.key});

  @override
  State<BDDLibraryHomePage> createState() => _BDDLibraryHomePageState();
}

class _BDDLibraryHomePageState extends State<BDDLibraryHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Mnemonic> _mnemonics = [];
  List<Account> _accounts = [];
  List<Endpoint> _endpoints = [];
  List<Balance> _balances = [];
  List<Tx> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mnemonics = await _dbHelper.getAllMnemonics();
      final accounts = await _dbHelper.getAllAccounts();
      final endpoints = await _dbHelper.getAllEndpoints();
      final balances = await _dbHelper.getAllBalances();
      final transactions = await _dbHelper.getAllTransactions();

      setState(() {
        _mnemonics = mnemonics;
        _accounts = accounts;
        _endpoints = endpoints;
        _balances = balances;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addSampleData() async {
    try {
      // Crear un mnemonic de ejemplo
      final mnemonic = Mnemonic(
        name: 'Wallet Demo ${DateTime.now().millisecondsSinceEpoch}',
        mnemonic:
            'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
        passphrase: 'demo-passphrase',
        masterKey: 'demo-master-key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mnemonicId = await _dbHelper.insertMnemonic(mnemonic);

      // Crear un endpoint de ejemplo
      final endpoint = Endpoint(
        name: 'Ethereum Demo',
        url: 'https://mainnet.infura.io/v3/demo',
        chainId: '1',
        createdAt: DateTime.now(),
      );

      final endpointId = await _dbHelper.insertEndpoint(endpoint);

      // Crear una cuenta de ejemplo
      final account = Account(
        mnemonicId: mnemonicId,
        name: 'Cuenta Demo',
        address:
            '0x${DateTime.now().millisecondsSinceEpoch.toString().padLeft(40, '0')}',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/60'/0'/0/0",
        createdAt: DateTime.now(),
      );

      final accountId = await _dbHelper.insertAccount(account);

      // Crear un balance de ejemplo
      final balance = Balance(
        accountId: accountId,
        endpointId: endpointId,
        balance: '1.5',
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertBalance(balance);

      // Crear una transacción de ejemplo
      final transaction = Tx(
        accountId: accountId,
        endpointId: endpointId,
        nonce: 0,
        fromAccount: account.address,
        toAccount: '0x1234567890123456789012345678901234567890',
        amount: 1000000000000000000,
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertTx(transaction);

      // Recargar datos
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Datos de ejemplo agregados')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BDD Library Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📊 Resumen de datos',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryItem(
                            'Mnemonics',
                            _mnemonics.length,
                            Icons.key,
                          ),
                          _buildSummaryItem(
                            'Endpoints',
                            _endpoints.length,
                            Icons.link,
                          ),
                          _buildSummaryItem(
                            'Accounts',
                            _accounts.length,
                            Icons.account_circle,
                          ),
                          _buildSummaryItem(
                            'Balances',
                            _balances.length,
                            Icons.account_balance_wallet,
                          ),
                          _buildSummaryItem(
                            'Transactions',
                            _transactions.length,
                            Icons.receipt,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_mnemonics.isNotEmpty) ...[
                    _buildDataSection(
                      'Mnemonics',
                      _mnemonics.map((m) => m.name).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_accounts.isNotEmpty) ...[
                    _buildDataSection(
                      'Accounts',
                      _accounts
                          .map(
                            (a) =>
                                '${a.name} (${a.address.substring(0, 10)}...)',
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_endpoints.isNotEmpty) ...[
                    _buildDataSection(
                      'Endpoints',
                      _endpoints.map((e) => '${e.name} - ${e.url}').toList(),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleData,
        tooltip: 'Agregar datos de ejemplo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$title: $count'),
        ],
      ),
    );
  }

  Widget _buildDataSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }
}
