const { ethers } = require('ethers');

// Clave privada para generar la firma
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// Datos base
const baseRandom = "0x2c1f528d5a544271171ff5447f70db5239951a57937efe0002ee94697bfa77e2";
const baseAddress = "0x4ab0400C941C36904A2D8D2A4d93d12661a3037E";

async function generateMobileDeepLink() {
  try {
    console.log("📱 === GENERADOR DE DEEP LINK PARA MÓVIL ===\n");
    
    // Crear wallet
    const wallet = new ethers.Wallet(privateKey);
    console.log("1️⃣ WALLET CREADA");
    console.log("   Dirección:", wallet.address);
    console.log("   Dirección esperada:", baseAddress);
    console.log("   ¿Coinciden?", wallet.address.toLowerCase() === baseAddress.toLowerCase() ? "✅ SÍ" : "❌ NO");
    console.log();
    
    // Generar timestamp actual
    const timestamp = Math.floor(Date.now() / 1000);
    console.log("2️⃣ TIMESTAMP GENERADO");
    console.log("   Timestamp:", timestamp);
    console.log("   Fecha:", new Date(timestamp * 1000).toISOString());
    console.log();
    
    // Firmar el random
    console.log("3️⃣ FIRMA GENERADA");
    const signature = await wallet.signMessage(baseRandom);
    console.log("   Firma:", signature);
    console.log();
    
    // Generar deep link
    console.log("4️⃣ DEEP LINK GENERADO");
    const deepLink = `login://ethereum-login-app.com?aleatorio=${baseRandom}&timestamp=${timestamp}&address=${wallet.address}&signature=${signature}`;
    console.log("   Deep Link:");
    console.log("   " + deepLink);
    console.log();
    
    // Generar comando xcrun
    console.log("5️⃣ COMANDO XCRUN PARA SIMULADOR iOS");
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
    
    // Verificación de la firma
    console.log("6️⃣ VERIFICACIÓN DE LA FIRMA");
    const recoveredAddress = ethers.verifyMessage(baseRandom, signature);
    console.log("   Dirección recuperada:", recoveredAddress);
    console.log("   ¿Firma válida?", recoveredAddress.toLowerCase() === wallet.address.toLowerCase() ? "✅ SÍ" : "❌ NO");
    console.log();
    
    // Datos del deep link para referencia
    console.log("7️⃣ DATOS DEL DEEP LINK");
    console.log("   Random:", baseRandom);
    console.log("   Timestamp:", timestamp);
    console.log("   Address:", wallet.address);
    console.log("   Signature:", signature);
    console.log();
    
    // Instrucciones de uso
    console.log("8️⃣ INSTRUCCIONES DE USO");
    console.log("   1. Copia el comando xcrun de arriba");
    console.log("   2. Abre Terminal en macOS");
    console.log("   3. Pega y ejecuta el comando");
    console.log("   4. El deep link se abrirá en el simulador iOS");
    console.log("   5. Verifica que la app reciba los parámetros correctamente");
    console.log();
    
    // Formato alternativo para testing
    console.log("9️⃣ FORMATO ALTERNATIVO PARA TESTING");
    console.log("   Si necesitas probar con diferentes datos:");
    console.log("   - Cambia el random en la variable baseRandom");
    console.log("   - Ejecuta el script nuevamente");
    console.log("   - Se generará un nuevo comando automáticamente");
    console.log();
    
    console.log("🎉 ¡COMANDO GENERADO EXITOSAMENTE!");
    console.log("   Copia el comando de arriba y pégalo en tu terminal");
    
  } catch (error) {
    console.error("❌ Error generando el comando:", error.message);
  }
}

// Ejecutar el generador
generateMobileDeepLink();
