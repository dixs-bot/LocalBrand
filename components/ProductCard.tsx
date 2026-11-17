import Link from "next/link";
import { rupiah } from "@/lib/money";

export type Product = { id:string; name:string; slug:string; price:number; sale_price:number|null; category?:string|null; image_url?:string|null; is_featured?:boolean };
export default function ProductCard({ product }: { product: Product }) {
  const image = product.image_url || "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900&q=85";
  return <Link href={`/products/${product.slug}`} className="product-card group block">
    <div className="relative overflow-hidden bg-neutral-100"><img src={image} alt={product.name} className="transition duration-500 group-hover:scale-[1.04]"/>
      {product.sale_price && <span className="absolute left-3 top-3 bg-black px-3 py-1 text-[9px] tracking-widest text-white">SALE</span>}
    </div>
    <div className="flex items-start justify-between gap-3 pt-4"><div><p className="text-[10px] uppercase tracking-[.16em] text-neutral-500">{product.category || "Footwear"}</p><h3 className="mt-1 text-sm font-medium">{product.name}</h3></div>
      <div className="text-right text-xs">{product.sale_price ? <><p className="font-semibold">{rupiah(product.sale_price)}</p><p className="mt-1 text-neutral-400 line-through">{rupiah(product.price)}</p></> : <p className="font-semibold">{rupiah(product.price)}</p>}</div></div>
  </Link>;
}
