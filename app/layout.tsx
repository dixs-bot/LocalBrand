import type { Metadata } from "next";
import "./globals.css";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: { default: "LocalBrandShoes — Step Into Your Style", template: "%s | LocalBrandShoes" },
  description: "Temukan sneakers, running shoes, dan casual shoes pilihan di LocalBrandShoes.",
  openGraph: { title: "LocalBrandShoes", description: "Step Into Your Style", type: "website" }
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="id"><body><Header/>{children}<Footer/></body></html>;
}
