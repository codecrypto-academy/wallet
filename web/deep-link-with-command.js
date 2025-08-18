const { ethers } = require('ethers');

// Clave privada para generar la firma
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// Datos base
const baseRandom = "0x2c1f528d5a544271171ff5447f70db5239951a57937efe0002ee94697bfa77e2";

async function displayDeepLinkWithCommand() {
  try {
    console.log("📱 === DEEP LINK PARA MÓVIL ===\n");
    
    // Crear wallet
    const wallet = new ethers.Wallet(privateKey);
    
    // Generar timestamp actual
    const timestamp = Math.floor(Date.now() / 1000);
    
    // Firmar el random
    const signature = await wallet.signMessage(baseRandom);
    
    // Generar deep link
    const deepLink = `login://ethereum-login-app.com?aleatorio=${baseRandom}&timestamp=${timestamp}&address=${wallet.address}&signature=${signature}`;
    
    // Generar comando xcrun
    const xcrunCommand = `xcrun simctl openurl booted "${deepLink}"`;
    
    // Mostrar en el formato exacto que necesitas
    console.log("🔗 **Deep Link generado:**");
    console.log(deepLink);
    console.log();
    
    console.log("📋 **Or copy the deep link:**");
    console.log(deepLink);
    console.log();
    
    console.log("💻 **Comando para enviar al móvil (simulador):**");
    console.log("Copia y pega este comando en tu Terminal:");
    console.log();
    console.log("```bash");
    console.log(xcrunCommand);
    console.log("```");
    console.log();
    
    // Separador para fácil copia
    console.log("=".repeat(80));
    console.log("📋 COMANDO LISTO PARA COPIAR Y PEGAR:");
    console.log("=".repeat(80));
    console.log(xcrunCommand);
    console.log("=".repeat(80));
    console.log();
    
    // Verificación rápida
    console.log("✅ **Verificación:**");
    const recoveredAddress = ethers.verifyMessage(baseRandom, signature);
    console.log("   Firma válida:", recoveredAddress.toLowerCase() === wallet.address.toLowerCase() ? "SÍ" : "NO");
    console.log("   Dirección:", wallet.address);
    console.log("   Timestamp:", timestamp);
    console.log("   Fecha:", new Date(timestamp * 1000).toISOString());
    
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
}

// Ejecutar el generador
displayDeepLinkWithCommand();
