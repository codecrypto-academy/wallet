const { ethers } = require('ethers');

// Datos proporcionados
const testData = {
  "random": "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a",
  "address": "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
  "signature": "0x0f81b26a3fbcb656fe1fc52dd2980047d36bf7f1404410dabb9252ade240fecc1a2822c4507b79d5b70a9d0da37cf155ab3a1a1afa1813f2447a7e63d17f6fd51b"
};

// Clave privada proporcionada
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

async function testSignature() {
  try {
    console.log("=== PROGRAMA TEST-SIGNATURE ===\n");
    
    // Crear wallet con la clave privada
    const wallet = new ethers.Wallet(privateKey);
    console.log("Wallet creada con dirección:", wallet.address);
    console.log("Dirección esperada:", testData.address);
    console.log("¿Coinciden las direcciones?", wallet.address.toLowerCase() === testData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Extraer el random sin el prefijo 0x para firmar
    const randomWithoutPrefix = testData.random.slice(2);
    console.log("\nRandom (sin 0x):", randomWithoutPrefix);
    
    // Firmar el random
    const message = randomWithoutPrefix;
    const signature = await wallet.signMessage(message);
    console.log("Firma generada:", signature);
    console.log("Firma esperada:", testData.signature);
    console.log("¿Coinciden las firmas?", signature === testData.signature ? "✅ SÍ" : "❌ NO");
    
    // Verificar la firma
    const recoveredAddress = ethers.verifyMessage(message, signature);
    console.log("\nDirección recuperada de la firma:", recoveredAddress);
    console.log("¿La firma es válida?", recoveredAddress.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Verificar la firma original
    const originalRecoveredAddress = ethers.verifyMessage(message, testData.signature);
    console.log("Dirección recuperada de la firma original:", originalRecoveredAddress);
    console.log("¿La firma original es válida?", originalRecoveredAddress.toLowerCase() === testData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Generar nueva firma con el mismo formato que espera el sistema
    const newSignature = await wallet.signMessage(message);
    console.log("\n=== NUEVA FIRMA GENERADA ===");
    console.log("Random:", testData.random);
    console.log("Address:", wallet.address);
    console.log("Signature:", newSignature);
    
    // Crear objeto de datos para usar en el sistema
    const newTestData = {
      random: testData.random,
      address: wallet.address,
      signature: newSignature
    };
    
    console.log("\n=== OBJETO DE DATOS COMPLETO ===");
    console.log(JSON.stringify(newTestData, null, 2));
    
  } catch (error) {
    console.error("Error:", error.message);
  }
}

// Ejecutar el programa
testSignature();
