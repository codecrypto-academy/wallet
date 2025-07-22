import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';
import 'add_account_screen.dart';
import 'send_transaction_screen.dart';

class AccountsListScreen extends StatefulWidget {
  final int? mnemonicId;
  final String? mnemonicName;

  const AccountsListScreen({super.key, this.mnemonicId, this.mnemonicName});

  @override
  State<AccountsListScreen> createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends State<AccountsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar accounts al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    try {
      final accountProvider = context.read<AccountProvider>();
      if (widget.mnemonicId != null) {
        await accountProvider.loadAccountsByMnemonic(widget.mnemonicId!);
      } else {
        await accountProvider.loadAccounts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cuentas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mnemonicName != null
              ? 'Cuentas de ${widget.mnemonicName}'
              : 'Todas las Cuentas',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadAccounts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          if (accountProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando cuentas...'),
                ],
              ),
            );
          }

          if (accountProvider.accounts.isEmpty) {
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
                    'No hay cuentas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mnemonicId != null
                        ? 'Genera tu primera cuenta para este mnemonic'
                        : 'Genera tu primera cuenta',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToAddAccount(context),
                    child: const Text('Generar Cuenta'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAccounts,
            child: ListView.builder(
              itemCount: accountProvider.accounts.length,
              itemBuilder: (context, index) {
                final account = accountProvider.accounts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue,
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dirección: ${_maskAddress(account.address)}'),
                        Text('Índice: ${account.derivationIndex}'),
                        Text('Ruta: ${account.derivationPath}'),
                        Text('Creado: ${_formatDate(account.createdAt)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para enviar transacción
                        IconButton(
                          onPressed: () =>
                              _navigateToSendTransaction(context, account),
                          icon: const Icon(Icons.send, color: Colors.green),
                          tooltip: 'Enviar transacción',
                        ),
                        // Menú de opciones
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleMenuAction(
                            value,
                            account,
                            accountProvider,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Ver detalles'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
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
        onPressed: () => _navigateToAddAccount(context),
        tooltip: 'Generar Cuenta',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddAccount(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(mnemonicId: widget.mnemonicId),
      ),
    );
    if (result == true && mounted) {
      await _loadAccounts();
    }
  }

  Future<void> _navigateToSendTransaction(
    BuildContext context,
    Account account,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendTransactionScreen(account: account),
      ),
    );
    if (result == true && mounted) {
      // Opcional: mostrar mensaje de éxito o recargar datos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción enviada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleMenuAction(
    String action,
    Account account,
    AccountProvider provider,
  ) async {
    switch (action) {
      case 'view':
        _showAccountDetails(context, account);
        break;
      case 'delete':
        await _deleteAccount(account, provider);
        break;
    }
  }

  Future<void> _deleteAccount(Account account, AccountProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${account.name}"?\n\n⚠️ Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await provider.deleteAccount(account.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _maskAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _showAccountDetails(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Creado: ${_formatDate(account.createdAt)}'),
              Text('Índice de derivación: ${account.derivationIndex}'),
              Text('Ruta de derivación: ${account.derivationPath}'),
              const SizedBox(height: 16),
              const Text(
                'Dirección:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  account.address,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Clave Privada:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  account.privateKey,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
