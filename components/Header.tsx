import Link from "next/link";
import { ShoppingBag, Search, Menu } from "lucide-react";

export default function Header() {
  return <header className="border-b border-neutral-200 bg-white">
    <div className="container flex h-[76px] items-center justify-between">
      <Link href="/" className="text-[19px] font-black tracking-[-.08em]">LOCALBRAND<span className="font-light">SHOES.</span></Link>
      <nav className="desktop-nav flex items-center gap-8">
        <Link className="nav-link" href="/">Home</Link><Link className="nav-link" href="/shop">Shop</Link>
        <Link className="nav-link" href="/shop?category=sneakers">Sneakers</Link><Link className="nav-link" href="/shop?category=running">Running</Link>
        <Link className="nav-link" href="/shop?category=casual">Casual</Link>
      </nav>
      <div className="flex items-center gap-5"><Link href="/shop" aria-label="Cari"><Search size={18}/></Link><Link href="/cart" aria-label="Keranjang"><ShoppingBag size={18}/></Link><Link href="/login" className="nav-link">Account</Link><Menu className="md:hidden" size={19}/></div>
    </div>
  </header>;
}
