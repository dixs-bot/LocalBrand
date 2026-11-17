import ProductCard, { type Product } from "@/components/ProductCard";
import { createClient } from "@/lib/supabase/server";

const demo:Product[]=[
{id:"1",name:"LBS Court Mono",slug:"lbs-court-mono",price:459000,sale_price:399000,category:"Sneakers",image_url:"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900"},
{id:"2",name:"Everyday Runner",slug:"everyday-runner",price:529000,sale_price:null,category:"Running",image_url:"https://images.unsplash.com/photo-1556906781-9a412961c28c?w=900"},
{id:"3",name:"Classic Street Low",slug:"classic-street-low",price:379000,sale_price:null,category:"Casual",image_url:"https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=900"},
{id:"4",name:"Urban Pace",slug:"urban-pace",price:499000,sale_price:449000,category:"Sneakers",image_url:"https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?w=900"}];
export default async function Shop({searchParams}:{searchParams:Promise<{category?:string; q?:string}>}) {
 const params=await searchParams; let products=demo;
 try {const sb=await createClient();let q=sb.from("products").select("id,name,slug,price,sale_price,category:categories(name),product_images(image_url,is_primary)").eq("is_active",true);if(params.q)q=q.ilike("name",`%${params.q}%`);const {data}=await q.order("created_at",{ascending:false});if(data?.length)products=data.map((p:any)=>({id:p.id,name:p.name,slug:p.slug,price:Number(p.price),sale_price:p.sale_price?Number(p.sale_price):null,category:p.category?.name||"Footwear",image_url:p.product_images?.find((i:any)=>i.is_primary)?.image_url||p.product_images?.[0]?.image_url}));}catch{}
 if(params.category)products=products.filter(p=>p.category?.toLowerCase()===params.category?.toLowerCase());
 return <main className="container py-14"><p className="eyebrow">LocalBrandShoes collection</p><h1 className="section-title mt-3">The collection.</h1><p className="mt-3 text-sm text-neutral-500">Temukan sneakers, running shoes, dan casual shoes pilihan.</p>
 <form className="mt-8 flex max-w-lg gap-2"><input name="q" defaultValue={params.q} placeholder="Cari nama sepatu..." className="input"/><button className="btn">Search</button></form>
 <div className="mt-10 flex flex-wrap gap-3 text-[10px] uppercase tracking-widest">{["All","Sneakers","Running","Casual"].map(c=><a key={c} href={c==="All"?"/shop":`/shop?category=${c.toLowerCase()}`} className="border border-neutral-300 px-4 py-3 hover:bg-black hover:text-white">{c}</a>)}</div>
 <div className="mt-9 grid grid-cols-2 gap-x-4 gap-y-9 md:grid-cols-4 md:gap-6">{products.map(p=><ProductCard key={p.id} product={p}/>)}</div>
 {products.length===0&&<p className="py-20 text-center text-sm text-neutral-500">Produk belum tersedia pada kategori ini.</p>}
 </main>;
}
