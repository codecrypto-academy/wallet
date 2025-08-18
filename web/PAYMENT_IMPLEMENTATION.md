# Implementación del Módulo de Pagos

## Resumen de Cambios

Se han implementado los siguientes cambios en la aplicación web para agregar funcionalidad de pagos con deeplinks:

### 1. Actualización del Esquema de Deeplink de Autenticación

**Archivo modificado:** `src/components/LoginForm.tsx`

- **Antes:** `login://domain?parameters`
- **Después:** `tx://?txType=login&parameters`

La función `generateDeepLink` ahora genera URLs con el nuevo esquema y agrega el parámetro `txType=login` para identificar el tipo de transacción.

### 2. Módulo de Pagos en el Dashboard

**Archivo modificado:** `src/components/Dashboard.tsx`

Se agregó una nueva sección de pagos que incluye:

- **Botón de pago:** Permite a usuarios autenticados iniciar una transacción
- **Información de la transacción:** Muestra los detalles fijos de la transacción (destinatario, cantidad, red)
- **Generación dinámica de deeplink:** Crea el deeplink de pago usando la dirección del usuario autenticado

#### Flujo de Pago:
1. Usuario hace clic en "Initiate Payment"
2. Se llama al endpoint `/api/cobro` para registrar el intento de pago
3. Se genera el deeplink: `tx://?txType=transfer&from={user_address}&to=0x70997970C51812dc3A010C7d01b50e0d17dc79C8&amount=10&endpoint=http://localhost:8545`
4. Se redirige al usuario al deeplink
5. En caso de error, se llama al endpoint `/api/cobroko`

### 3. Endpoints del Backend

#### `/api/cobro` (POST)
**Archivo:** `src/app/api/cobro/route.ts`

- **Propósito:** Iniciar y validar transacciones antes de la redirección
- **Validaciones:**
  - Campos requeridos (from, to, amount, endpoint)
  - Formato de direcciones Ethereum
  - Validación de cantidad positiva
- **Funcionalidad:**
  - Genera ID único de transacción
  - Registra la solicitud en MongoDB
  - Devuelve confirmación de éxito

#### `/api/cobroko` (POST)
**Archivo:** `src/app/api/cobroko/route.ts`

- **Propósito:** Manejar transacciones fallidas o canceladas
- **Funcionalidad:**
  - Actualiza el estado de transacciones existentes a "failed"
  - Crea nuevos registros de transacciones fallidas (fallback)
  - Registra el motivo del error
  - Actualiza timestamps de fallo

### 4. Script de Prueba

**Archivo:** `test-payment-deeplink.sh`

Script ejecutable para probar el deeplink de pago en el simulador de iOS:

```bash
./test-payment-deeplink.sh
```

Este script ejecuta:
```bash
xcrun simctl openurl booted "tx://?txType=transfer&from=0x742d35cc6634c0532925a3b8d3c8f4f6e3c1c6f7&to=0x70997970C51812dc3A010C7d01b50e0d17dc79C8&amount=10&endpoint=http://localhost:8545"
```

## Estructura de Base de Datos

### Colección: `payment-requests` (MongoDB)

```javascript
{
  transactionId: "tx_1234567890_abc123",
  from: "0x742d35cc6634c0532925a3b8d3c8f4f6e3c1c6f7",
  to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
  amount: "10",
  endpoint: "http://localhost:8545",
  status: "initiated" | "failed",
  error: "Error message (if failed)",
  createdAt: Date,
  updatedAt: Date,
  failedAt: Date // (if failed)
}
```

## Configuración

### Parámetros Fijos de Pago:
- **Destinatario:** `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`
- **Cantidad:** `10 ETH`
- **Endpoint RPC:** `http://localhost:8545`

### Variables Dinámicas:
- **From:** Dirección del usuario autenticado
- **Transaction ID:** Generado automáticamente

## Uso

1. **Autenticación:** El usuario debe estar autenticado para acceder al botón de pago
2. **Pago:** Hacer clic en "Initiate Payment (10 ETH)" en el dashboard
3. **Redirección:** La aplicación redirigirá automáticamente al deeplink de la wallet
4. **Manejo de errores:** Los errores se registran automáticamente en `/api/cobroko`

## Testing

Para probar la funcionalidad:

1. Ejecutar la aplicación web
2. Autenticarse con una wallet
3. Hacer clic en el botón de pago en el dashboard
4. Usar el script de prueba para simular deeplinks: `./test-payment-deeplink.sh`

## Comando de Prueba Directo

```bash
xcrun simctl openurl booted "tx://?txType=transfer&from=0x742d35cc6634c0532925a3b8d3c8f4f6e3c1c6f7&to=0x70997970C51812dc3A010C7d01b50e0d17dc79C8&amount=10&endpoint=http://localhost:8545"
```
