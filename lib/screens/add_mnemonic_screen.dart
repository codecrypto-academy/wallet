import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../providers/mnemonic_provider.dart';
import '../models/mnemonic.dart';

class AddMnemonicScreen extends StatefulWidget {
  const AddMnemonicScreen({super.key});

  @override
  State<AddMnemonicScreen> createState() => _AddMnemonicScreenState();
}

class _AddMnemonicScreenState extends State<AddMnemonicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mnemonicController = TextEditingController();
  String _generatedMnemonic = '';
  bool _isLoading = false;
  bool _showPassword = false;
  bool _isCustomMnemonic = false;

  @override
  void initState() {
    super.initState();
    _generateMnemonic();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _mnemonicController.dispose();
    super.dispose();
  }

  void _generateMnemonic() {
    setState(() {
      _generatedMnemonic = bip39.generateMnemonic();
      _mnemonicController.text = _generatedMnemonic;
      _isCustomMnemonic = false;
    });
  }

  void _toggleCustomMnemonic() {
    setState(() {
      _isCustomMnemonic = !_isCustomMnemonic;
      if (_isCustomMnemonic) {
        _mnemonicController.text = _generatedMnemonic;
      } else {
        _generatedMnemonic = _mnemonicController.text;
      }
    });
  }

  void _validateMnemonic() {
    final mnemonic = _mnemonicController.text.trim();
    if (bip39.validateMnemonic(mnemonic)) {
      setState(() {
        _generatedMnemonic = mnemonic;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mnemonic válido'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mnemonic inválido. Verifica que tenga 12, 15, 18, 21 o 24 palabras válidas',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveMnemonic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mnemonicProvider = context.read<MnemonicProvider>();

      final newMnemonic = Mnemonic(
        mnemonic: _isCustomMnemonic
            ? _mnemonicController.text.trim()
            : _generatedMnemonic,
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        createdAt: DateTime.now(),
      );

      await mnemonicProvider.addMnemonic(newMnemonic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mnemonic guardado exitosamente'),
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
        title: const Text('Nuevo Mnemonic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mnemonic generado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isCustomMnemonic
                                ? 'Mnemonic Personalizado:'
                                : 'Mnemonic Generado:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _toggleCustomMnemonic,
                                icon: Icon(
                                  _isCustomMnemonic
                                      ? Icons.auto_awesome
                                      : Icons.edit,
                                ),
                                tooltip: _isCustomMnemonic
                                    ? 'Usar generación automática'
                                    : 'Editar manualmente',
                              ),
                              IconButton(
                                onPressed: _generateMnemonic,
                                icon: const Icon(Icons.refresh),
                                tooltip: 'Generar nuevo mnemonic',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isCustomMnemonic) ...[
                        // Campo editable para mnemonic personalizado
                        TextFormField(
                          controller: _mnemonicController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'Ingresa tu frase mnemotécnica (12, 15, 18, 21 o 24 palabras)',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: _validateMnemonic,
                              icon: const Icon(Icons.check_circle),
                              tooltip: 'Validar mnemonic',
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El mnemonic es requerido';
                            }
                            if (!bip39.validateMnemonic(value.trim())) {
                              return 'Mnemonic inválido. Debe tener 12, 15, 18, 21 o 24 palabras válidas';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        // Visualización del mnemonic generado
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SelectableText(
                            _generatedMnemonic,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${(_isCustomMnemonic ? _mnemonicController.text : _generatedMnemonic).split(' ').length} palabras',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
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
                        _isCustomMnemonic
                            ? 'Modo manual: Ingresa tu propia frase mnemotécnica. Usa el botón de validación para verificar que sea correcta.'
                            : 'Modo automático: Se genera una frase mnemotécnica aleatoria y segura. Puedes cambiar a modo manual para ingresar tu propia frase.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingresa un nombre para este mnemonic',
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

              // Campo password
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Ingresa un password para proteger el mnemonic',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El password es requerido';
                  }
                  if (value.length < 8) {
                    return 'El password debe tener al menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMnemonic,
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
                        'Guardar Mnemonic',
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
