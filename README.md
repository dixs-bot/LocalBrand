# LocalBrandShoes

Starter fullstack e-commerce sepatu dengan Next.js App Router, TypeScript, Tailwind CSS, Supabase, dan dashboard Super Admin.

## Fitur dalam starter
- Homepage premium monochrome dan katalog.
- Halaman detail produk, pilihan variasi, cart, checkout.
- Supabase Auth login/register dan customer account.
- Alur order melalui RPC `create_order`.
- Upload bukti transfer ke bucket private.
- Dashboard Super Admin: ringkasan, produk, order, pembayaran, pengaturan rekening.
- Middleware proteksi `/admin` berdasarkan role `super_admin`.

## Jalankan lokal
1. Install Node.js 20+.
2. `npm install`
3. Salin `.env.example` menjadi `.env.local`.
4. Isi URL dan anon key Supabase.
5. Jalankan SQL `supabase/migrations/001_initial_schema.sql` di Supabase SQL Editor.
6. Buat bucket Storage `products`, `banners`, `categories`, `avatars` (public sesuai policy), dan `payment-proofs` (private).
7. Buat user melalui register. Jadikan user Super Admin melalui SQL aman di Supabase SQL Editor (lihat `SUPABASE_SETUP.md`).
8. `npm run dev`

## Perintah
- `npm run dev`
- `npm run typecheck`
- `npm run lint`
- `npm run build`

## Penting
Ini adalah fondasi implementasi yang perlu dikonfigurasi dan diuji pada project Supabase milik Anda sebelum menerima pembayaran/pesanan nyata. Transfer manual tetap memerlukan pemeriksaan manusia. Tambahkan aturan pengiriman, pajak/ongkir, kebijakan retur, dan pengujian keamanan sebelum production.
