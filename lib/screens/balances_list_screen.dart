import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/balance_provider.dart';
import '../providers/endpoint_provider.dart';
import '../providers/mnemonic_provider.dart';
import '../providers/account_provider.dart';
import '../models/balance.dart';

class BalancesListScreen extends StatefulWidget {
  const BalancesListScreen({super.key});

  @override
  State<BalancesListScreen> createState() => _BalancesListScreenState();
}

class _BalancesListScreenState extends State<BalancesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final balanceProvider = context.read<BalanceProvider>();
    final endpointProvider = context.read<EndpointProvider>();
    final mnemonicProvider = context.read<MnemonicProvider>();
    final accountProvider = context.read<AccountProvider>();

    await Future.wait([
      balanceProvider.loadBalances(),
      endpointProvider.loadEndpoints(),
      mnemonicProvider.loadMnemonics(),
      accountProvider.loadAccounts(),
    ]);
  }

  String _getMnemonicName(int mnemonicId) {
    final mnemonicProvider = context.read<MnemonicProvider>();
    final mnemonic = mnemonicProvider.mnemonics.firstWhere(
      (m) => m.id == mnemonicId,
      orElse: () => throw Exception('Mnemonic no encontrado'),
    );
    return mnemonic.name;
  }

  String _getAccountName(int accountId) {
    final accountProvider = context.read<AccountProvider>();
    final account = accountProvider.accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => throw Exception('Cuenta no encontrada'),
    );
    return account.name;
  }

  String _getEndpointName(int endpointId) {
    final endpointProvider = context.read<EndpointProvider>();
    final endpoint = endpointProvider.endpoints.firstWhere(
      (e) => e.id == endpointId,
      orElse: () => throw Exception('Endpoint no encontrado'),
    );
    return endpoint.name;
  }

  String _maskAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<BalanceProvider>().updateAllBalancesFromEndpoints();
            },
            tooltip: 'Actualizar desde endpoints',
          ),
        ],
      ),
      body: Consumer<BalanceProvider>(
        builder: (context, balanceProvider, child) {
          if (balanceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (balanceProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${balanceProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      balanceProvider.clearError();
                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (balanceProvider.balances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay balances registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<BalanceProvider>()
                          .updateAllBalancesFromEndpoints();
                    },
                    child: const Text('Actualizar Balances'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              itemCount: balanceProvider.balances.length,
              itemBuilder: (context, index) {
                final balance = balanceProvider.balances[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        balance.symbol.isNotEmpty
                            ? balance.symbol[0].toUpperCase()
                            : 'B',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${balance.balance} ${balance.symbol}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Mnemonic: ${_getMnemonicName(balance.mnemonicId)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Cuenta: ${_getAccountName(balance.accountId)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Endpoint: ${_getEndpointName(balance.endpointId)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Actualizado: ${_formatDate(balance.lastUpdated)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            _showBalanceDetails(balance);
                            break;
                          case 'edit':
                            // TODO: Navegar a pantalla de edición
                            break;
                          case 'delete':
                            _showDeleteConfirmation(balance);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('Ver detalles'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<BalanceProvider>().updateAllBalancesFromEndpoints();
        },
        child: const Icon(Icons.sync),
        tooltip: 'Actualizar balances desde endpoints',
      ),
    );
  }

  void _showBalanceDetails(Balance balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Balance: ${balance.balance} ${balance.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${balance.id}'),
            Text('Mnemonic ID: ${balance.mnemonicId}'),
            Text('Cuenta ID: ${balance.accountId}'),
            Text('Endpoint ID: ${balance.endpointId}'),
            Text('Balance: ${balance.balance}'),
            Text('Símbolo: ${balance.symbol}'),
            Text('Última actualización: ${_formatDate(balance.lastUpdated)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Balance balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el balance de ${balance.balance} ${balance.symbol}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BalanceProvider>().deleteBalance(balance.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Balance eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
