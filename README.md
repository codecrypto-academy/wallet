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


```
### Ejecutar en emulador

Para lanzar la aplicación en un emulador de macOS, asegúrate de tener Xcode instalado y ejecuta:
### Ejecutar en iOS (simulador o dispositivo)

Para ejecutar la aplicación en un simulador o dispositivo iOS, sigue estos pasos:

1. **Abre el proyecto en Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Selecciona el dispositivo o simulador** en la barra superior de Xcode.

3. **Ejecuta la app** presionando el botón de "Play" o usando el comando:
   ```bash
   flutter run -d ios
   ```

4. **Compilar para distribución (App Store/TestFlight):**
   ```bash
   flutter build ios --release
   ```

> **Nota:**  
> - Asegúrate de tener una cuenta de desarrollador de Apple y los certificados/provisioning profiles configurados.
> - Si es la primera vez que corres en un dispositivo físico, puede que debas autorizar el desarrollador en el dispositivo.

---


### Ejecutar en Android

Para ejecutar la aplicación en un emulador o dispositivo Android, sigue estos pasos:

1. **Conecta un dispositivo Android** o inicia un emulador desde Android Studio o usando el comando:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

2. **Ejecuta la app** con el siguiente comando:
   ```bash
   flutter run -d emulator-5554
   ```

3. **Compilar para distribución (APK o App Bundle):**
   - Para generar un APK:
     ```bash
     flutter build apk --release
     ```
   - Para generar un App Bundle (recomendado para Play Store):
     ```bash
     flutter build appbundle --release
     ```

### Ejecutar en iOS (simulador o dispositivo)

Para ejecutar la aplicación en un simulador o dispositivo iOS, sigue estos pasos:

1. **Abre el proyecto en Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Selecciona el dispositivo o simulador** en la barra superior de Xcode.

3. **Ejecuta la app** presionando el botón de "Play" o usando el comando:
   ```bash
   flutter run -d ios
   ```

4. **Compilar para distribución (App Store/TestFlight):**
   ```bash
   flutter build ios --release
   ```

### **Launch url en Android:**



```bash
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "login://MiApp?token=ABC123&api=https%3A%2F%2Ftu.api.com%2Fvalidate"
```

### **Launch url en iOS:**

```bash
xcrun simctl openurl booted "login://MiApp?token=ABC123&api=https%3A%2F%2Ftu.api.com%2Fvalidate"
```








> **Nota:**  
> - Asegúrate de tener configurado Android Studio y el SDK de Android.
> - Si es la primera vez que usas un dispositivo físico, habilita la depuración USB y acepta la autorización desde el dispositivo.

---

