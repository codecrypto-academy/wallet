import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:hex/hex.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/endpoint.dart';
import 'database_service.dart';
import 'dart:typed_data';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory TransactionService() => _instance;

  TransactionService._internal();

  Future<String> sendTx(
    String address,
    Account fromAccount,
    String toAddress,
    String amount,
    Endpoint endpoint,
  ) async {
    final httpClient = http.Client();
    final ethClient = web3.Web3Client(endpoint.url, httpClient);

    final web3.EthPrivateKey credentials = web3.EthPrivateKey.fromHex(
      fromAccount.privateKey,
    );
    final web3.EthereumAddress senderAddress = credentials.address;
    final web3.EthereumAddress receiverAddress = web3.EthereumAddress.fromHex(
      toAddress,
    );
    final web3.EtherAmount amountToSend = web3.EtherAmount.fromInt(
      web3.EtherUnit.ether,
      int.parse(amount),
    );
    debugPrint('Amount To Send: $amountToSend');
    final web3.EtherAmount gasPrice = await ethClient.getGasPrice();
    debugPrint('Gas Price: $gasPrice');
    final BigInt chainId = await ethClient.getChainId();
    debugPrint('Chain ID: $chainId');
    final transaction = web3.Transaction(
      to: receiverAddress,
      from: senderAddress,
      value: amountToSend,
      gasPrice: gasPrice,
      maxGas: 21000,
    );

    debugPrint('Transaction: $transaction');

    final Uint8List signedRawTransactionBytes = await ethClient.signTransaction(
      credentials,
      transaction,
      chainId: chainId.toInt(),
    );

    final String transactionHash = await ethClient.sendRawTransaction(
      signedRawTransactionBytes,
    );

    ethClient.dispose();
    return transactionHash;
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
