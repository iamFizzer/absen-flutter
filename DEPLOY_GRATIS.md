# Deployment Gratis Tanpa Menjalankan Local

Arsitektur yang dipakai:

- Flutter Web: Firebase Hosting (gratis sampai kuota Spark).
- Django + DeepFace: Hugging Face Docker Space, CPU Basic gratis.
- PostgreSQL: Supabase Free.
- Foto wajah/selfie: Cloudinary Free.
- Build dan deployment: GitHub Actions.

## 1. Buat layanan

1. Buat project Supabase Free dan salin **Session pooler connection string**. Gunakan port pooler yang ditampilkan Supabase.
2. Buat akun Cloudinary Free dan salin `CLOUDINARY_URL` dari dashboard.
3. Buat Hugging Face Space baru dengan SDK **Docker** dan hardware **CPU Basic**.
4. Buat Hugging Face access token dengan izin tulis untuk Space.
5. Push repository ini ke GitHub. Firebase project sudah diarahkan ke `absensi-geo-fr-test`.

## 2. Isi Hugging Face Space

Di halaman Space, buka **Settings > Variables and secrets** lalu isi:

| Nama | Jenis | Nilai |
| --- | --- | --- |
| `DJANGO_SECRET_KEY` | Secret | String acak panjang |
| `DATABASE_URL` | Secret | Connection string Supabase |
| `CLOUDINARY_URL` | Secret | URL dari Cloudinary |
| `DJANGO_DEBUG` | Variable | `False` |
| `DJANGO_ALLOWED_HOSTS` | Variable | `.hf.space` |
| `CORS_ALLOW_ALL_ORIGINS` | Variable | `False` |
| `CORS_ALLOWED_ORIGINS` | Variable | `https://absensi-geo-fr-test.web.app,https://absensi-geo-fr-test.firebaseapp.com` |
| `CSRF_TRUSTED_ORIGINS` | Variable | Sama seperti CORS |
| `ATTENDANCE_ENFORCE_RADIUS` | Variable | `True` |

Jangan masukkan password asli ke `.env.example` atau commit GitHub.

## 3. Isi konfigurasi GitHub

Di repository GitHub buka **Settings > Secrets and variables > Actions**.

Variables:

- `HF_SPACE`: `iamfizzer/absensi-fr-api` (opsional karena sudah menjadi default workflow)
- `API_BASE_URL`: `https://iamfizzer-absensi-fr-api.hf.space/api/v1/` (opsional karena sudah menjadi default workflow)

Secrets:

- `HF_TOKEN`: token tulis Hugging Face
- `FIREBASE_SERVICE_ACCOUNT`: JSON service account Firebase utuh

Service account Firebase dapat dibuat dari **Firebase Console > Project settings > Service accounts**. Berikan akses hanya ke project ini.

## 4. Deploy

Buka tab **Actions**, pilih **Deploy gratis di cloud**, lalu jalankan **Run workflow**. Proses build Flutter dan image Python seluruhnya dilakukan oleh runner GitHub/Hugging Face.

Setelah selesai:

- Frontend: `https://absensi-geo-fr-test.web.app`
- Backend health: `https://iamfizzer-absensi-fr-api.hf.space/health/`

Untuk perubahan berikutnya cukup push ke branch `Maste`, `main`, atau `master`; deployment berjalan otomatis.

## Batas layanan gratis

Hugging Face Space dan Supabase dapat tidur setelah tidak aktif. Request pertama dapat lambat saat layanan bangun. Penyimpanan container Hugging Face tidak permanen, sehingga database harus tetap di Supabase dan media harus tetap di Cloudinary.
