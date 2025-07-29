# BDD Library

Una biblioteca Flutter para gestionar tablas en base de datos SQLite con modelos predefinidos para wallets blockchain.

## Características

- ✅ Gestión completa de base de datos SQLite
- ✅ Modelos de datos para wallets blockchain
- ✅ Operaciones CRUD completas
- ✅ Relaciones entre tablas con claves foráneas
- ✅ Singleton pattern para conexión de base de datos
- ✅ Conversión automática de DateTime
- ✅ Estructura modular con repositorios
- ✅ API de compatibilidad y nueva API con repositorios
- ✅ Soporte para Flutter Web (con sqflite_common_ffi_web)

## Modelos

### Account
```dart
class Account {
    final int? id;
    final int mnemonicId;
    final String name;
    final String address;
    final int derivationIndex;
    final String derivationPathPattern;
    final DateTime createdAt;
}
```

### Mnemonic
```dart
class Mnemonic {
    final int? id;
    final String name;
    final String mnemonic;
    final String passphrase;
    final String masterKey;
    final DateTime createdAt;
    final DateTime updatedAt;
}
```

### Endpoint
```dart
class Endpoint {
    final int? id;
    final String name;
    final String url;
    final String chainId;
    final DateTime createdAt;
}
```

### Balance
```dart
class Balance {
    final int? id;
    final int accountId;
    final int endpointId; 
    final String balance;
    final DateTime createdAt;
}
```

### Tx (Transaction)
```dart
class Tx {
    final int? id;
    final int accountId;
    final int endpointId; 
    final int nonce;
    final String fromAccount;
    final String toAccount;
    final int amount;
    final DateTime createdAt;
}
```

## Instalación

Agrega las dependencias a tu `pubspec.yaml`:

```yaml
dependencies:
  bdd_lib:
    path: ../bdd_lib
  sqflite: ^2.3.0
  path: ^1.8.3

dev_dependencies:
  sqflite_common_ffi: ^2.3.2
  sqflite_common_ffi_web: ^0.4.2+3
```

## Uso

### Inicialización (Importante)

**Para aplicaciones Flutter móviles:**
```dart
import 'package:bdd_lib/bdd_lib.dart';

void main() async {
  final dbHelper = DatabaseHelper();
  // La base de datos se inicializa automáticamente
}
```

**Para tests y ejemplos (consola/desktop):**
```dart
import 'package:bdd_lib/bdd_lib.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Inicializar SQLite para tests/ejemplos
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  final dbHelper = DatabaseHelper();
}
```

**Para Flutter Web:**
```dart
import 'package:bdd_lib/bdd_lib.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  // Inicializar SQLite para web
  databaseFactory = databaseFactoryFfiWeb;
  
  final dbHelper = DatabaseHelper();
}
```

**Para ejemplos multiplataforma:**
```dart
import 'package:bdd_lib/bdd_lib.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Inicializar SQLite según la plataforma
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  final dbHelper = DatabaseHelper();
}
```

### API Tradicional (Compatibilidad)

```dart
// Inicializar
final dbHelper = DatabaseHelper();

// Crear un mnemonic
final mnemonic = Mnemonic(
  name: 'Mi Wallet',
  mnemonic: 'word1 word2 word3...',
  passphrase: 'mi-passphrase',
  masterKey: 'master-key',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Insertar en la base de datos
final mnemonicId = await dbHelper.insertMnemonic(mnemonic);

// Consultar datos
final allMnemonics = await dbHelper.getAllMnemonics();
final mnemonic = await dbHelper.getMnemonic(mnemonicId);

// Cerrar
await dbHelper.close();
```

### API con Repositorios (Nueva)

```dart
// Inicializar
final dbHelper = DatabaseHelper();

// Usar repositorios específicos
final mnemonicId = await dbHelper.mnemonics.insert(mnemonic);
final allMnemonics = await dbHelper.mnemonics.getAll();
final mnemonic = await dbHelper.mnemonics.getById(mnemonicId);

// Repositorios disponibles
dbHelper.mnemonics     // MnemonicRepository
dbHelper.endpoints     // EndpointRepository
dbHelper.accounts      // AccountRepository
dbHelper.balances      // BalanceRepository
dbHelper.transactions  // TransactionRepository
```

### Ejemplos completos

**Ejemplo de consola (recomendado):**
```bash
dart example/console_example.dart
```

**Ejemplo simple (consola/web):**
```bash
dart example/simple_example.dart
```

**Ejemplo Flutter (aplicación):**
```bash
flutter run example/flutter_example.dart
```

## Estructura del proyecto

```
bdd_lib/
├── lib/
│   ├── bdd_lib.dart              # Archivo principal
│   ├── database_helper.dart       # Gestión de BD + API de compatibilidad
│   ├── models/                    # 📦 Modelos de datos
│   │   ├── models.dart            # Exporta todos los modelos
│   │   ├── account.dart           # Clase Account
│   │   ├── mnemonic.dart          # Clase Mnemonic
│   │   ├── endpoint.dart          # Clase Endpoint
│   │   ├── balance.dart           # Clase Balance
│   │   └── tx.dart               # Clase Tx
│   └── repositories/              # 🔧 Repositorios de operaciones
│       ├── repositories.dart      # Exporta todos los repositorios
│       ├── mnemonic_repository.dart
│       ├── endpoint_repository.dart
│       ├── account_repository.dart
│       ├── balance_repository.dart
│       └── transaction_repository.dart
├── example/
│   ├── example.dart               # Ejemplo básico
│   ├── simple_example.dart        # Ejemplo consola/web
│   └── flutter_example.dart       # Ejemplo Flutter app
├── test/
│   └── bdd_lib_test.dart         # Tests unitarios
└── README.md
```

## Estructura de la base de datos

La biblioteca crea automáticamente las siguientes tablas:

1. **mnemonics** - Almacena información de frases mnemónicas
2. **endpoints** - Almacena endpoints de blockchain
3. **accounts** - Almacena cuentas derivadas de mnemonics
4. **balances** - Almacena balances de cuentas por endpoint
5. **transactions** - Almacena transacciones de cuentas

### Relaciones

- `accounts.mnemonicId` → `mnemonics.id`
- `balances.accountId` → `accounts.id`
- `balances.endpointId` → `endpoints.id`
- `transactions.accountId` → `accounts.id`
- `transactions.endpointId` → `endpoints.id`

## Notas importantes

- **Inicialización SQLite:** Para tests y ejemplos, siempre inicializa SQLite según la plataforma
- **Flutter Web:** Usar `sqflite_common_ffi_web` para soporte web
- **Flutter Móvil:** La inicialización es automática
- **Base de datos:** Se crea automáticamente en la primera ejecución
- **IDs:** Se generan automáticamente como AUTOINCREMENT
- **Fechas:** Se almacenan como timestamps (milliseconds)
- **Claves foráneas:** Están habilitadas para mantener integridad referencial
- **Singleton:** La clase DatabaseHelper usa el patrón Singleton
- **Compatibilidad:** Mantiene API anterior para no romper código existente

## Tests

```bash
flutter test
```

Los tests verifican todas las operaciones CRUD y relaciones entre tablas.
