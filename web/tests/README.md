# Tests E2E con Playwright

Este directorio contiene los tests end-to-end completos para el sistema de autenticación con Ethereum.

## Estructura de Tests

### 1. `auth-flow.spec.ts`
Test principal que verifica todo el circuito de autenticación:
- Generación de QR code
- Firma de mensaje con wallet
- Verificación de firma
- Redirección al dashboard
- Verificación de token JWT
- Funcionalidad de logout

### 2. `jwt-verification.spec.ts`
Test específico para verificar la integridad del token JWT:
- Estructura del JWT
- Contenido del payload
- Verificación de dirección de wallet
- Timestamps y expiración
- Almacenamiento en localStorage y cookies

### 3. `simplified-auth-flow.spec.ts`
Test simplificado usando helpers reutilizables:
- Flujo completo de autenticación
- Verificación de JWT
- Manejo de múltiples wallets
- Logout y limpieza de storage

### 4. `utils/auth-helpers.ts`
Clase helper para simplificar los tests:
- Generación de login requests
- Firma de mensajes
- Verificación de JWT
- Manejo de storage

## Comandos de Test

```bash
# Ejecutar todos los tests
npm run test:e2e

# Ejecutar tests con UI
npm run test:e2e:ui

# Ejecutar tests en modo headed (visible)
npm run test:e2e:headed

# Ejecutar tests en modo debug
npm run test:e2e:debug
```

## Configuración

### Playwright Config (`playwright.config.ts`)
- Configuración para múltiples navegadores (Chrome, Firefox, Safari)
- Servidor web automático (Next.js dev server)
- Timeouts y retry configurados
- Screenshots en fallos

### Variables de Entorno
- `JWT_SECRET`: Clave secreta para JWT (test-secret-key-for-testing-only)
- `MONGODB_URI`: URI de MongoDB para tests
- `NODE_ENV`: Entorno de test

## Cobertura de Tests

Los tests cubren:

### ✅ Flujo de Autenticación
- [x] Generación de QR code
- [x] Escaneo y firma de mensaje
- [x] Verificación de firma en backend
- [x] Generación de JWT
- [x] Redirección al dashboard

### ✅ Verificación de JWT
- [x] Estructura correcta del token
- [x] Dirección de wallet en payload
- [x] Timestamps válidos
- [x] Expiración configurada (3 minutos)

### ✅ Almacenamiento
- [x] JWT en localStorage
- [x] JWT en cookies
- [x] Dirección de wallet en localStorage
- [x] Sincronización entre storage y cookies

### ✅ UI y UX
- [x] Estados de carga
- [x] Mensajes de error
- [x] Transiciones entre pantallas
- [x] Información de wallet en dashboard

### ✅ Seguridad
- [x] Verificación de firmas
- [x] Expiración de requests
- [x] Limpieza de storage en logout
- [x] Validación de parámetros

## Ejecución de Tests

### Prerrequisitos
1. MongoDB corriendo localmente
2. Dependencias instaladas (`npm install`)
3. Playwright instalado (`npx playwright install`)

### Ejecución
```bash
# Instalar dependencias
npm install

# Instalar Playwright
npx playwright install

# Ejecutar tests
npm run test:e2e
```

### Debug
Para debuggear tests específicos:
```bash
# Ejecutar un test específico
npx playwright test auth-flow.spec.ts

# Ejecutar con UI
npx playwright test --ui

# Ejecutar en modo headed
npx playwright test --headed
```

## Troubleshooting

### MongoDB Connection
Si hay problemas de conexión a MongoDB:
1. Verificar que MongoDB esté corriendo
2. Verificar la URI en `playwright.config.ts`
3. Usar base de datos de test separada

### Timeouts
Si los tests fallan por timeouts:
1. Aumentar timeout en `playwright.config.ts`
2. Verificar que el servidor Next.js esté respondiendo
3. Verificar conectividad de red

### JWT Verification
Si falla la verificación de JWT:
1. Verificar `JWT_SECRET` en variables de entorno
2. Verificar formato del token
3. Verificar expiración del token
