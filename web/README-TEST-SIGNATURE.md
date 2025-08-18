# Programa Test-Signature

Este programa demuestra cómo firmar y verificar mensajes usando la biblioteca `ethers.js` con claves privadas de Ethereum.

## Archivos del Programa

### 1. `test-signature.js` (JavaScript)
- Versión básica en JavaScript
- Ejecutar con: `node test-signature.js`

### 2. `test-signature.ts` (TypeScript)
- Versión en TypeScript con análisis detallado
- Ejecutar con: `npx ts-node test-signature.ts`

### 3. `test-signature-correct.ts` (TypeScript Corregido)
- Versión que genera la firma correcta
- Ejecutar con: `npx ts-node test-signature-correct.ts`

## Datos de Prueba

```json
{
  "random": "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a",
  "address": "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
  "signature": "0x0f81b26a3fbcb656fe1fc52dd2980047d36bf7f1404410dabb9252ade240fecc1a2822c4507b79d5b70a9d0da37cf155ab3a1a1afa1813f2447a7e63d17f6fd51b"
}
```

## Clave Privada

```
0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## Descubrimientos Importantes

### 1. Formato Correcto del Mensaje
- **❌ Incorrecto**: Firmar solo el random sin `0x` (ej: `0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a`)
- **✅ Correcto**: Firmar el random con `0x` (ej: `0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a`)

### 2. Problema en el Sistema Actual
El sistema actual en `verify-signature/route.ts` usa:
```typescript
const message = `{random}`; // ❌ Incorrecto
```

Debería usar:
```typescript
const message = random; // ✅ Correcto (con 0x)
```

### 3. Verificación de Firmas
- **Firma Original**: ✅ Válida cuando se usa el formato correcto
- **Firma Generada**: ✅ Coincide exactamente con la original
- **Dirección Recuperada**: ✅ Coincide con `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

## Uso del Programa

### Ejecutar en JavaScript
```bash
node test-signature.js
```

### Ejecutar en TypeScript
```bash
npx ts-node test-signature.ts
npx ts-node test-signature-correct.ts
```

## Salida del Programa

El programa muestra:
1. ✅ Verificación de la wallet creada
2. ✅ Comparación de direcciones
3. ✅ Generación de firma
4. ✅ Verificación de firma
5. ✅ Comparación con firma original
6. ✅ Generación de nuevos datos de prueba

## Objeto de Datos Generado

```json
{
  "random": "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a",
  "address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "signature": "0x0f81b26a3fbcb656fe1fc52dd2980047d36bf7f1404410dabb9252ade240fecc1a2822c4507b79d5b70a9d0da37cf155ab3a1a1afa1813f2447a7e63d17f6fd51b"
}
```

## Dependencias

- `ethers`: ^6.15.0 (ya instalado en el proyecto)
- `ts-node`: Para ejecutar archivos TypeScript

## Notas Técnicas

- El programa usa `ethers.Wallet` para crear la wallet desde la clave privada
- `wallet.signMessage()` para firmar mensajes
- `ethers.verifyMessage()` para verificar firmas
- El formato del mensaje es crítico para la verificación correcta
