import '../database/database_helper.dart';
import '../models/endpoint.dart';

class EndpointRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Create
  Future<int> createEndpoint(Endpoint endpoint) async {
    return await _databaseHelper.insertEndpoint(endpoint);
  }

  // Read
  Future<List<Endpoint>> getAllEndpoints() async {
    return await _databaseHelper.getAllEndpoints();
  }

  Future<Endpoint?> getEndpointById(int id) async {
    return await _databaseHelper.getEndpoint(id);
  }

  // Update
  Future<int> updateEndpoint(Endpoint endpoint) async {
    return await _databaseHelper.updateEndpoint(endpoint);
  }

  // Delete
  Future<int> deleteEndpoint(int id) async {
    return await _databaseHelper.deleteEndpoint(id);
  }

  // Helper method to create a new endpoint with current timestamp
  Future<int> createNewEndpoint({
    required String name,
    required String url,
    required String chanId,
  }) async {
    final newEndpoint = Endpoint(
      name: name,
      url: url,
      chanId: chanId,
      createdAt: DateTime.now(),
    );
    return await createEndpoint(newEndpoint);
  }
}
