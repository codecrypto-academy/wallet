const { ethers } = require('ethers');

// Datos generados por nuestro programa test-signature
const testData = {
  "random": "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a",
  "address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "signature": "0x0f81b26a3fbcb656fe1fc52dd2980047d36bf7f1404410dabb9252ade240fecc1a2822c4507b79d5b70a9d0da37cf155ab3a1a1afa1813f2447a7e63d17f6fd51b"
};

// Clave privada para generar nuevas firmas
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

async function testSystemVerification() {
  try {
    console.log("=== PRUEBA DE VERIFICACIÓN DEL SISTEMA CORREGIDO ===\n");
    
    // Crear wallet
    const wallet = new ethers.Wallet(privateKey);
    console.log("Wallet creada:", wallet.address);
    
    // Simular el proceso del sistema corregido
    console.log("\n1. Mensaje usado por el sistema corregido:");
    const message = testData.random; // Ahora usa el valor real, no '{random}'
    console.log("   Message:", message);
    
    // Verificar la firma original
    console.log("\n2. Verificación de la firma original:");
    const recoveredAddress = ethers.verifyMessage(message, testData.signature);
    console.log("   Dirección recuperada:", recoveredAddress);
    console.log("   ¿Coincide con la dirección esperada?", 
      recoveredAddress.toLowerCase() === testData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Generar nueva firma para el mismo random
    console.log("\n3. Generación de nueva firma:");
    const newSignature = await wallet.signMessage(message);
    console.log("   Nueva firma:", newSignature);
    
    // Verificar la nueva firma
    console.log("\n4. Verificación de la nueva firma:");
    const newRecoveredAddress = ethers.verifyMessage(message, newSignature);
    console.log("   Dirección recuperada:", newRecoveredAddress);
    console.log("   ¿Coincide con la wallet?", 
      newRecoveredAddress.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Comparar con el sistema anterior (incorrecto)
    console.log("\n5. Comparación con el sistema anterior (incorrecto):");
    const oldMessage = `{random}`;
    console.log("   Mensaje anterior:", oldMessage);
    
    try {
      const oldRecoveredAddress = ethers.verifyMessage(oldMessage, testData.signature);
      console.log("   Dirección recuperada (sistema anterior):", oldRecoveredAddress);
      console.log("   ¿Coincide con la dirección esperada?", 
        oldRecoveredAddress.toLowerCase() === testData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    } catch (error) {
      console.log("   Error en sistema anterior:", error.message);
    }
    
    // Resumen final
    console.log("\n=== RESUMEN ===");
    console.log("✅ Sistema corregido: Usa el valor real del random");
    console.log("❌ Sistema anterior: Usaba el string literal '{random}'");
    console.log("✅ Firma original: Válida con el sistema corregido");
    console.log("✅ Nueva firma: Válida con el sistema corregido");
    
    // Datos para usar en el sistema
    console.log("\n=== DATOS PARA EL SISTEMA ===");
    const systemData = {
      random: testData.random,
      address: wallet.address,
      signature: newSignature
    };
    console.log(JSON.stringify(systemData, null, 2));
    
  } catch (error) {
    console.error("Error:", error.message);
  }
}

// Ejecutar la prueba
testSystemVerification();
