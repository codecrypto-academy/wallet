import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/endpoint_provider.dart';
import 'providers/mnemonic_provider.dart';
import 'providers/account_provider.dart';
import 'screens/main_tabs_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EndpointProvider()),
        ChangeNotifierProvider(create: (_) => MnemonicProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Endpoints',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainTabsScreen(),
    );
  }
}
