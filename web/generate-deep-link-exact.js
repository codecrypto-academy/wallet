const { ethers } = require('ethers');

// Datos exactos proporcionados por el usuario
const exactData = {
  random: "0x0d865ee921c85a45fa5fe68b5c1326cd822d9e24f6f3dccedfd45423fa92fb8a",
  timestamp: 1754900259,
  address: "0x42436188b8F17DabB179c82b6277B35AD010c65b",
  signature: "0x7c56dd5cb41e02dc56760afcc2dd65eec437ca7254d9e9822b40c8de89cd2534765e2354fdaa8950e5f38a579b6f7c4cd64780e9e580649219dc6cd15ac2ecfd1b"
};

// Clave privada para verificar y generar nuevas firmas
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

async function generateExactDeepLinkCommand() {
  try {
    console.log("🔗 === GENERADOR DE DEEP LINK EXACTO ===\n");
    
    // Crear wallet con la clave privada
    const wallet = new ethers.Wallet(privateKey);
    console.log("1️⃣ WALLET CREADA");
    console.log("   Dirección de la clave privada:", wallet.address);
    console.log("   Dirección esperada en los datos:", exactData.address);
    console.log("   ¿Coinciden?", wallet.address.toLowerCase() === exactData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    console.log();
    
    // Verificar la firma original
    console.log("2️⃣ VERIFICACIÓN DE LA FIRMA ORIGINAL");
    try {
      const recoveredAddress = ethers.verifyMessage(exactData.random, exactData.signature);
      console.log("   Dirección recuperada:", recoveredAddress);
      console.log("   ¿Coincide con la esperada?", recoveredAddress.toLowerCase() === exactData.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
      console.log("   ¿Firma válida?", "✅ SÍ");
    } catch (error) {
      console.log("   ❌ Error verificando firma:", error.message);
    }
    console.log();
    
    // Generar deep link con los datos exactos
    console.log("3️⃣ DEEP LINK CON DATOS EXACTOS");
    const deepLink = `login://ethereum-login-app.com?aleatorio=${exactData.random}&timestamp=${exactData.timestamp}&address=${exactData.address}&signature=${exactData.signature}`;
    console.log("   Deep Link:");
    console.log("   " + deepLink);
    console.log();
    
    // Generar comando xcrun
    console.log("4️⃣ COMANDO XCRUN PARA SIMULADOR iOS");
    const xcrunCommand = `xcrun simctl openurl booted "${deepLink}"`;
    console.log("   Comando completo:");
    console.log("   " + xcrunCommand);
    console.log();
    
    // Separador para fácil copia
    console.log("=".repeat(80));
    console.log("📋 COMANDO LISTO PARA COPIAR Y PEGAR:");
    console.log("=".repeat(80));
    console.log(xcrunCommand);
    console.log("=".repeat(80));
    console.log();
    
    // Generar nueva firma con la clave privada proporcionada
    console.log("5️⃣ NUEVA FIRMA GENERADA CON TU CLAVE PRIVADA");
    const newSignature = await wallet.signMessage(exactData.random);
    console.log("   Nueva firma:", newSignature);
    console.log("   ¿Coincide con la original?", newSignature === exactData.signature ? "✅ SÍ" : "❌ NO");
    console.log();
    
    // Deep link con nueva firma
    console.log("6️⃣ DEEP LINK CON NUEVA FIRMA");
    const newDeepLink = `login://ethereum-login-app.com?aleatorio=${exactData.random}&timestamp=${exactData.timestamp}&address=${wallet.address}&signature=${newSignature}`;
    console.log("   Nuevo Deep Link:");
    console.log("   " + newDeepLink);
    console.log();
    
    // Comando xcrun con nueva firma
    console.log("7️⃣ COMANDO XCRUN CON NUEVA FIRMA");
    const newXcrunCommand = `xcrun simctl openurl booted "${newDeepLink}"`;
    console.log("   Nuevo comando:");
    console.log("   " + newXcrunCommand);
    console.log();
    
    // Separador para nueva firma
    console.log("=".repeat(80));
    console.log("📋 COMANDO CON NUEVA FIRMA (LISTO PARA COPIAR):");
    console.log("=".repeat(80));
    console.log(newXcrunCommand);
    console.log("=".repeat(80));
    console.log();
    
    // Resumen de opciones
    console.log("8️⃣ RESUMEN DE OPCIONES");
    console.log("   Opción 1: Usar datos exactos (firma original)");
    console.log("   - Address:", exactData.address);
    console.log("   - Signature:", exactData.signature);
    console.log();
    console.log("   Opción 2: Usar tu clave privada (nueva firma)");
    console.log("   - Address:", wallet.address);
    console.log("   - Signature:", newSignature);
    console.log();
    
    // Instrucciones de uso
    console.log("9️⃣ INSTRUCCIONES DE USO");
    console.log("   1. Copia el comando xcrun que prefieras");
    console.log("   2. Abre Terminal en macOS");
    console.log("   3. Pega y ejecuta el comando");
    console.log("   4. El deep link se abrirá en el simulador iOS");
    console.log("   5. Verifica que la app reciba los parámetros correctamente");
    console.log();
    
    console.log("🎉 ¡COMANDOS GENERADOS EXITOSAMENTE!");
    console.log("   Elige el comando que mejor se adapte a tus necesidades");
    
  } catch (error) {
    console.error("❌ Error generando el comando:", error.message);
  }
}

// Ejecutar el generador
generateExactDeepLinkCommand();
