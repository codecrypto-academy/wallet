import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/endpoint.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../providers/endpoint_provider.dart';

class SendTransactionScreen extends StatefulWidget {
  final Account account;

  const SendTransactionScreen({super.key, required this.account});

  @override
  State<SendTransactionScreen> createState() => _SendTransactionScreenState();
}

class _SendTransactionScreenState extends State<SendTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  final _transactionService = TransactionService();

  Endpoint? _selectedEndpoint;
  bool _isLoading = false;
  List<Endpoint> _endpoints = [];

  @override
  void initState() {
    super.initState();
    _loadEndpoints();
  }

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadEndpoints() async {
    try {
      final endpointProvider = context.read<EndpointProvider>();
      await endpointProvider.loadEndpoints();
      setState(() {
        _endpoints = endpointProvider.endpoints;
        if (_endpoints.isNotEmpty) {
          _selectedEndpoint = _endpoints.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando endpoints: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTx() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEndpoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un endpoint'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar transacción para envío
      final result = await _transactionService.sendTx(
        widget.account.address,
        widget.account,
        _toAddressController.text.trim(),
        _amountController.text.trim(),
        _selectedEndpoint!,
      );

      if (result.isNotEmpty) {
        // Mostrar diálogo de confirmación
        if (mounted) {
          _showConfirmationDialog({
            'transactionData': result,
            'fromAddress': widget.account.address,
            'toAddress': _toAddressController.text.trim(),
            'amount': _amountController.text.trim(),
            'endpoint': _selectedEndpoint!.name,
          });
        }
      } else {
        throw Exception(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparando transacción: $e'),
            backgroundColor: Colors.red,
          ),
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

  void _showConfirmationDialog(Map<String, dynamic> transactionData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Transacción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres enviar esta transacción?'),
            const SizedBox(height: 16),
            Text('Desde: ${widget.account.address}'),
            Text('A: ${_toAddressController.text.trim()}'),
            Text('Cantidad: ${_amountController.text.trim()} ETH'),
            Text('Endpoint: ${_selectedEndpoint!.name}'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ ADVERTENCIA: Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendSignedTransaction(transactionData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar y Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSignedTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Enviar transacción
      final result = await _transactionService.sendTx(
        widget.account.address,
        widget.account,
        _toAddressController.text.trim(),
        _amountController.text.trim(),
        _selectedEndpoint!,
      );

      if (result.isNotEmpty) {
        // Guardar transacción en base de datos
        final transaction = Transaction(
          accountId: widget.account.id!,
          fromAddress: widget.account.address,
          toAddress: _toAddressController.text.trim(),
          amount: _amountController.text.trim(),
          status: '1',
          txHash: result,
          createdAt: DateTime.now(),
        );

        await _transactionService.saveTransaction(transaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transacción enviada: $result'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enviando transacción: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: const Text('Enviar Transacción'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de la cuenta origen
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cuenta Origen:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.account.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dirección: ${_maskAddress(widget.account.address)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo dirección destino
              TextFormField(
                controller: _toAddressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección Destino',
                  hintText: '0x...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La dirección es requerida';
                  }
                  if (!_transactionService.isValidEthereumAddress(
                    value.trim(),
                  )) {
                    return 'Ingresa una dirección Ethereum válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo cantidad
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (ETH)',
                  hintText: '0.1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La cantidad es requerida';
                  }
                  if (!_transactionService.isValidAmount(value.trim())) {
                    return 'Ingresa una cantidad válida mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selector de endpoint
              DropdownButtonFormField<Endpoint>(
                value: _selectedEndpoint,
                decoration: const InputDecoration(
                  labelText: 'Endpoint',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                items: _endpoints.map((endpoint) {
                  return DropdownMenuItem<Endpoint>(
                    value: endpoint,
                    child: Text(endpoint.name),
                  );
                }).toList(),
                onChanged: (Endpoint? newValue) {
                  setState(() {
                    _selectedEndpoint = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Debes seleccionar un endpoint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón enviar
              ElevatedButton(
                onPressed: _isLoading ? null : _sendTx,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Enviar Transacción',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
