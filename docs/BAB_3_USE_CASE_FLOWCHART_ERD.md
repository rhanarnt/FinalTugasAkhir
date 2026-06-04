# BAB III - Perancangan Sistem

## 3.1 Use Case Diagram
Use case diagram menggambarkan interaksi antara aktor dengan sistem aplikasi Tobaku Sulastri. Aktor utama pada aplikasi ini adalah Admin/Pemilik Toko, yaitu pengguna yang melakukan pengelolaan data bahan kue, pencatatan stok masuk, perhitungan kebutuhan produksi, prediksi permintaan, serta pemantauan laporan.

Use case yang terdapat pada sistem meliputi login, melihat dashboard, mengelola produk dan stok bahan, mencatat stok masuk, melakukan prediksi kebutuhan produksi, menghitung kebutuhan bahan berdasarkan resep, submit produksi dan update stok, melihat laporan, serta mengatur akun/password. Pada proses prediksi dan produksi, sistem mengambil data resep, menghitung kebutuhan bahan, mengecek ketersediaan stok, mengurangi stok apabila produksi disubmit, dan menyimpan riwayat prediksi atau pemakaian bahan.

Gambar 3.1 Use Case Diagram Aplikasi Prediksi dan Pengelolaan Stok Bahan Kue.

## 3.2 Flowchart Sistem
Flowchart sistem menjelaskan alur kerja aplikasi dari pengguna membuka aplikasi sampai proses selesai. Sistem dimulai dari splash screen, kemudian mengecek status sesi login. Jika sesi belum tersedia, pengguna harus memasukkan username/email dan password. Apabila validasi berhasil, pengguna diarahkan ke dashboard utama. Jika gagal, sistem menampilkan pesan kesalahan dan pengguna diminta login kembali.

Setelah masuk ke dashboard, pengguna dapat memilih menu produk/stok, transaksi stok masuk, prediksi/produksi, laporan, atau pengaturan. Pada menu produk/stok, pengguna dapat melihat, memfilter, dan menambahkan data bahan. Pada menu transaksi stok masuk, pengguna memilih bahan, mengisi jumlah, tanggal, dan menyimpan transaksi sehingga stok bertambah. Pada menu prediksi/produksi, pengguna memilih resep dan jumlah produksi, lalu sistem menghitung kebutuhan bahan dan mengecek stok. Jika stok cukup, sistem mengurangi stok, menyimpan riwayat penggunaan bahan, dan menyimpan hasil prediksi. Jika stok tidak cukup, pengguna diarahkan untuk memperbarui stok terlebih dahulu. Menu laporan menampilkan data stok, riwayat stok masuk, hasil prediksi, dan bahan kritis secara realtime dari database.

Gambar 3.2 Flowchart Sistem Aplikasi Tobaku Sulastri.

## 3.3 Entity Relationship Diagram (ERD)
ERD menggambarkan rancangan basis data yang digunakan oleh aplikasi. Tabel utama pada sistem adalah `products`, `transactions` atau `Stock In`, `predictions`, `recipes`, `recipe_ingredients`, `stock_usage_history`, `login`, dan `password_reset_otps`. Tabel `products` menyimpan data bahan kue seperti nama, kategori, satuan, harga, stok saat ini, dan stok minimum. Tabel `transactions` atau `Stock In` menyimpan riwayat stok masuk. Tabel `recipes` menyimpan data resep produk, sedangkan `recipe_ingredients` menyimpan daftar bahan dan jumlah kebutuhan untuk setiap resep.

Tabel `stock_usage_history` menyimpan riwayat pemakaian stok saat produksi disubmit. Tabel `predictions` atau `prediksi` menyimpan hasil prediksi jumlah produksi, estimasi kebutuhan bahan, tanggal prediksi, dan informasi akurasi model jika tersedia. Tabel `login` menyimpan data akun pengguna, sementara `password_reset_otps` menyimpan kode OTP untuk proses reset password. Relasi utama yang terbentuk adalah satu akun login dapat memiliki banyak OTP, satu resep memiliki banyak detail bahan, satu produk dapat muncul pada banyak riwayat stok masuk, riwayat pemakaian stok, dan hasil prediksi.

Gambar 3.3 Entity Relationship Diagram Database Aplikasi.

## Keterangan Diagram
- File sumber Draw.io Use Case: `docs/bab3_use_case.drawio`
- File gambar Use Case: `docs/bab3_use_case.svg`
- File sumber Draw.io Flowchart: `docs/bab3_flowchart_sistem.drawio`
- File gambar Flowchart: `docs/bab3_flowchart_sistem.svg`
- File sumber Draw.io ERD: `docs/bab3_erd.drawio`
- File gambar ERD: `docs/bab3_erd.svg`
