import 'package:flutter/material.dart';
import '../models/endpoint.dart';
import '../services/database_service.dart';

class EndpointProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Endpoint> _endpoints = [];
  bool _isLoading = false;

  List<Endpoint> get endpoints => _endpoints;
  bool get isLoading => _isLoading;

  // Cargar todos los endpoints
  Future<void> loadEndpoints() async {
    _isLoading = true;
    notifyListeners();

    try {
      _endpoints = await _databaseService.getEndpoints();
    } catch (e) {
      debugPrint('Error loading endpoints: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un nuevo endpoint
  Future<void> addEndpoint(Endpoint endpoint) async {
    try {
      final id = await _databaseService.insertEndpoint(endpoint);
      final newEndpoint = Endpoint(
        id: id,
        name: endpoint.name,
        url: endpoint.url,
        chanId: endpoint.chanId,
      );
      _endpoints.add(newEndpoint);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding endpoint: $e');
      rethrow;
    }
  }

  // Actualizar un endpoint
  Future<void> updateEndpoint(Endpoint endpoint) async {
    try {
      await _databaseService.updateEndpoint(endpoint);
      final index = _endpoints.indexWhere((e) => e.id == endpoint.id);
      if (index != -1) {
        _endpoints[index] = endpoint;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating endpoint: $e');
      rethrow;
    }
  }

  // Eliminar un endpoint
  Future<void> deleteEndpoint(int id) async {
    try {
      await _databaseService.deleteEndpoint(id);
      _endpoints.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting endpoint: $e');
      rethrow;
    }
  }
}
