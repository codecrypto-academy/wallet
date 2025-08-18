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

async function testSignature(): Promise<void> {
  try {
    console.log("=== PROGRAMA TEST-SIGNATURE (TypeScript) ===\n");
    
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
    const newTestData: TestData = {
      random: testData.random,
      address: wallet.address,
      signature: newSignature
    };
    
    console.log("\n=== OBJETO DE DATOS COMPLETO ===");
    console.log(JSON.stringify(newTestData, null, 2));
    
    // Probar diferentes formatos de mensaje para entender cómo se firmó originalmente
    console.log("\n=== ANÁLISIS DE FORMATOS DE MENSAJE ===");
    
    // Formato 1: Solo el random
    const message1 = randomWithoutPrefix;
    console.log("Formato 1 (solo random):", message1);
    
    // Formato 2: Random con 0x
    const message2 = testData.random;
    console.log("Formato 2 (random con 0x):", message2);
    
    // Formato 3: Random como bytes
    const message3 = ethers.getBytes(testData.random);
    console.log("Formato 3 (random como bytes):", ethers.hexlify(message3));
    
    // Formato 4: Mensaje personalizado como en el sistema
    const message4 = `{random}`;
    console.log("Formato 4 (mensaje del sistema):", message4);
    
    // Intentar verificar con diferentes formatos
    try {
      const recovered1 = ethers.verifyMessage(message1, testData.signature);
      console.log("Recuperado formato 1:", recovered1);
    } catch (e) {
      console.log("Error formato 1:", (e as Error).message);
    }
    
    try {
      const recovered2 = ethers.verifyMessage(message2, testData.signature);
      console.log("Recuperado formato 2:", recovered2);
    } catch (e) {
      console.log("Error formato 2:", (e as Error).message);
    }
    
    try {
      const recovered3 = ethers.verifyMessage(message3, testData.signature);
      console.log("Recuperado formato 3:", recovered3);
    } catch (e) {
      console.log("Error formato 3:", (e as Error).message);
    }
    
    try {
      const recovered4 = ethers.verifyMessage(message4, testData.signature);
      console.log("Recuperado formato 4:", recovered4);
    } catch (e) {
      console.log("Error formato 4:", (e as Error).message);
    }
    
  } catch (error) {
    console.error("Error:", (error as Error).message);
  }
}

// Ejecutar el programa
testSignature();
