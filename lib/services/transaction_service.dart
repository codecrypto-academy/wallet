import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/endpoint.dart';
import 'database_service.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory TransactionService() => _instance;

  TransactionService._internal();

  // Enviar transacción a través de endpoint
  Future<Map<String, dynamic>> sendTransaction({
    required Account fromAccount,
    required String toAddress,
    required String amount,
    required Endpoint endpoint,
  }) async {
    try {
      debugPrint(
        'Enviando transacción desde ${fromAccount.address} a $toAddress',
      );
      debugPrint('Endpoint: ${endpoint.url}');

      // Preparar datos de la transacción
      final transactionData = {
        'from': fromAccount.address,
        'to': toAddress,
        'amount': amount,
        'privateKey': fromAccount.privateKey,
        'channelId': endpoint.chanId,
      };

      // Enviar transacción al endpoint
      final response = await http
          .post(
            Uri.parse(endpoint.url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(transactionData),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Respuesta del endpoint: ${response.statusCode}');
      debugPrint('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'txHash': responseData['txHash'] ?? 'unknown',
          'status': 'pending',
          'data': responseData,
        };
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error enviando transacción: $e');
      return {'success': false, 'error': e.toString(), 'status': 'failed'};
    }
  }

  // Guardar transacción en base de datos
  Future<int> saveTransaction(Transaction transaction) async {
    return await _databaseService.insertTransaction(transaction);
  }

  // Obtener transacciones de una cuenta
  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    return await _databaseService.getTransactionsByAccount(accountId);
  }

  // Obtener todas las transacciones
  Future<List<Transaction>> getAllTransactions() async {
    return await _databaseService.getTransactions();
  }

  // Actualizar estado de transacción
  Future<void> updateTransactionStatus(int transactionId, String status) async {
    // Primero obtener la transacción actual
    final transactions = await _databaseService.getTransactions();
    final transaction = transactions.firstWhere((t) => t.id == transactionId);

    // Crear transacción actualizada
    final updatedTransaction = Transaction(
      id: transaction.id,
      accountId: transaction.accountId,
      fromAddress: transaction.fromAddress,
      toAddress: transaction.toAddress,
      amount: transaction.amount,
      txHash: transaction.txHash,
      status: status,
      createdAt: transaction.createdAt,
    );

    await _databaseService.updateTransaction(updatedTransaction);
  }

  // Validar dirección Ethereum
  bool isValidEthereumAddress(String address) {
    // Validación básica de dirección Ethereum
    if (address.length != 42 || !address.startsWith('0x')) {
      return false;
    }

    // Verificar que solo contenga caracteres hexadecimales válidos
    final hexPattern = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return hexPattern.hasMatch(address);
  }

  // Validar cantidad
  bool isValidAmount(String amount) {
    try {
      final value = double.tryParse(amount);
      return value != null && value > 0;
    } catch (e) {
      return false;
    }
  }
}
