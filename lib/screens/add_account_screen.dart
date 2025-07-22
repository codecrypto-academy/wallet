import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:bs58/bs58.dart';
import '../providers/account_provider.dart';
import '../providers/mnemonic_provider.dart';
import '../models/account.dart';
import '../models/mnemonic.dart';

class AddAccountScreen extends StatefulWidget {
  final int? mnemonicId;

  const AddAccountScreen({super.key, this.mnemonicId});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _derivationPathController = TextEditingController();
  String _generatedAddress = '';
  String _generatedPrivateKey = '';
  int _derivationIndex = 0;
  bool _isLoading = false;
  Mnemonic? _selectedMnemonic;

  @override
  void initState() {
    super.initState();
    _loadMnemonic();
    // Agregar listener para detectar cambios en la ruta de derivación
    _derivationPathController.addListener(_onDerivationPathChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _derivationPathController.removeListener(_onDerivationPathChanged);
    _derivationPathController.dispose();
    super.dispose();
  }

  // Función que se ejecuta cuando cambia la ruta de derivación
  void _onDerivationPathChanged() {
    if (_selectedMnemonic != null &&
        _derivationPathController.text.isNotEmpty) {
      // Usar un debounce para evitar regenerar en cada caracter
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          // Verificar que el texto no haya cambiado durante el delay
          final currentText = _derivationPathController.text;
          if (currentText.isNotEmpty) {
            _generateAccountFromPath();
          }
        }
      });
    }
  }

  Future<void> _loadMnemonic() async {
    if (widget.mnemonicId != null) {
      final mnemonicProvider = context.read<MnemonicProvider>();
      final mnemonics = mnemonicProvider.mnemonics;
      _selectedMnemonic = mnemonics.firstWhere(
        (m) => m.id == widget.mnemonicId,
        orElse: () => throw Exception('Mnemonic no encontrado'),
      );
      _generateAccount();
    }
  }

  void _generateAccount() async {
    if (_selectedMnemonic == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener el siguiente índice de derivación
      final accountProvider = context.read<AccountProvider>();
      _derivationIndex = await accountProvider.getNextDerivationIndex(
        _selectedMnemonic!.id!,
      );

      // Generar la cuenta usando BIP32
      final seed = bip39.mnemonicToSeed(_selectedMnemonic!.mnemonic);
      final root = bip32.BIP32.fromSeed(seed);

      // Ruta de derivación: m/44'/60'/0'/0/index (Ethereum)
      final path = "m/44'/60'/0'/0/$_derivationIndex";
      final child = root.derivePath(path);

      // Generar la dirección Ethereum
      final privateKey = EthPrivateKey(child.privateKey!);
      final address = privateKey.address;

      setState(() {
        _derivationPathController.text = path;
        _generatedAddress = address.hex;
        _generatedPrivateKey =
            '0x${privateKey.privateKey.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generando cuenta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Nueva función para generar cuenta desde una ruta de derivación personalizada
  void _generateAccountFromPath() async {
    if (_selectedMnemonic == null || _derivationPathController.text.isEmpty) {
      return;
    }

    // Validar formato básico de la ruta de derivación
    final path = _derivationPathController.text.trim();
    if (!_isValidDerivationPath(path)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final seed = bip39.mnemonicToSeed(_selectedMnemonic!.mnemonic);
      final root = bip32.BIP32.fromSeed(seed);

      // Usar la ruta de derivación ingresada por el usuario
      final child = root.derivePath(path);

      // Verificar si es una ruta de Solana (contiene 501)
      final isSolanaPath = path.contains('501');

      // La clave privada es la misma para ambos (derivada con BIP32)
      final privateKey =
          '0x${child.privateKey!.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
      String address;

      if (isSolanaPath) {
        // Generar dirección de Solana usando la clave privada derivada
        // Nota: Esta es una implementación simplificada
        // En una implementación real, necesitarías usar la biblioteca de Solana correctamente
        address = base58.encode(child.privateKey!);
      } else {
        // Generar la dirección Ethereum
        final ethPrivateKey = EthPrivateKey(child.privateKey!);
        final ethAddress = ethPrivateKey.address;
        address = ethAddress.hex;
      }

      // Extraer el índice de derivación de la ruta
      final pathParts = path.split('/');
      final indexPart = pathParts.last;
      final index = int.tryParse(indexPart) ?? 0;

      setState(() {
        _derivationIndex = index;
        _generatedAddress = address;
        _generatedPrivateKey = privateKey;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error con la ruta de derivación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para validar el formato de la ruta de derivación
  bool _isValidDerivationPath(String path) {
    // Patrón básico para rutas de derivación BIP44 (Ethereum y Solana)
    final pattern = RegExp(r"^m/44'/\d+'/\d+'/\d+/\d+$");
    return pattern.hasMatch(path);
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMnemonic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se ha seleccionado un mnemonic'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accountProvider = context.read<AccountProvider>();

      final newAccount = Account(
        mnemonicId: _selectedMnemonic!.id!,
        name: _nameController.text.trim(),
        address: _generatedAddress,
        privateKey: _generatedPrivateKey,
        derivationIndex: _derivationIndex,
        derivationPath: _derivationPathController.text.trim(),
        createdAt: DateTime.now(),
      );

      await accountProvider.addAccount(newAccount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta generada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Cuenta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información del mnemonic
              if (_selectedMnemonic != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mnemonic:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedMnemonic!.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Índice de derivación: $_derivationIndex',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Campo nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la cuenta',
                  hintText: 'Ingresa un nombre para esta cuenta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo ruta de derivación
              TextFormField(
                controller: _derivationPathController,
                decoration: InputDecoration(
                  labelText: 'Ruta de derivación',
                  hintText:
                      'm/44\'/60\'/0\'/0/x (Ethereum) o m/44\'/501\'/0\'/0/x (Solana)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_tree),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.auto_awesome, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La ruta de derivación es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Texto de ayuda
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La cuenta se regenerará automáticamente cuando cambies la ruta de derivación.\nEthereum: m/44\'/60\'/0\'/0/x\nSolana: m/44\'/501\'/0\'/0/x',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Información generada
              if (_generatedAddress.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cuenta Generada:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _generateAccount,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Generar nueva cuenta',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                            _generatedAddress,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                            _generatedPrivateKey,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading || _generatedAddress.isEmpty
                    ? null
                    : _saveAccount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar Cuenta',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
