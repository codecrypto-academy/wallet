import type { Metadata } from "next";
import "./globals.css";
import { GlobalContextProvider } from "../contexts/GlobalContext";

export const metadata: Metadata = {
  title: "Ethereum Login App",
  description: "Secure authentication using Ethereum wallets",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <GlobalContextProvider>
          {children}
        </GlobalContextProvider>
      </body>
    </html>
  );
}
