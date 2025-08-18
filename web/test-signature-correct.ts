import { ethers } from 'ethers';

// Datos proporcionados
const testData = {
  "random": "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a",
  "address": "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
  "signature": "0x0f81b26a3fbcb656fe1fc52dd2980047d36bf7f1404410dabb9252ade240fecc1a2822c4507b79d5b70a9d0da37cf155ab3a1a1afa1813f2447a7e63d17f6fd51b"
};

// Clave privada proporcionada
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

interface TestData {
  random: string;
  address: string;
  signature: string;
}

async function testSignatureCorrect(): Promise<void> {
  try {
    console.log("=== PROGRAMA TEST-SIGNATURE CORRECTO ===\n");
    
    // Crear wallet con la clave privada
    const wallet = new ethers.Wallet(privateKey);
    console.log("Wallet creada con dirección:", wallet.address);
    console.log("Dirección esperada:", testData.address);
    console.log("¿Coinciden las direcciones?", wallet.address.toLowerCase() === testData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // IMPORTANTE: Usar el random CON el prefijo 0x para firmar
    // Esto es lo que se usó en la firma original
    const message = testData.random; // Con 0x
    console.log("\nMensaje a firmar (con 0x):", message);
    
    // Firmar el random con 0x
    const signature = await wallet.signMessage(message);
    console.log("Firma generada:", signature);
    console.log("Firma esperada:", testData.signature);
    console.log("¿Coinciden las firmas?", signature === testData.signature ? "✅ SÍ" : "❌ NO");
    
    // Verificar la firma generada
    const recoveredAddress = ethers.verifyMessage(message, signature);
    console.log("\nDirección recuperada de la firma generada:", recoveredAddress);
    console.log("¿La firma es válida?", recoveredAddress.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Verificar la firma original
    const originalRecoveredAddress = ethers.verifyMessage(message, testData.signature);
    console.log("Dirección recuperada de la firma original:", originalRecoveredAddress);
    console.log("¿La firma original es válida?", originalRecoveredAddress.toLowerCase() === testData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Generar nueva firma con el formato correcto
    const newSignature = await wallet.signMessage(message);
    console.log("\n=== NUEVA FIRMA GENERADA (FORMATO CORRECTO) ===");
    console.log("Random:", testData.random);
    console.log("Address:", wallet.address);
    console.log("Signature:", newSignature);
    
    // Crear objeto de datos para usar en el sistema
    const newTestData: TestData = {
      random: testData.random,
      address: wallet.address,
      signature: newSignature
    };
    
    console.log("\n=== OBJETO DE DATOS COMPLETO ===");
    console.log(JSON.stringify(newTestData, null, 2));
    
    // Verificar que la nueva firma funciona correctamente
    console.log("\n=== VERIFICACIÓN FINAL ===");
    const finalVerification = ethers.verifyMessage(message, newSignature);
    console.log("Dirección recuperada de la nueva firma:", finalVerification);
    console.log("¿La nueva firma es válida?", finalVerification.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    
    // Comparar con el formato usado en el sistema actual
    console.log("\n=== COMPARACIÓN CON EL SISTEMA ACTUAL ===");
    console.log("El sistema actual usa el mensaje:", `{random}`);
    console.log("Pero debería usar:", testData.random);
    console.log("Esto explica por qué las firmas no coinciden en el sistema actual");
    
  } catch (error) {
    console.error("Error:", (error as Error).message);
  }
}

// Ejecutar el programa
testSignatureCorrect();
