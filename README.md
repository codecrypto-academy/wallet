Este proyecto está compuesto por una **aplicación Flutter** y dos **librerías** propias:

---

## 📱 Aplicación principal: `flutter_application_1`

- **Descripción:** Aplicación Flutter para gestionar endpoints, cuentas, mnemonics y transacciones relacionadas con blockchain/cryptocurrency.
- **Ubicación:** Carpeta raíz `flutter_application_1/`
- **Características principales:**
  - Interfaz de usuario para visualizar, agregar, editar y eliminar endpoints.
  - Gestión de frases mnemotécnicas y cuentas asociadas.
  - Visualización y registro de transacciones.
  - Arquitectura modular usando Provider para la gestión de estado.
  - Persistencia local de datos usando SQLite (a través de las librerías).

---

## 📦 Librerías incluidas

### 1. `blockchain_lib`

- **Ubicación:** `../blockchain_lib`
- **Propósito:** Provee utilidades y modelos relacionados con operaciones de blockchain, como validación de direcciones, generación de claves, y utilidades criptográficas.
- **Uso:** Importada como dependencia local en la app principal para operaciones de bajo nivel relacionadas con blockchain.

### 2. `bdd_lib`

- **Ubicación:** `../bdd_lib`
- **Propósito:** Abstracción y gestión de la base de datos local (SQLite) para la app y otras posibles aplicaciones.
- **Incluye:**
  - Modelos de datos reutilizables.
  - Métodos para CRUD (crear, leer, actualizar, eliminar) de entidades como endpoints, cuentas, mnemonics y transacciones.
  - Utiliza los paquetes `sqflite` y `path` para la gestión de la base de datos.
- **Uso:** Permite a la app principal acceder y manipular datos de manera eficiente y desacoplada.

---

**Resumen:**  
La app Flutter (`flutter_application_1`) utiliza las librerías `blockchain_lib` (para lógica blockchain) y `bdd_lib` (para persistencia de datos), permitiendo una arquitectura limpia, modular y fácilmente extensible para proyectos relacionados con blockchain y gestión de datos locales.
