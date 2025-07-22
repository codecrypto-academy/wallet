import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/endpoint_provider.dart';
import '../models/endpoint.dart';

class AddEndpointScreen extends StatefulWidget {
  final Endpoint? endpoint;

  const AddEndpointScreen({super.key, this.endpoint});

  @override
  State<AddEndpointScreen> createState() => _AddEndpointScreenState();
}

class _AddEndpointScreenState extends State<AddEndpointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _chanIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, llenar los campos con los datos existentes
    if (widget.endpoint != null) {
      _nameController.text = widget.endpoint!.name;
      _urlController.text = widget.endpoint!.url;
      _chanIdController.text = widget.endpoint!.chanId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _chanIdController.dispose();
    super.dispose();
  }

  Future<void> _saveEndpoint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final endpointProvider = context.read<EndpointProvider>();

      if (widget.endpoint != null) {
        // Actualizar endpoint existente
        final updatedEndpoint = Endpoint(
          id: widget.endpoint!.id,
          name: _nameController.text.trim(),
          url: _urlController.text.trim(),
          chanId: _chanIdController.text.trim(),
        );
        await endpointProvider.updateEndpoint(updatedEndpoint);
      } else {
        // Crear nuevo endpoint
        final newEndpoint = Endpoint(
          name: _nameController.text.trim(),
          url: _urlController.text.trim(),
          chanId: _chanIdController.text.trim(),
        );
        await endpointProvider.addEndpoint(newEndpoint);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.endpoint != null
                  ? 'Endpoint actualizado'
                  : 'Endpoint agregado',
            ),
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
        title: Text(
          widget.endpoint != null ? 'Editar Endpoint' : 'Nuevo Endpoint',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingresa el nombre del endpoint',
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
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://ejemplo.com/api',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La URL es requerida';
                  }
                  //final uri = Uri.tryParse(value.trim());
                  // if (uri == null || !uri.hasAbsolutePath) {
                  //   return 'Ingresa una URL válida';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chanIdController,
                decoration: const InputDecoration(
                  labelText: 'Channel ID',
                  hintText: 'Ingresa el Channel ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El Channel ID es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveEndpoint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.endpoint != null ? 'Actualizar' : 'Guardar',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
