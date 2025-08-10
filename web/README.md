
### **1. Configuración y Estado Global**

-   **Contexto Global:** Se creará un contexto global (`GlobalContext`) para almacenar la dirección de Ethereum del usuario y las funciones de `login` y `logout`.
-   **Almacenamiento de Sesión:**
    -   Se usará **MongoDB** para guardar los datos necesarios para el inicio de sesión.
    -   El **JWT** se guardará en una **cookie** y en el **localStorage** del navegador.

---

### **2. Interfaz de Usuario (UI)**

-   **Cabecera:** Contendrá los botones de `Login` y `Logout`.
-   **Dashboard:** Solo será visible para los usuarios autenticados.

---

### **3. Proceso de Login (Flujo del QR Code)**

-   **Generación del QR (Backend):**
    1.  Cuando un usuario inicia el login, el backend genera los siguientes datos: `dominio`, `aleatorio`, `timestamp` y la `address de Ethereum` del servidor.
    2.  Se crea una **signature ECDSA** firmando digitalmente estos cuatro datos.
    3.  El `timestamp` tendrá una duración de **10 minutos** para mayor seguridad.
    4.  Se genera una URL de **deep link** con el formato: `login://dominio?aleatorio=...&timestamp=...&address=...&signature=...`.
    5.  Esta URL se guarda en la base de datos con el estado `pendiente` y se envía al frontend para mostrar el QR.
    -   **Librería de Criptografía:** Se utilizará una biblioteca minimalista que ofrezca solo las funcionalidades de generación de claves, firma ECDSA y validación de firmas, evitando la sobrecarga de bibliotecas completas como `ethers`. La libreria debe de poder generar un address de ethereum a partir de la clave privada. Si tienes que ser ethers, puedes usar la libreria de ethers.

-   **Proceso de Verificación (Frontend):**
    1.  El frontend muestra el QR y comienza a hacer **pooling** cada segundo para verificar el estado de la solicitud en el backend.
    2.  El usuario escanea el QR con su billetera, que firma los datos y envía una solicitud **POST** al backend.

-   **Validación y Autenticación (Backend):**
    1.  El backend recibe la solicitud **POST** del cliente con su `aleatorio`, `address de Ethereum` y su `signature`.
    2.  Valida la `signature` del cliente y comprueba si el `timestamp` no ha expirado.
    3.  Si la firma es válida, actualiza el estado de la solicitud a `completado`.
    4.  Genera un **JWT** que incluye la dirección del cliente y un `timestamp` para una caducidad de 3 minutos.

-   **Finalización del Login (Frontend):**
    1.  Al detectar que la solicitud está `completada`, el frontend recibe el JWT.
    2.  Guarda el JWT en una **cookie** y en el **localStorage**.
    3.  El `GlobalContext` se actualiza y la dirección del usuario se muestra en la cabecera.

---

### **4. Proceso de Logout**

-   La función `logout` elimina el JWT del **localStorage** y de la **cookie** y restablece el estado del usuario en el `GlobalContext`.

### **5 Prueba del funcionamiento**

Hacer un programa typescript que haga lo siguiente:

1.  Le pasemos el deep link de login://dominio?aleatorio=...&timestamp=...&address=...&signature=...
2.  El programa valide la signature.
3.  Genere una clave private ethereum, y derive un address.
4.  El programa debe hacer un POST a la url de login://dominio?aleatorio=...&address=..&signature=...
5. Comprobar que en el front pasa al dashboard con el address generado y que el address generado aparece en la cabecera.


