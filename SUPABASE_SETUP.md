# Supabase setup

## 1. Project & environment
Buat project Supabase. Isi `.env.local` dengan Project URL, anon/public key, dan site URL. Jangan pernah expose service role key ke browser.

## 2. Database
Jalankan `supabase/migrations/001_initial_schema.sql` di SQL Editor.

## 3. Super Admin
1. Daftarkan akun melalui `/register`.
2. Ambil UUID user di Authentication > Users.
3. Jalankan SQL berikut dengan UUID yang benar-benar milik Anda:
   `insert into public.user_roles(user_id, role) values ('YOUR-USER-UUID', 'super_admin') on conflict (user_id) do update set role='super_admin';`
4. Logout dan login ulang, kemudian buka `/admin`.

Jangan pernah memberikan role ini kepada customer umum.

## 4. Storage
Buat bucket:
- `products` public
- `banners` public
- `categories` public
- `avatars` private (atau public jika memang diinginkan)
- `payment-proofs` private

Policy contoh untuk payment-proofs sudah ada di migration. Upload proof menggunakan path `{auth.uid()}/{order_id}/...`.

## 5. Konfigurasi rekening
Login sebagai Super Admin, buka `/admin/settings`, dan simpan rekening serta WhatsApp toko.

## 6. Catatan integrasi
- Checkout memakai RPC `create_order` yang memvalidasi variasi, harga dan stok.
- Verifikasi transfer memakai RPC `admin_review_payment`.
- Untuk production, review kembali expiry/reservasi stok, ongkir, pajak, refund, audit, dan prosedur fulfillment.
