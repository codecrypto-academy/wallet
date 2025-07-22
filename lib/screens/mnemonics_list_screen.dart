import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mnemonic_provider.dart';
import '../models/mnemonic.dart';
import 'add_mnemonic_screen.dart';
import 'accounts_list_screen.dart';
import 'add_account_screen.dart';

class MnemonicsListScreen extends StatefulWidget {
  const MnemonicsListScreen({super.key});

  @override
  State<MnemonicsListScreen> createState() => _MnemonicsListScreenState();
}

class _MnemonicsListScreenState extends State<MnemonicsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar mnemonics al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMnemonics();
    });
  }

  Future<void> _loadMnemonics() async {
    try {
      await context.read<MnemonicProvider>().loadMnemonics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mnemonics: $e'),
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
        title: const Text('Mnemonics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadMnemonics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Consumer<MnemonicProvider>(
        builder: (context, mnemonicProvider, child) {
          if (mnemonicProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando mnemonics...'),
                ],
              ),
            );
          }

          if (mnemonicProvider.mnemonics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay mnemonics',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agrega tu primer mnemonic',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToAddMnemonic(context),
                    child: const Text('Agregar Mnemonic'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMnemonics,
            child: ListView.builder(
              itemCount: mnemonicProvider.mnemonics.length,
              itemBuilder: (context, index) {
                final mnemonic = mnemonicProvider.mnemonics[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.security, color: Colors.green),
                    title: Text(
                      mnemonic.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Creado: ${_formatDate(mnemonic.createdAt)}'),
                        Text('Mnemonic: ${_maskMnemonic(mnemonic.mnemonic)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para ver cuentas
                        IconButton(
                          onPressed: () =>
                              _navigateToAccounts(context, mnemonic),
                          icon: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue,
                          ),
                          tooltip: 'Ver cuentas',
                        ),
                        // Botón para generar cuenta
                        IconButton(
                          onPressed: () =>
                              _navigateToGenerateAccount(context, mnemonic),
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          tooltip: 'Generar cuenta',
                        ),
                        // Menú de opciones
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleMenuAction(
                            value,
                            mnemonic,
                            mnemonicProvider,
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
        onPressed: () => _navigateToAddMnemonic(context),
        tooltip: 'Agregar Mnemonic',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddMnemonic(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMnemonicScreen()),
    );
    if (result == true && mounted) {
      await _loadMnemonics();
    }
  }

  Future<void> _navigateToAccounts(
    BuildContext context,
    Mnemonic mnemonic,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountsListScreen(
          mnemonicId: mnemonic.id,
          mnemonicName: mnemonic.name,
        ),
      ),
    );
  }

  Future<void> _navigateToGenerateAccount(
    BuildContext context,
    Mnemonic mnemonic,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(mnemonicId: mnemonic.id),
      ),
    );
    if (result == true && mounted) {
      // Opcional: mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta generada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleMenuAction(
    String action,
    Mnemonic mnemonic,
    MnemonicProvider provider,
  ) async {
    switch (action) {
      case 'view':
        _showMnemonicDetails(context, mnemonic);
        break;
      case 'delete':
        await _deleteMnemonic(mnemonic, provider);
        break;
    }
  }

  Future<void> _deleteMnemonic(
    Mnemonic mnemonic,
    MnemonicProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${mnemonic.name}"?\n\n⚠️ Esta acción eliminará también todas las cuentas asociadas.',
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
        await provider.deleteMnemonic(mnemonic.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mnemonic eliminado'),
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

  String _maskMnemonic(String mnemonic) {
    try {
      final words = mnemonic.split(' ');
      if (words.length <= 4) return '***';
      return '${words.take(2).join(' ')} ... ${words.skip(words.length - 2).join(' ')}';
    } catch (e) {
      return 'Error al mostrar mnemonic';
    }
  }

  void _showMnemonicDetails(BuildContext context, Mnemonic mnemonic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mnemonic.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Creado: ${_formatDate(mnemonic.createdAt)}'),
              const SizedBox(height: 16),
              const Text(
                'Mnemonic:',
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
                  mnemonic.mnemonic,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Password:',
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
                  mnemonic.password,
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
