# Flutter Application - Gestor de Endpoints

## Descripción
Esta es una aplicación Flutter para la gestión de endpoints, mnemonics, cuentas y transacciones relacionadas con blockchain/cryptocurrency.

## Estructura del Proyecto

### 📁 **Carpeta `lib/` - Código Fuente Principal**

El folder `lib` es el directorio principal donde se encuentra todo el código fuente de la aplicación Flutter. Está organizado siguiendo una arquitectura modular y bien estructurada:

```
lib/
├── main.dart              # Punto de entrada de la aplicación
├── models/                # Modelos de datos
├── providers/             # Gestión de estado (Provider pattern)
├── screens/               # Pantallas/Interfaces de usuario
└── services/              # Servicios y lógica de negocio
```

### 🔧 **Archivos principales:**

#### **`main.dart`** (36 líneas)
- **Punto de entrada** de la aplicación Flutter
- Configura el **Provider pattern** para gestión de estado global
- Inicializa tres providers principales:
  - `EndpointProvider` - Gestión de endpoints
  - `MnemonicProvider` - Gestión de frases mnemotécnicas
  - `AccountProvider` - Gestión de cuentas
- Define el tema de la aplicación con Material 3 y color púrpura
- Establece `MainTabsScreen` como pantalla principal

### 📊 **Carpeta `models/`** (4 archivos)
Contiene las clases de datos que representan las entidades principales:

- **`endpoint.dart`** (32 líneas) - Modelo para endpoints con campos: `id`, `name`, `url`, `chanId`
- **`account.dart`** (49 líneas) - Modelo para cuentas
- **`mnemonic.dart`** (41 líneas) - Modelo para frases mnemotécnicas
- **`transaction.dart`** (53 líneas) - Modelo para transacciones

### 🎛️ **Carpeta `providers/`** (3 archivos)
Implementa el patrón Provider para gestión de estado:

- **`endpoint_provider.dart`** (73 líneas) - Gestión de endpoints
- **`mnemonic_provider.dart`** (92 líneas) - Gestión de mnemonics
- **`account_provider.dart`** (125 líneas) - Gestión de cuentas

### 📱 **Carpeta `screens/`** (8 archivos)
Contiene todas las pantallas de la interfaz de usuario:

- **`main_tabs_screen.dart`** (117 líneas) - Pantalla principal con navegación por tabs
- **`endpoints_list_screen.dart`** (184 líneas) - Lista de endpoints
- **`add_endpoint_screen.dart`** (191 líneas) - Agregar nuevo endpoint
- **`mnemonics_list_screen.dart`** (372 líneas) - Lista de mnemonics
- **`add_mnemonic_screen.dart`** (226 líneas) - Agregar nuevo mnemonic
- **`accounts_list_screen.dart`** (361 líneas) - Lista de cuentas
- **`add_account_screen.dart`** (315 líneas) - Agregar nueva cuenta
- **`send_transaction_screen.dart`** (292 líneas) - Enviar transacciones

### 🔧 **Carpeta `services/`** (2 archivos)
Contiene la lógica de negocio y servicios:

- **`database_service.dart`** (528 líneas) - Servicio de base de datos local
- **`transaction_service.dart`** (128 líneas) - Servicio para manejo de transacciones

## 🎯 **Funcionalidades Principales**

La aplicación permite gestionar:

1. **Endpoints** - Conexiones a nodos de blockchain
2. **Mnemonics** - Frases de recuperación de wallets
3. **Accounts** - Cuentas/carteras de cryptocurrency
4. **Transactions** - Envío y gestión de transacciones

## 🏗️ **Arquitectura**

La aplicación utiliza una arquitectura moderna con:

- **Provider pattern** para gestión de estado
- **Material Design 3** para la interfaz de usuario
- **Navegación por tabs** para organizar las funcionalidades
- **Base de datos local** para persistencia de datos
- **Separación de responsabilidades** entre modelos, providers, screens y services

## 🚀 **Cómo ejecutar**

1. Asegúrate de tener Flutter instalado
2. Ejecuta `flutter pub get` para instalar dependencias
3. Ejecuta `flutter run` para iniciar la aplicación

## 📱 **Navegación**

La aplicación utiliza una navegación por tabs con cuatro secciones principales:
- **Inicio** - Pantalla de bienvenida
- **Endpoints** - Gestión de endpoints
- **Mnemonics** - Gestión de frases mnemotécnicas
- **Configuración** - Ajustes de la aplicación
