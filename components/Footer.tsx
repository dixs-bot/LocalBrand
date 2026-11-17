import Link from "next/link";
export default function Footer() {
  return <footer className="mt-24 bg-black text-white"><div className="container grid gap-10 py-14 md:grid-cols-3">
    <div><div className="text-2xl font-black tracking-[-.08em]">LOCALBRANDSHOES.</div><p className="mt-3 max-w-xs text-sm text-neutral-400">Step into your style. Temukan sepatu pilihan untuk setiap langkah.</p></div>
    <div><p className="eyebrow text-neutral-400">Explore</p><div className="mt-4 flex flex-col gap-3 text-sm text-neutral-300"><Link href="/shop">Semua Produk</Link><Link href="/shop?category=sneakers">Sneakers</Link><Link href="/shop?category=running">Running</Link><Link href="/shop?category=casual">Casual</Link></div></div>
    <div><p className="eyebrow text-neutral-400">Customer Care</p><div className="mt-4 flex flex-col gap-3 text-sm text-neutral-300"><Link href="/account">Akun Saya</Link><Link href="/orders">Pesanan Saya</Link><Link href="/admin">Admin</Link></div></div>
  </div><div className="border-t border-neutral-800 py-5 text-center text-[10px] tracking-widest text-neutral-500">© {new Date().getFullYear()} LOCALBRANDSHOES. ALL RIGHTS RESERVED.</div></footer>;
}
