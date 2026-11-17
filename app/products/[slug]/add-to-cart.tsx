 "use client";
import { useState } from "react";
import { ShoppingBag } from "lucide-react";
type Variant={id:string;size:string;color:string;stock:number};
export default function AddToCart({product}:{product:{id:string;name:string;price:number;image_url:string;variants:Variant[]}}){
 const [variant,setVariant]=useState("");const [qty,setQty]=useState(1);const [message,setMessage]=useState("");
 function add(){const v=product.variants.find(x=>x.id===variant);if(!v){setMessage("Pilih ukuran dan warna terlebih dahulu.");return;}if(v.stock<qty){setMessage("Stok tidak mencukupi.");return;}
 const key="lbs-cart";const cart=JSON.parse(localStorage.getItem(key)||"[]");const existing=cart.find((x:any)=>x.variantId===variant);if(existing)existing.qty+=qty;else cart.push({productId:product.id,variantId:variant,name:product.name,price:product.price,image_url:product.image_url,size:v.size,color:v.color,qty});localStorage.setItem(key,JSON.stringify(cart));setMessage("Produk berhasil ditambahkan ke keranjang.");}
 return <div><label className="label">Pilih ukuran / warna</label><div className="grid grid-cols-4 gap-2">{product.variants.map(v=><button key={v.id} onClick={()=>setVariant(v.id)} disabled={v.stock<=0} className={`border p-3 text-xs ${variant===v.id?"border-black bg-black text-white":"border-neutral-300"} disabled:opacity-30`}>{v.size}<span className="block text-[9px]">{v.color}</span></button>)}</div><div className="mt-6 flex items-center gap-4"><label className="label mb-0">Qty</label><button onClick={()=>setQty(Math.max(1,qty-1))} className="border px-3 py-2">−</button><span>{qty}</span><button onClick={()=>setQty(qty+1)} className="border px-3 py-2">+</button></div><button onClick={add} className="btn mt-7 w-full gap-3"><ShoppingBag size={16}/> Add to bag</button>{message&&<p className="mt-3 text-xs">{message}</p>}</div>;
}
