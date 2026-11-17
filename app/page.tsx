import Link from "next/link";
import ProductCard, { type Product } from "@/components/ProductCard";
import { createClient } from "@/lib/supabase/server";

const fallback: Product[] = [
 {id:"1",name:"LBS Court Mono",slug:"lbs-court-mono",price:459000,sale_price:399000,category:"Sneakers",image_url:"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900&q=85"},
 {id:"2",name:"Everyday Runner",slug:"everyday-runner",price:529000,sale_price:null,category:"Running",image_url:"https://images.unsplash.com/photo-1556906781-9a412961c28c?w=900&q=85"},
 {id:"3",name:"Classic Street Low",slug:"classic-street-low",price:379000,sale_price:null,category:"Casual",image_url:"https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=900&q=85"},
 {id:"4",name:"Urban Pace",slug:"urban-pace",price:499000,sale_price:449000,category:"Sneakers",image_url:"https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?w=900&q=85"}
];

export default async function Home() {
  let products = fallback;
  try {
    const supabase = await createClient();
    const { data } = await supabase.from("products").select("id,name,slug,price,sale_price,category:categories(name),product_images(image_url,is_primary)").eq("is_active",true).order("created_at",{ascending:false}).limit(4);
    if (data?.length) products = data.map((p:any)=>({id:p.id,name:p.name,slug:p.slug,price:Number(p.price),sale_price:p.sale_price?Number(p.sale_price):null,category:p.category?.name||"Footwear",image_url:p.product_images?.find((i:any)=>i.is_primary)?.image_url||p.product_images?.[0]?.image_url}));
  } catch {}
  return <main>
    <section className="relative flex min-h-[590px] items-center overflow-hidden bg-[#ececea]">
      <div className="absolute inset-0"><img src="https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?w=2000&q=90" alt="Sneaker collection" className="h-full w-full object-cover object-center opacity-75"/></div>
      <div className="absolute inset-0 bg-gradient-to-r from-white via-white/75 to-transparent"/>
      <div className="container relative py-24"><p className="eyebrow">The new everyday essential</p><h1 className="mt-5 max-w-[650px] text-6xl font-medium leading-[.98] tracking-[-.075em] md:text-8xl">FIND YOUR<br/><span className="font-black">OWN PACE.</span></h1><p className="mt-7 max-w-sm text-sm leading-7 text-neutral-600">Temukan sepatu yang menemani setiap langkah. Desain berkarakter, nyaman dipakai, siap untuk gaya harianmu.</p><Link href="/shop" className="btn mt-9">Explore Collection</Link></div>
      <div className="absolute bottom-7 right-8 hidden text-[9px] tracking-[.3em] md:block">LOCALBRANDSHOES — 001 / NEW SEASON</div>
    </section>
    <section className="container py-20"><div className="flex items-end justify-between"><div><p className="eyebrow">Curated for your move</p><h2 className="section-title mt-3">Shop by category</h2></div><Link href="/shop" className="hidden text-xs underline underline-offset-4 md:block">View all collection</Link></div>
      <div className="mt-9 grid grid-cols-1 gap-3 md:grid-cols-3">
        {[["SNEAKERS","Everyday statement","/shop?category=sneakers","https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900"],["RUNNING","Move without limits","/shop?category=running","https://images.unsplash.com/photo-1556906781-9a412961c28c?w=900"],["CASUAL","Made for every day","/shop?category=casual","https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=900"]].map(([title,sub,href,img])=><Link href={href} key={title} className="group relative h-[330px] overflow-hidden bg-neutral-100"><img src={img} alt={title} className="h-full w-full object-cover transition duration-700 group-hover:scale-105"/><div className="absolute inset-0 bg-black/20"/><div className="absolute bottom-7 left-7 text-white"><p className="text-[10px] tracking-[.2em]">{sub}</p><h3 className="mt-2 text-3xl font-semibold tracking-tight">{title}</h3><p className="mt-3 text-[10px] tracking-widest underline underline-offset-4">SHOP NOW</p></div></Link>)}
      </div>
    </section>
    <section className="bg-[#f7f7f6] py-20"><div className="container"><div className="flex items-end justify-between"><div><p className="eyebrow">Selected for you</p><h2 className="section-title mt-3">Latest arrivals</h2></div><Link href="/shop" className="text-xs underline underline-offset-4">Shop all</Link></div><div className="mt-9 grid grid-cols-2 gap-x-4 gap-y-9 md:grid-cols-4 md:gap-6">{products.map(p=><ProductCard key={p.id} product={p}/>)}</div></div></section>
    <section className="container grid gap-10 py-24 md:grid-cols-2 md:items-center"><div><p className="eyebrow">Local style, everyday comfort</p><h2 className="section-title mt-4 max-w-md">Made to move.<br/>Designed to stay.</h2><p className="mt-5 max-w-md text-sm leading-7 text-neutral-600">Koleksi pilihan untuk aktivitas dan gaya sehari-hari. Temukan pasangan sepatu yang paling cocok dengan langkahmu.</p><Link href="/shop" className="btn mt-8">Discover the collection</Link></div><img src="https://images.unsplash.com/photo-1520256862855-398228c41684?w=1200&q=85" alt="Sneaker lifestyle" className="aspect-[5/4] w-full object-cover"/></section>
  </main>;
}
