create extension if not exists pgcrypto;

create type public.app_role as enum ('customer','super_admin');
create type public.order_state as enum ('pending_payment','waiting_verification','paid','processing','shipped','completed','rejected','cancelled','expired','refunded');
create type public.payment_state as enum ('pending','waiting_verification','approved','rejected','expired','refunded');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role public.app_role not null default 'customer',
  created_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  image_url text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.brands (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  logo_url text,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  brand_id uuid references public.brands(id) on delete set null,
  name text not null,
  slug text not null unique,
  sku text unique,
  description text,
  material text,
  price numeric(14,2) not null check (price >= 0),
  sale_price numeric(14,2) check (sale_price is null or (sale_price >= 0 and sale_price <= price)),
  is_active boolean not null default true,
  is_featured boolean not null default false,
  is_best_seller boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null,
  storage_path text,
  alt_text text,
  is_primary boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  sku text unique,
  size text not null,
  color text not null,
  stock integer not null default 0 check (stock >= 0),
  reserved_stock integer not null default 0 check (reserved_stock >= 0 and reserved_stock <= stock),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(product_id,size,color)
);

create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  recipient_name text not null,
  phone text not null,
  address text not null,
  city text not null,
  postal_code text,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id),
  quantity int not null check (quantity > 0),
  created_at timestamptz not null default now(),
  unique(cart_id,variant_id)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  user_id uuid not null references auth.users(id),
  customer_name text not null,
  phone text not null,
  email text,
  address text not null,
  city text not null,
  postal_code text,
  note text,
  subtotal numeric(14,2) not null check (subtotal >= 0),
  shipping_amount numeric(14,2) not null default 0 check (shipping_amount >= 0),
  discount_amount numeric(14,2) not null default 0 check (discount_amount >= 0),
  total_amount numeric(14,2) not null check (total_amount >= 0),
  status public.order_state not null default 'pending_payment',
  payment_status public.payment_state not null default 'pending',
  expires_at timestamptz not null default (now() + interval '24 hours'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  variant_id uuid references public.product_variants(id) on delete set null,
  product_name text not null,
  sku text,
  size text not null,
  color text not null,
  unit_price numeric(14,2) not null check (unit_price >= 0),
  quantity int not null check (quantity > 0),
  line_total numeric(14,2) not null check (line_total >= 0)
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  proof_path text,
  status public.payment_state not null default 'pending',
  review_note text,
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.coupons (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  discount_type text not null check (discount_type in ('percentage','fixed')),
  discount_value numeric(14,2) not null check (discount_value > 0),
  minimum_purchase numeric(14,2) not null default 0,
  max_discount numeric(14,2),
  usage_limit int,
  used_count int not null default 0,
  starts_at timestamptz,
  expires_at timestamptz,
  is_active boolean not null default true
);

create table public.coupon_usages (
  id uuid primary key default gen_random_uuid(),
  coupon_id uuid not null references public.coupons(id),
  user_id uuid not null references auth.users(id),
  order_id uuid not null references public.orders(id),
  created_at timestamptz not null default now(),
  unique(coupon_id,user_id,order_id)
);

create table public.banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  image_url text not null,
  link_url text,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  order_id uuid not null references public.orders(id),
  rating int not null check (rating between 1 and 5),
  body text,
  is_approved boolean not null default false,
  created_at timestamptz not null default now(),
  unique(product_id,user_id,order_id)
);

create table public.store_settings (
  id uuid primary key default gen_random_uuid(),
  store_name text not null default 'LocalBrandShoes',
  whatsapp_number text,
  bank_name text,
  bank_account text,
  bank_holder text,
  payment_instructions text,
  updated_at timestamptz not null default now()
);

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid not null references public.product_variants(id),
  change_amount int not null,
  reason text not null,
  reference_id uuid,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table public.order_status_history (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  old_status public.order_state,
  new_status public.order_state not null,
  note text,
  changed_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index products_active_idx on public.products(is_active,created_at desc);
create index products_category_idx on public.products(category_id);
create index variants_product_idx on public.product_variants(product_id);
create index orders_user_idx on public.orders(user_id,created_at desc);
create index orders_status_idx on public.orders(status,payment_status);
create index payments_order_idx on public.payments(order_id,created_at desc);

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
create trigger profiles_updated before update on public.profiles for each row execute function public.set_updated_at();
create trigger products_updated before update on public.products for each row execute function public.set_updated_at();
create trigger variants_updated before update on public.product_variants for each row execute function public.set_updated_at();

create or replace function public.is_super_admin() returns boolean
language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.user_roles where user_id=auth.uid() and role='super_admin');
$$;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,full_name,email) values(new.id, new.raw_user_meta_data->>'full_name', new.email);
  insert into public.user_roles(user_id,role) values(new.id,'customer') on conflict do nothing;
  return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- Checkout: validates all variants and prices server-side; locks inventory rows to avoid overselling.
create or replace function public.create_order(
  p_customer_name text,p_phone text,p_email text,p_address text,p_city text,p_postal_code text,p_note text,p_items jsonb
) returns jsonb language plpgsql security definer set search_path=public as $$
declare
  v_user uuid := auth.uid();
  v_order_id uuid := gen_random_uuid();
  v_order_number text;
  v_subtotal numeric(14,2) := 0;
  v_item jsonb;
  v_variant public.product_variants%rowtype;
  v_product public.products%rowtype;
  v_qty int;
  v_price numeric(14,2);
begin
  if v_user is null then raise exception 'Silakan login terlebih dahulu'; end if;
  if p_customer_name is null or length(trim(p_customer_name))<2 or p_phone is null or p_address is null or p_city is null then raise exception 'Data penerima belum lengkap'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items)=0 then raise exception 'Keranjang kosong'; end if;

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'quantity')::int;
    if v_qty < 1 or v_qty > 20 then raise exception 'Jumlah produk tidak valid'; end if;
    select * into v_variant from public.product_variants where id=(v_item->>'variant_id')::uuid for update;
    if not found then raise exception 'Variasi produk tidak ditemukan'; end if;
    if v_variant.stock - v_variant.reserved_stock < v_qty then raise exception 'Stok tidak mencukupi untuk ukuran % warna %',v_variant.size,v_variant.color; end if;
    select * into v_product from public.products where id=v_variant.product_id and is_active=true;
    if not found then raise exception 'Produk tidak tersedia'; end if;
    v_price := coalesce(v_product.sale_price,v_product.price);
    v_subtotal := v_subtotal + v_price*v_qty;
  end loop;

  v_order_number := 'LBS-'||to_char(now(),'YYYYMMDD')||'-'||upper(substr(replace(v_order_id::text,'-',''),1,8));
  insert into public.orders(id,order_number,user_id,customer_name,phone,email,address,city,postal_code,note,subtotal,total_amount)
  values(v_order_id,v_order_number,v_user,p_customer_name,p_phone,p_email,p_address,p_city,p_postal_code,p_note,v_subtotal,v_subtotal);

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'quantity')::int;
    select * into v_variant from public.product_variants where id=(v_item->>'variant_id')::uuid for update;
    select * into v_product from public.products where id=v_variant.product_id;
    v_price := coalesce(v_product.sale_price,v_product.price);
    update public.product_variants set reserved_stock=reserved_stock+v_qty where id=v_variant.id;
    insert into public.order_items(order_id,product_id,variant_id,product_name,sku,size,color,unit_price,quantity,line_total)
    values(v_order_id,v_product.id,v_variant.id,v_product.name,v_variant.sku,v_variant.size,v_variant.color,v_price,v_qty,v_price*v_qty);
  end loop;
  insert into public.order_status_history(order_id,new_status,note,changed_by) values(v_order_id,'pending_payment','Order dibuat',v_user);
  return jsonb_build_object('order_id',v_order_id,'order_number',v_order_number,'total_amount',v_subtotal);
end; $$;

create or replace function public.admin_review_payment(p_payment_id uuid,p_status text,p_note text default null)
returns void language plpgsql security definer set search_path=public as $$
declare v_payment public.payments%rowtype; v_order public.orders%rowtype; v_item record;
begin
  if not public.is_super_admin() then raise exception 'Akses ditolak'; end if;
  if p_status not in ('approved','rejected') then raise exception 'Status tidak valid'; end if;
  select * into v_payment from public.payments where id=p_payment_id for update;
  if not found then raise exception 'Pembayaran tidak ditemukan'; end if;
  if v_payment.status not in ('waiting_verification','pending') then raise exception 'Pembayaran sudah diproses'; end if;
  select * into v_order from public.orders where id=v_payment.order_id for update;
  if p_status='approved' then
    for v_item in select * from public.order_items where order_id=v_order.id loop
      update public.product_variants set stock=stock-v_item.quantity,reserved_stock=greatest(0,reserved_stock-v_item.quantity) where id=v_item.variant_id and stock>=v_item.quantity;
      if not found then raise exception 'Stok berubah; periksa pesanan'; end if;
      insert into public.inventory_movements(variant_id,change_amount,reason,reference_id,created_by) values(v_item.variant_id,-v_item.quantity,'Order paid',v_order.id,auth.uid());
    end loop;
    update public.orders set status='paid',payment_status='approved',updated_at=now() where id=v_order.id;
  else
    for v_item in select * from public.order_items where order_id=v_order.id loop
      update public.product_variants set reserved_stock=greatest(0,reserved_stock-v_item.quantity) where id=v_item.variant_id;
    end loop;
    update public.orders set status='rejected',payment_status='rejected',updated_at=now() where id=v_order.id;
  end if;
  update public.payments set status=p_status::public.payment_state,review_note=p_note,reviewed_by=auth.uid(),reviewed_at=now() where id=p_payment_id;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,details) values(auth.uid(),'payment_'||p_status,'payment',p_payment_id,jsonb_build_object('order_id',v_order.id,'note',p_note));
  insert into public.order_status_history(order_id,old_status,new_status,note,changed_by) values(v_order.id,v_order.status,case when p_status='approved' then 'paid'::public.order_state else 'rejected'::public.order_state end,p_note,auth.uid());
end; $$;

alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.categories enable row level security;
alter table public.brands enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.product_variants enable row level security;
alter table public.addresses enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;
alter table public.coupons enable row level security;
alter table public.coupon_usages enable row level security;
alter table public.banners enable row level security;
alter table public.reviews enable row level security;
alter table public.store_settings enable row level security;
alter table public.inventory_movements enable row level security;
alter table public.order_status_history enable row level security;
alter table public.audit_logs enable row level security;

create policy "profiles own or admin" on public.profiles for select using (id=auth.uid() or public.is_super_admin());
create policy "profiles update own or admin" on public.profiles for update using (id=auth.uid() or public.is_super_admin()) with check (id=auth.uid() or public.is_super_admin());
create policy "roles own read or admin" on public.user_roles for select using (user_id=auth.uid() or public.is_super_admin());
create policy "categories public read" on public.categories for select using (is_active or public.is_super_admin());
create policy "categories admin all" on public.categories for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "brands public read" on public.brands for select using (true);
create policy "brands admin all" on public.brands for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "products public read" on public.products for select using (is_active or public.is_super_admin());
create policy "products admin all" on public.products for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "images public read" on public.product_images for select using (true);
create policy "images admin all" on public.product_images for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "variants public read" on public.product_variants for select using (true);
create policy "variants admin all" on public.product_variants for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "addresses own" on public.addresses for all using (user_id=auth.uid() or public.is_super_admin()) with check (user_id=auth.uid() or public.is_super_admin());
create policy "carts own" on public.carts for all using (user_id=auth.uid() or public.is_super_admin()) with check (user_id=auth.uid() or public.is_super_admin());
create policy "cart items own" on public.cart_items for all using (exists(select 1 from public.carts c where c.id=cart_id and (c.user_id=auth.uid() or public.is_super_admin()))) with check (exists(select 1 from public.carts c where c.id=cart_id and (c.user_id=auth.uid() or public.is_super_admin())));
create policy "orders own or admin read" on public.orders for select using (user_id=auth.uid() or public.is_super_admin());
create policy "orders admin update" on public.orders for update using (public.is_super_admin()) with check (public.is_super_admin());
create policy "order items own or admin" on public.order_items for select using (exists(select 1 from public.orders o where o.id=order_id and (o.user_id=auth.uid() or public.is_super_admin())));
create policy "payments own or admin read" on public.payments for select using (user_id=auth.uid() or public.is_super_admin());
create policy "payments own insert" on public.payments for insert with check (user_id=auth.uid() and exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()));
create policy "payments admin update" on public.payments for update using (public.is_super_admin()) with check (public.is_super_admin());
create policy "coupons active read" on public.coupons for select using (is_active or public.is_super_admin());
create policy "coupons admin all" on public.coupons for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "coupon usages own read" on public.coupon_usages for select using (user_id=auth.uid() or public.is_super_admin());
create policy "banners public read" on public.banners for select using (is_active or public.is_super_admin());
create policy "banners admin all" on public.banners for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "reviews public approved" on public.reviews for select using (is_approved or user_id=auth.uid() or public.is_super_admin());
create policy "reviews customer insert" on public.reviews for insert with check (user_id=auth.uid() and exists(select 1 from public.orders o join public.order_items oi on oi.order_id=o.id where o.user_id=auth.uid() and o.status='completed' and oi.product_id=product_id));
create policy "reviews admin update" on public.reviews for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "settings public read" on public.store_settings for select using (true);
create policy "settings admin all" on public.store_settings for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "inventory admin only" on public.inventory_movements for all using (public.is_super_admin()) with check (public.is_super_admin());
create policy "history own or admin" on public.order_status_history for select using (exists(select 1 from public.orders o where o.id=order_id and (o.user_id=auth.uid() or public.is_super_admin())));
create policy "history admin insert" on public.order_status_history for insert with check (public.is_super_admin());
create policy "audit admin only" on public.audit_logs for all using (public.is_super_admin()) with check (public.is_super_admin());

-- Storage buckets and policies. Create buckets through Storage UI or CLI.
insert into storage.buckets(id,name,public) values
('products','products',true),('banners','banners',true),('categories','categories',true),('avatars','avatars',false),('payment-proofs','payment-proofs',false)
on conflict(id) do nothing;

create policy "public read product assets" on storage.objects for select using (bucket_id in ('products','banners','categories'));
create policy "admin manage public assets" on storage.objects for all using (bucket_id in ('products','banners','categories') and public.is_super_admin()) with check (bucket_id in ('products','banners','categories') and public.is_super_admin());
create policy "user upload own payment proof" on storage.objects for insert with check (bucket_id='payment-proofs' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "owner or admin read proof" on storage.objects for select using (bucket_id='payment-proofs' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_super_admin()));
create policy "admin manage proofs" on storage.objects for update using (bucket_id='payment-proofs' and public.is_super_admin()) with check (bucket_id='payment-proofs' and public.is_super_admin());

grant execute on function public.create_order(text,text,text,text,text,text,text,jsonb) to authenticated;
grant execute on function public.admin_review_payment(uuid,text,text) to authenticated;

insert into public.categories(name,slug,sort_order) values
('Sneakers','sneakers',1),('Running','running',2),('Casual','casual',3),('Men','men',4),('Women','women',5)
on conflict(slug) do nothing;
insert into public.store_settings(store_name, payment_instructions)
select 'LocalBrandShoes','Transfer sesuai nominal pesanan. Unggah bukti pembayaran untuk diverifikasi admin.'
where not exists(select 1 from public.store_settings);
