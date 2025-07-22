import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/endpoint_provider.dart';
import '../models/endpoint.dart';
import 'add_endpoint_screen.dart';

class EndpointsListScreen extends StatefulWidget {
  const EndpointsListScreen({super.key});

  @override
  State<EndpointsListScreen> createState() => _EndpointsListScreenState();
}

class _EndpointsListScreenState extends State<EndpointsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar endpoints al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EndpointProvider>().loadEndpoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Endpoints'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<EndpointProvider>(
        builder: (context, endpointProvider, child) {
          if (endpointProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (endpointProvider.endpoints.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay endpoints',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega tu primer endpoint',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: endpointProvider.endpoints.length,
            itemBuilder: (context, index) {
              final endpoint = endpointProvider.endpoints[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.link, color: Colors.blue),
                  title: Text(
                    endpoint.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('URL: ${endpoint.url}'),
                      Text('Channel ID: ${endpoint.chanId}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // Navegar a la pantalla de edición
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEndpointScreen(endpoint: endpoint),
                          ),
                        );
                        if (result == true) {
                          // Recargar la lista si se editó
                          endpointProvider.loadEndpoints();
                        }
                      } else if (value == 'delete') {
                        // Mostrar diálogo de confirmación
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: Text(
                              '¿Estás seguro de que quieres eliminar "${endpoint.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await endpointProvider.deleteEndpoint(endpoint.id!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Endpoint eliminado'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar'),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEndpointScreen()),
          );
          if (result == true) {
            // Recargar la lista si se agregó un nuevo endpoint
            context.read<EndpointProvider>().loadEndpoints();
          }
        },
        tooltip: 'Agregar Endpoint',
        child: const Icon(Icons.add),
      ),
    );
  }
}
