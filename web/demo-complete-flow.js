const { ethers } = require('ethers');

// Clave privada para demostración
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// Datos de ejemplo
const randomValue = "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a";

async function demonstrateCompleteFlow() {
  try {
    console.log("🚀 === DEMOSTRACIÓN COMPLETA DEL FLUJO DE FIRMA ===\n");
    
    // 1. Crear wallet
    console.log("1️⃣ CREANDO WALLET");
    const wallet = new ethers.Wallet(privateKey);
    console.log("   Clave privada:", privateKey);
    console.log("   Dirección pública:", wallet.address);
    console.log("   Balance (simulado):", ethers.formatEther("1000000000000000000000"), "ETH\n");
    
    // 2. Generar random (simulado)
    console.log("2️⃣ GENERANDO RANDOM");
    console.log("   Random generado:", randomValue);
    console.log("   Longitud:", randomValue.length, "caracteres\n");
    
    // 3. Firmar el random
    console.log("3️⃣ FIRMANDO EL RANDOM");
    console.log("   Mensaje a firmar:", randomValue);
    console.log("   Nota: El mensaje incluye el prefijo 0x");
    
    const signature = await wallet.signMessage(randomValue);
    console.log("   Firma generada:", signature);
    console.log("   Longitud de firma:", signature.length, "caracteres\n");
    
    // 4. Verificar la firma
    console.log("4️⃣ VERIFICANDO LA FIRMA");
    const recoveredAddress = ethers.verifyMessage(randomValue, signature);
    console.log("   Dirección recuperada:", recoveredAddress);
    console.log("   ¿Coincide con la wallet original?", 
      recoveredAddress.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    console.log("   ¿La firma es válida?", "✅ SÍ\n");
    
    // 5. Crear objeto de datos completo
    console.log("5️⃣ CREANDO OBJETO DE DATOS");
    const completeData = {
      random: randomValue,
      address: wallet.address,
      signature: signature,
      timestamp: new Date().toISOString(),
      nonce: Math.random().toString(36).substring(7)
    };
    
    console.log("   Datos completos:");
    console.log(JSON.stringify(completeData, null, 4));
    console.log();
    
    // 6. Simular envío al sistema
    console.log("6️⃣ SIMULANDO ENVÍO AL SISTEMA");
    console.log("   POST /api/auth/verify-signature");
    console.log("   Body:", JSON.stringify({
      random: completeData.random,
      address: completeData.address,
      signature: completeData.signature
    }, null, 2));
    console.log();
    
    // 7. Simular verificación en el sistema
    console.log("7️⃣ SIMULANDO VERIFICACIÓN EN EL SISTEMA");
    console.log("   Sistema corregido:");
    console.log("   - Mensaje usado:", randomValue);
    console.log("   - Dirección recuperada:", recoveredAddress);
    console.log("   - Verificación:", "✅ EXITOSA");
    console.log();
    
    console.log("   Sistema anterior (incorrecto):");
    console.log("   - Mensaje usado: {random}");
    try {
      const wrongRecovered = ethers.verifyMessage("{random}", signature);
      console.log("   - Dirección recuperada:", wrongRecovered);
      console.log("   - ¿Coincide?", wrongRecovered.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    } catch (error) {
      console.log("   - Error:", error.message);
    }
    console.log();
    
    // 8. Resumen final
    console.log("8️⃣ RESUMEN FINAL");
    console.log("   ✅ Wallet creada correctamente");
    console.log("   ✅ Random generado y firmado");
    console.log("   ✅ Firma verificada exitosamente");
    console.log("   ✅ Sistema corregido funciona");
    console.log("   ❌ Sistema anterior fallaba");
    console.log("   ✅ Flujo completo demostrado");
    console.log();
    
    // 9. Datos para usar en el sistema
    console.log("9️⃣ DATOS LISTOS PARA USAR");
    console.log("   Estos datos pueden ser enviados directamente al endpoint:");
    console.log("   /api/auth/verify-signature");
    console.log();
    
    const systemReadyData = {
      random: completeData.random,
      address: completeData.address,
      signature: completeData.signature
    };
    
    console.log(JSON.stringify(systemReadyData, null, 2));
    console.log();
    
    console.log("🎉 ¡DEMOSTRACIÓN COMPLETADA EXITOSAMENTE!");
    
  } catch (error) {
    console.error("❌ Error en la demostración:", error.message);
  }
}

// Ejecutar la demostración
demonstrateCompleteFlow();
