**Especificaciones del flujo de autenticación:**

1. **Contexto Global**
   - La aplicación debe tener un contexto global para guardar el usuario y las funciones de login y logout.

2. **Persistencia**
   - Usar MongoDB para almacenar los datos necesarios de la sesión.

3. **Interfaz**
   - Incluir una cabecera con opciones de login y logout.
   - Mostrar un dashboard cuando el usuario esté conectado.

4. **Proceso de Login**
   - Al iniciar el login, se genera un QR code con los siguientes datos:
     - dominio
     - aleatorio
     - address de Ethereum
     - signature ECDSA (firma de dominio, aleatorio y address)
   - El deep link del QR code tiene el formato:  
     `login://dominio?aleatorio=44&address=454&signature=4454`
   - Se guarda la URL en la base de datos con estado "pendiente".

5. **Polling**
   - El frontend realiza polling al servidor para comprobar si la petición pasa a "completado" o "rechazado".

6. **Finalización del Login**
   - Para completar la petición, el servidor debe recibir un POST con:
     - aleatorio
     - address del cliente
     - signature del cliente
   - El servidor valida la signature y, si es correcta, marca la petición como "completada".
   - Cuando el frontend detecta el estado "completado", almacena el JWT generado en una cookie y en localStorage.
   - En la cabecera se muestra el address que firmó el token.

7. **JWT**
   - El JWT generado contiene el address del cliente y un timestamp.
   - El token tiene una duración de aproximadamente 3 minutos.