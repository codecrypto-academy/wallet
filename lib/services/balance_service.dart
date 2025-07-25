import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/balance.dart';
import '../models/account.dart';
import '../models/endpoint.dart';
import 'database_service.dart';

class BalanceService {
  static final BalanceService _instance = BalanceService._internal();
  factory BalanceService() => _instance;
  BalanceService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// Obtiene el balance de una dirección desde un endpoint de Ethereum
  Future<String> getEthereumBalance(String address, String endpointUrl) async {
    try {
      debugPrint('Consultando balance para $address en $endpointUrl');

      // Crear el payload para la consulta JSON-RPC
      final payload = {
        'jsonrpc': '2.0',
        'method': 'eth_getBalance',
        'params': [address, 'latest'],
        'id': 1,
      };

      final response = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['error'] != null) {
          debugPrint('Error en respuesta RPC: ${data['error']}');
          throw Exception('Error RPC: ${data['error']['message']}');
        }

        final balanceHex = data['result'] as String;
        if (balanceHex == '0x') {
          return '0';
        }

        // Convertir de hex a decimal (Wei)
        final balanceWei = BigInt.parse(balanceHex.substring(2), radix: 16);

        // Convertir de Wei a Ether (18 decimales)
        final balanceEther = balanceWei / BigInt.from(10).pow(18);
        final remainder = balanceWei % BigInt.from(10).pow(18);

        // Formatear con decimales
        final balanceString =
            '$balanceEther.${remainder.toString().padLeft(18, '0').substring(0, 6)}';

        debugPrint('Balance obtenido: $balanceString ETH');
        return balanceString;
      } else {
        debugPrint('Error HTTP: ${response.statusCode} - ${response.body}');
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error obteniendo balance: $e');
      rethrow;
    }
  }

  /// Obtiene todas las combinaciones cuenta-endpoint y actualiza los balances
  Future<void> updateAllBalances() async {
    try {
      debugPrint('Iniciando actualización de balances...');

      // Obtener todas las cuentas y endpoints
      final accounts = await _databaseService.getAccounts();
      final endpoints = await _databaseService.getEndpoints();

      debugPrint('Cuentas encontradas: ${accounts.length}');
      debugPrint('Endpoints encontrados: ${endpoints.length}');

      int successCount = 0;
      int errorCount = 0;

      // Para cada combinación cuenta-endpoint
      for (final account in accounts) {
        for (final endpoint in endpoints) {
          try {
            debugPrint(
              'Procesando cuenta ${account.name} (${account.address}) en endpoint ${endpoint.name}',
            );

            // Obtener el balance desde el endpoint
            final balanceString = await getEthereumBalance(
              account.address,
              endpoint.url,
            );

            // Verificar que los IDs no sean null
            if (account.id == null || endpoint.id == null) {
              debugPrint('Error: ID de cuenta o endpoint es null');
              continue;
            }

            // Crear o actualizar el balance en la base de datos
            await _saveOrUpdateBalance(
              account.mnemonicId,
              account.id!,
              endpoint.id!,
              balanceString,
              'ETH',
            );

            successCount++;
            debugPrint('Balance actualizado exitosamente');

            // Pequeña pausa para no sobrecargar los endpoints
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (e) {
            errorCount++;
            debugPrint(
              'Error procesando cuenta ${account.name} en endpoint ${endpoint.name}: $e',
            );

            // Continuar con la siguiente combinación
            continue;
          }
        }
      }

      debugPrint(
        'Actualización completada. Éxitos: $successCount, Errores: $errorCount',
      );
    } catch (e) {
      debugPrint('Error en actualización masiva de balances: $e');
      rethrow;
    }
  }

  /// Guarda o actualiza un balance en la base de datos
  Future<void> _saveOrUpdateBalance(
    int mnemonicId,
    int accountId,
    int endpointId,
    String balance,
    String symbol,
  ) async {
    try {
      final db = await _databaseService.database;

      // Buscar si ya existe un balance para esta combinación
      final existingBalances = await db.query(
        'balances',
        where: 'mnemonicId = ? AND accountId = ? AND endpointId = ?',
        whereArgs: [mnemonicId, accountId, endpointId],
      );

      final now = DateTime.now();

      if (existingBalances.isNotEmpty) {
        // Actualizar balance existente
        final existingBalance = Balance.fromMap(existingBalances.first);
        final updatedBalance = Balance(
          id: existingBalance.id,
          mnemonicId: mnemonicId,
          accountId: accountId,
          endpointId: endpointId,
          balance: balance,
          symbol: symbol,
          lastUpdated: now,
        );

        await _databaseService.updateBalance(updatedBalance);
        debugPrint('Balance actualizado: ID ${existingBalance.id}');
      } else {
        // Crear nuevo balance
        final newBalance = Balance(
          id: 0, // Se asignará automáticamente
          mnemonicId: mnemonicId,
          accountId: accountId,
          endpointId: endpointId,
          balance: balance,
          symbol: symbol,
          lastUpdated: now,
        );

        final id = await _databaseService.insertBalance(newBalance);
        debugPrint('Nuevo balance creado: ID $id');
      }
    } catch (e) {
      debugPrint('Error guardando/actualizando balance: $e');
      rethrow;
    }
  }

  /// Obtiene el balance de una cuenta específica en un endpoint específico
  Future<void> updateBalanceForAccount(int accountId, int endpointId) async {
    try {
      final accounts = await _databaseService.getAccounts();
      final endpoints = await _databaseService.getEndpoints();

      final account = accounts.firstWhere((a) => a.id == accountId);
      final endpoint = endpoints.firstWhere((e) => e.id == endpointId);

      // Verificar que los IDs no sean null
      if (account.id == null || endpoint.id == null) {
        throw Exception('ID de cuenta o endpoint es null');
      }

      debugPrint(
        'Actualizando balance para cuenta ${account.name} en endpoint ${endpoint.name}',
      );

      final balanceString = await getEthereumBalance(
        account.address,
        endpoint.url,
      );

      await _saveOrUpdateBalance(
        account.mnemonicId,
        account.id!,
        endpoint.id!,
        balanceString,
        'ETH',
      );

      debugPrint('Balance actualizado exitosamente');
    } catch (e) {
      debugPrint('Error actualizando balance específico: $e');
      rethrow;
    }
  }
}
