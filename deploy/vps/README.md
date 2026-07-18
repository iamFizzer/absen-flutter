# Deployment VPS Testing

Target: Ubuntu 24.04, `202.155.94.237`, dan `api.mpizz.my.id`.

Endpoint HTTPS testing aktif di `https://202-155-94-237.sslip.io`. Endpoint ini digunakan hingga DNS `api.mpizz.my.id` diarahkan ke VPS.

Stack backend terdiri dari Django/DeepFace, PostgreSQL 16, volume media persisten, dan Nginx. VPS RAM 1 GB menggunakan swap 4 GB dan hanya satu Gunicorn worker.

File `.env` production disimpan hanya di `/opt/absensi/deploy/vps/.env` pada VPS dan tidak boleh masuk Git.
