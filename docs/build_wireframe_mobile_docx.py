from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
import html


OUT = Path(__file__).resolve().parent / "wireframe-mobile-project.docx"


def esc(text: str) -> str:
    return html.escape(text, quote=False)


def run(
    text: str,
    size: int = 22,
    bold: bool = False,
    italic: bool = False,
    font: str = "Arial",
    color: str = "000000",
) -> str:
    props = [
        f'<w:rFonts w:ascii="{font}" w:hAnsi="{font}" w:cs="{font}"/>',
        f'<w:sz w:val="{size}"/>',
        f'<w:szCs w:val="{size}"/>',
        f'<w:color w:val="{color}"/>',
    ]
    if bold:
        props.insert(0, "<w:b/>")
    if italic:
        props.insert(0, "<w:i/>")
    lines = text.split("\n")
    parts = [f"<w:t xml:space=\"preserve\">{esc(lines[0])}</w:t>"]
    for line in lines[1:]:
        parts.append("<w:br/>")
        parts.append(f"<w:t xml:space=\"preserve\">{esc(line)}</w:t>")
    return f"<w:r><w:rPr>{''.join(props)}</w:rPr>{''.join(parts)}</w:r>"


def p(
    text: str = "",
    style: str | None = None,
    runs: list[str] | None = None,
    jc: str | None = None,
    before: int = 0,
    after: int = 140,
    line: int = 276,
    keep_next: bool = False,
) -> str:
    ppr = []
    if style:
        ppr.append(f'<w:pStyle w:val="{style}"/>')
    if jc:
        ppr.append(f'<w:jc w:val="{jc}"/>')
    if keep_next:
        ppr.append("<w:keepNext/>")
    ppr.append(f'<w:spacing w:before="{before}" w:after="{after}" w:line="{line}" w:lineRule="auto"/>')
    content = "".join(runs) if runs is not None else run(text)
    return f"<w:p><w:pPr>{''.join(ppr)}</w:pPr>{content}</w:p>"


def heading(text: str, level: int = 1) -> str:
    if level == 1:
        return p(text, style="Heading1", keep_next=True, before=180, after=120)
    if level == 2:
        return p(text, style="Heading2", keep_next=True, before=140, after=90)
    return p(text, style="Heading3", keep_next=True, before=100, after=70)


def bullet(text: str) -> str:
    return p(runs=[run("- ", 22), run(text, 22)], after=70)


def numbered(n: int, text: str) -> str:
    return p(runs=[run(f"{n}. ", 22), run(text, 22)], after=70)


def ascii_block(text: str) -> str:
    return p(
        runs=[run(text.strip("\n"), size=17, font="Courier New", color="202020")],
        before=60,
        after=180,
        line=220,
    )


def page_break() -> str:
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'


def table(rows: list[list[str]], widths: list[int]) -> str:
    grid = "".join(f'<w:gridCol w:w="{w}"/>' for w in widths)
    body = []
    for r_idx, row in enumerate(rows):
        cells = []
        for c_idx, cell in enumerate(row):
            fill = "EDEDED" if r_idx == 0 else "FFFFFF"
            cells.append(
                f"""
<w:tc>
  <w:tcPr>
    <w:tcW w:w="{widths[c_idx]}" w:type="dxa"/>
    <w:shd w:fill="{fill}"/>
    <w:tcMar><w:top w:w="90" w:type="dxa"/><w:left w:w="110" w:type="dxa"/><w:bottom w:w="90" w:type="dxa"/><w:right w:w="110" w:type="dxa"/></w:tcMar>
  </w:tcPr>
  {p(runs=[run(cell, 18 if r_idx == 0 else 17, bold=(r_idx == 0))], after=0, line=230)}
</w:tc>"""
            )
        body.append(f"<w:tr>{''.join(cells)}</w:tr>")
    return f"""
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="{sum(widths)}" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="6" w:color="B8B8B8"/>
      <w:left w:val="single" w:sz="6" w:color="B8B8B8"/>
      <w:bottom w:val="single" w:sz="6" w:color="B8B8B8"/>
      <w:right w:val="single" w:sz="6" w:color="B8B8B8"/>
      <w:insideH w:val="single" w:sz="4" w:color="D6D6D6"/>
      <w:insideV w:val="single" w:sz="4" w:color="D6D6D6"/>
    </w:tblBorders>
  </w:tblPr>
  <w:tblGrid>{grid}</w:tblGrid>
  {''.join(body)}
</w:tbl>"""


PAGES = [
    {
        "name": "Splash Screen",
        "purpose": "Menampilkan identitas aplikasi, status inisialisasi, dan menentukan tujuan navigasi berdasarkan status login.",
        "elements": "Logo aplikasi, nama Tobaku Sulastri, tagline, loading indicator, status koneksi, versi aplikasi.",
        "nav": "Jika sesi aktif menuju Dashboard, jika belum login menuju Login.",
        "notes": "Gunakan komposisi vertikal tengah, status singkat, dan durasi loading yang tidak terlalu lama.",
        "wire": """
+--------------------------------+
|                                |
|           [ APP LOGO ]         |
|                                |
|        Tobaku Sulastri         |
|         Toko Bahan Kue         |
|   Smart Inventory Management   |
|                                |
|           .   .   .            |
|                                |
|   Menghubungkan ke server...   |
|          Version 1.0.0         |
+--------------------------------+
""",
    },
    {
        "name": "Login",
        "purpose": "Memvalidasi akun admin sebelum mengakses fitur pengelolaan stok dan prediksi.",
        "elements": "Logo, judul selamat datang, input email/username, input password, tombol visibility password, lupa password, tombol masuk.",
        "nav": "Login berhasil menuju Dashboard. Lupa Password membuka dialog OTP.",
        "notes": "Form dibuat satu kolom agar nyaman di layar kecil. Error login ditampilkan melalui snackbar.",
        "wire": """
+--------------------------------+
|                                |
|           [ ICON ]             |
|        Selamat Datang          |
|       Masuk ke akun Anda       |
|                                |
| Email / Username               |
| +----------------------------+ |
| | Masukkan email/username    | |
| +----------------------------+ |
| Password                       |
| +----------------------------+ |
| | ********              [eye]| |
| +----------------------------+ |
|                 Lupa Password? |
| +----------------------------+ |
| |           MASUK            | |
| +----------------------------+ |
|                                |
+--------------------------------+
""",
    },
    {
        "name": "Reset Password / OTP",
        "purpose": "Membantu pengguna membuat password baru melalui verifikasi kode OTP.",
        "elements": "Field akun, tombol kirim OTP, field OTP, field password baru, tombol batal, tombol reset.",
        "nav": "Reset berhasil kembali ke Login atau menutup dialog jika dibuka dari Pengaturan.",
        "notes": "Gunakan dialog/bottom sheet agar tidak memutus konteks halaman sebelumnya.",
        "wire": """
+--------------------------------+
| Reset Password              X  |
|                                |
| Email / Username               |
| +----------------------------+ |
| | akun pengguna              | |
| +----------------------------+ |
| +----------------------------+ |
| |         KIRIM OTP          | |
| +----------------------------+ |
| Kode OTP                       |
| +----------------------------+ |
| | 6 digit OTP                | |
| +----------------------------+ |
| Password Baru                  |
| +----------------------------+ |
| | Password baru              | |
| +----------------------------+ |
| [ Batal ]        [ Reset ]     |
+--------------------------------+
""",
    },
    {
        "name": "Dashboard / Home",
        "purpose": "Memberi ringkasan cepat kondisi stok, pemakaian bahan, dan peringatan bahan kritis.",
        "elements": "Header admin, notifikasi stok menipis, kartu bahan digunakan hari ini, kartu total produk, grafik penggunaan bahan, daftar stok menipis, tombol prediksi, tombol tambah stok, bottom navigation.",
        "nav": "Menu bawah menuju Produk, Stok Masuk, Prediksi, Laporan, Pengaturan.",
        "notes": "Prioritaskan informasi yang perlu tindakan: stok menipis dan akses cepat ke prediksi/stok masuk.",
        "wire": """
+--------------------------------+
| Selamat Datang          [ ! ]  |
| Admin Sulastri                 |
| +-------------+ +------------+ |
| | Bahan Hari | | Produk     | |
| | 24 kg      | | 8 Aktif    | |
| +-------------+ +------------+ |
|                                |
| Penggunaan Bahan               |
| Tepung   [===========-----]    |
| Telur    [=========-------]    |
| Gula     [======----------]    |
|                                |
| Stok Menipis                   |
| +----------------------------+ |
| | Gula Pasir 2 kg   Kritis   | |
| +----------------------------+ |
| [ Lihat Prediksi ][Tambah Stok]|
|--------------------------------|
| Home Produk Stok Pred Laporan  |
+--------------------------------+
""",
    },
    {
        "name": "Data Produk",
        "purpose": "Menampilkan seluruh bahan/barang beserta kategori, harga, stok, status, dan kapasitas.",
        "elements": "Header, jumlah produk, search field, filter chip, kartu produk, badge status, progress kapasitas, tombol info.",
        "nav": "Tap kartu/info membuka Detail Produk. Bottom navigation menuju menu lain.",
        "notes": "Filter status penting untuk mobile karena admin perlu cepat menemukan stok kritis.",
        "wire": """
+--------------------------------+
| <  Data Produk                 |
|    8 Produk                    |
| +----------------------------+ |
| | Cari produk...           Q | |
| +----------------------------+ |
| [Semua][Tersedia][Sedang]     |
|                                |
| +----------------------------+ |
| | [ ] Tepung Terigu    Aman  | |
| |     Bahan | Rp 12.000      | |
| | Stok 20 kg                 | |
| | Kapasitas [==========--] i | |
| +----------------------------+ |
| +----------------------------+ |
| | [ ] Gula Pasir     Kritis | |
| | Stok 2 kg [==----------] i | |
| +----------------------------+ |
|--------------------------------|
| Home Produk Stok Pred Laporan  |
+--------------------------------+
""",
    },
    {
        "name": "Detail Produk",
        "purpose": "Menampilkan informasi lengkap satu produk/bahan dan rekomendasi tindakan berdasarkan status stok.",
        "elements": "Nama produk, ID, badge status, grid informasi kategori/harga/stok/minimum/satuan/kapasitas, progress kapasitas, rekomendasi stok, tombol tutup, tombol tambah stok.",
        "nav": "Tutup kembali ke Data Produk. Tambah Stok menuju Stok Masuk.",
        "notes": "Pada mobile cocok sebagai bottom sheet agar pengguna tetap merasa berada di daftar produk.",
        "wire": """
+--------------------------------+
| Detail Produk                  |
| +----------------------------+ |
| | [ ] Tepung Terigu    Aman  | |
| |     ID Produk: 001         | |
| +----------------------------+ |
| [Kategori] Bahan  [Harga] Rp  |
| [Stok] 20 kg     [Min] 5 kg   |
| [Satuan] kg      [Kapas] 80%  |
|                                |
| Kapasitas stok            80%  |
| [====================----]     |
|                                |
| Stok aman untuk produksi.      |
|                                |
| [ Tutup ]      [ Tambah Stok ] |
+--------------------------------+
""",
    },
    {
        "name": "Stok Masuk",
        "purpose": "Mencatat penambahan stok bahan/barang dan memperbarui stok di database.",
        "elements": "Dropdown produk, input jumlah, harga satuan otomatis/terisi, tombol tambah ke keranjang, daftar keranjang, kontrol qty, hapus item, total pembayaran, tanggal, tombol simpan, riwayat stok masuk.",
        "nav": "Tambah Produk membuka dialog tambah produk. Simpan sukses tetap di halaman dan memperbarui riwayat.",
        "notes": "Keranjang membantu input beberapa bahan sekaligus tanpa berpindah halaman.",
        "wire": """
+--------------------------------+
| <  Stok Masuk                  |
| Form Stok Masuk                |
| Produk                         |
| +----------------------------+ |
| | Pilih produk             v | |
| +----------------------------+ |
| Jumlah                         |
| +----------------------------+ |
| | 0                          | |
| +----------------------------+ |
| +----------------------------+ |
| |     TAMBAH KE KERANJANG    | |
| +----------------------------+ |
| Keranjang                      |
| | Produk A  [-] 2 [+]  Del   | |
| Total Pembayaran      Rp xxx   |
| Tanggal              [calendar]|
| +----------------------------+ |
| |      SIMPAN STOK MASUK     | |
| +----------------------------+ |
| Riwayat Stok Masuk             |
|--------------------------------|
| Home Produk Stok Pred Laporan  |
+--------------------------------+
""",
    },
    {
        "name": "Tambah Produk Baru",
        "purpose": "Menambahkan produk/bahan baru yang belum tersedia dalam daftar.",
        "elements": "Nama produk, jenis kategori, satuan, harga, stok awal, stok minimum, tombol batal, tombol simpan.",
        "nav": "Simpan berhasil menambahkan produk ke pilihan Stok Masuk.",
        "notes": "Gunakan validasi langsung untuk harga, stok awal, dan stok minimum agar kesalahan input cepat diketahui.",
        "wire": """
+--------------------------------+
| Tambah Produk Baru             |
| Nama Produk                    |
| +----------------------------+ |
| | Masukkan nama produk       | |
| +----------------------------+ |
| Jenis Kategori           [v]   |
| Satuan                   [v]   |
| Harga                         |
| +----------------------------+ |
| | Rp                         | |
| +----------------------------+ |
| Stok Awal                     |
| +----------------------------+ |
| | 0                          | |
| +----------------------------+ |
| Stok Minimum                  |
| +----------------------------+ |
| | 0                          | |
| +----------------------------+ |
| [ Batal ]       [ Simpan ]     |
+--------------------------------+
""",
    },
    {
        "name": "Prediksi Kebutuhan Bahan",
        "purpose": "Menghitung kebutuhan bahan berdasarkan resep dan jumlah produksi, lalu memeriksa kecukupan stok.",
        "elements": "Header, info kalkulasi otomatis, dropdown produk/resep, input jumlah produksi, tombol hitung, daftar bahan, checkbox bahan, kebutuhan, stok tersedia, status cukup/kurang, ringkasan pengurangan stok, rekomendasi tambah stok, tombol submit produksi.",
        "nav": "Submit sukses membuka dialog produksi berhasil. Jika stok kurang, pengguna diarahkan menambah stok.",
        "notes": "Ini halaman inti sistem pakar; hasil kalkulasi dan rekomendasi harus terlihat tanpa banyak scroll.",
        "wire": """
+--------------------------------+
| <  Prediksi Kebutuhan Bahan    |
| Kalkulasi berdasarkan produksi |
| +----------------------------+ |
| | [Calc] Kalkulasi Otomatis  | |
| +----------------------------+ |
| Rencana Produksi               |
| Produk                    [v]  |
| Jumlah Produksi                |
| +----------------------------+ |
| | 0                          | |
| +----------------------------+ |
| +----------------------------+ |
| |       HITUNG BAHAN         | |
| +----------------------------+ |
| Kebutuhan Bahan                |
| | Bahan | Butuh | Stok | Stat | |
| | Tepung| 3 kg  |10 kg |Cukup | |
| | Telur | 2 kg  |1 kg  |Kurang| |
| Ringkasan Pengurangan Stok     |
| Rekomendasi: Telur +1 kg       |
| +----------------------------+ |
| |       SUBMIT PRODUKSI      | |
| +----------------------------+ |
|--------------------------------|
| Home Produk Stok Pred Laporan  |
+--------------------------------+
""",
    },
    {
        "name": "Produksi Berhasil",
        "purpose": "Memberi konfirmasi bahwa produksi tersimpan dan stok bahan telah diperbarui.",
        "elements": "Icon sukses, judul, pesan singkat, tombol sukses.",
        "nav": "Menutup dialog dan kembali ke halaman Prediksi dengan form reset.",
        "notes": "Gunakan dialog sederhana agar pengguna memahami aksi sudah selesai.",
        "wire": """
+--------------------------------+
|                                |
|             [ OK ]             |
|                                |
|       Produksi Berhasil        |
| Stok bahan sudah diperbarui    |
| sesuai produksi.               |
|                                |
| +----------------------------+ |
| |           SUKSES           | |
| +----------------------------+ |
+--------------------------------+
""",
    },
    {
        "name": "Laporan & Analitik",
        "purpose": "Menampilkan rekap stok, riwayat stok masuk, prediksi, grafik penggunaan, bahan kritis, dan export laporan.",
        "elements": "Kartu total produk, total bahan, stok kritis, total prediksi, daftar stok bahan, riwayat stok masuk, daftar prediksi, grafik, bahan kritis, tombol export CSV/PDF.",
        "nav": "Export membuka pilihan periode dan format. Bottom navigation menuju menu lain.",
        "notes": "Konten laporan panjang, jadi section perlu heading jelas dan tinggi list dibatasi agar mudah discroll.",
        "wire": """
+--------------------------------+
| Laporan & Analitik             |
| +-------------+ +------------+ |
| | Total Prod  | | Total Bhn  | |
| | 8           | | 6          | |
| +-------------+ +------------+ |
| | Stok Kritis | | Prediksi   | |
| | 2           | | 10         | |
| +-------------+ +------------+ |
| Laporan Stok Bahan             |
| | Nama | Stok | Status        | |
| Riwayat Stok Masuk             |
| | Bahan | Tgl | +Jumlah       | |
| Laporan Prediksi               |
| | Produk | Tgl | Prediksi     | |
| Grafik Penggunaan Bahan        |
| [Bar Chart] [Pie Chart]        |
| [ Export CSV ] [ Export PDF ]  |
|--------------------------------|
| Home Produk Stok Pred Laporan  |
+--------------------------------+
""",
    },
    {
        "name": "Export Laporan",
        "purpose": "Memilih periode dan format export laporan.",
        "elements": "Dialog periode harian/2 mingguan/bulanan, dialog format CSV/PDF, snackbar hasil export, aksi buka/share file.",
        "nav": "Setelah export selesai tetap di halaman Laporan.",
        "notes": "Gunakan dialog bertahap agar pilihan tidak memenuhi layar kecil.",
        "wire": """
+--------------------------------+
| Pilih Periode Export           |
| +----------------------------+ |
| | Harian                     | |
| | 2 Mingguan                 | |
| | Bulanan                    | |
| +----------------------------+ |
|                                |
| Pilih Format Export            |
| +----------------------------+ |
| | CSV                        | |
| | PDF                        | |
| +----------------------------+ |
|                                |
| Snackbar: Laporan diekspor     |
| [ Buka ] [ Share ]             |
+--------------------------------+
""",
    },
    {
        "name": "Pengaturan / Profil",
        "purpose": "Menampilkan informasi akun, akses perubahan password, informasi aplikasi, dan logout.",
        "elements": "Kartu akun, nama, email, menu ubah password, tombol logout, info versi aplikasi.",
        "nav": "Ubah password membuka dialog OTP. Logout membuka dialog konfirmasi lalu kembali ke Login.",
        "notes": "Profil dan keamanan dipisahkan agar hierarki informasi jelas.",
        "wire": """
+--------------------------------+
| Pengaturan                     |
| Akun                           |
| +----------------------------+ |
| | [Avatar] Ibu Sulastri      | |
| | sulastri...@gmail.com      | |
| +----------------------------+ |
| Keamanan                       |
| +----------------------------+ |
| | [Lock] Ubah Password   >   | |
| +----------------------------+ |
| +----------------------------+ |
| |           LOGOUT           | |
| +----------------------------+ |
| Tobaku Sulastri                |
| Version 1.0.0                  |
|--------------------------------|
| Home Produk Stok Pred Laporan  |
+--------------------------------+
""",
    },
    {
        "name": "Logout Confirmation",
        "purpose": "Mencegah pengguna keluar tanpa sengaja.",
        "elements": "Judul logout, pesan konfirmasi, tombol batal, tombol logout.",
        "nav": "Batal menutup dialog. Logout membersihkan sesi dan menuju Login.",
        "notes": "Tombol logout diberi warna bahaya agar konsekuensi aksi jelas.",
        "wire": """
+--------------------------------+
| Logout                         |
| Apakah Anda yakin ingin keluar |
| dari aplikasi?                 |
|                                |
| [ Batal ]        [ Logout ]    |
+--------------------------------+
""",
    },
    {
        "name": "State Loading / Empty / Error",
        "purpose": "Memberi respons visual saat data sedang dimuat, kosong, atau gagal diambil dari server.",
        "elements": "Circular progress, pesan kosong, icon error, tombol coba lagi, snackbar error.",
        "nav": "Coba Lagi memuat ulang data. Empty state tetap di halaman terkait.",
        "notes": "State ini penting karena aplikasi bergantung pada API Flask dan data MySQL.",
        "wire": """
+--------------------------------+
| Loading                        |
|           [ spinner ]          |
|        Memuat data...          |
|--------------------------------|
| Empty                          |
|           [ icon ]             |
|      Data belum tersedia       |
|--------------------------------|
| Error                          |
|           [ ! ]                |
|      Gagal memuat data         |
|        [ Coba Lagi ]           |
+--------------------------------+
""",
    },
]


def build_document() -> str:
    body: list[str] = []
    body.append(p("Wireframe Mobile Project", style="Title", jc="center", after=60))
    body.append(p("Aplikasi Sistem Prediksi dan Pengelolaan Stok Bahan Kue Tobaku Sulastri", style="Subtitle", jc="center", after=420))

    body.append(heading("Ringkasan Aplikasi", 1))
    body.append(
        p(
            "Aplikasi Tobaku Sulastri adalah aplikasi mobile berbasis Flutter untuk membantu admin toko bahan kue dalam memantau stok, mencatat stok masuk, menghitung kebutuhan bahan berdasarkan rencana produksi, dan membuat laporan stok serta prediksi. Aplikasi terhubung ke API Flask dan menyimpan sesi login menggunakan SharedPreferences."
        )
    )

    body.append(heading("Analisis Kebutuhan Berdasarkan Repository", 1))
    analysis_rows = [
        ["Area", "Temuan dari Project", "Kebutuhan Wireframe"],
        ["Autentikasi", "Splash mengecek sesi login; Login memakai email/username dan password; OTP tersedia untuk reset password.", "Splash, Login, Reset Password/OTP, Logout."],
        ["Navigasi", "Route utama: splash, login, dashboard, prediction, transaction, products, reports, settings.", "Bottom navigation mobile dengan menu Dashboard, Produk, Stok Masuk, Prediksi, Laporan, Pengaturan."],
        ["Produk/Stok", "Product model memuat nama, kategori, harga, stok, stok minimum, satuan, status.", "Daftar produk, filter status, detail produk, rekomendasi tambah stok."],
        ["Stok Masuk", "TransactionController memakai dropdown produk, jumlah, keranjang, tanggal, dan submit transaksi.", "Form stok masuk, keranjang, total pembayaran, riwayat stok masuk."],
        ["Prediksi", "PredictionController mengambil resep, menghitung bahan, cek stok cukup/kurang, submit produksi, simpan prediksi.", "Halaman sistem pakar/prediksi dengan hasil bahan, status, rekomendasi, dan submit produksi."],
        ["Laporan", "ReportController memuat stok, stok masuk, prediksi, bahan kritis, grafik, export CSV/PDF.", "Halaman laporan panjang dengan ringkasan, list, chart, export."],
        ["Pengaturan", "Settings menampilkan akun, ubah password OTP, logout, info aplikasi.", "Profil/pengaturan dan dialog konfirmasi logout."],
    ]
    body.append(table(analysis_rows, [1700, 3900, 3760]))

    body.append(heading("Asumsi Perancangan", 1))
    assumptions = [
        "Tidak ditemukan halaman Register pada route aplikasi, sehingga dokumen hanya memasukkan Login dan Reset Password/OTP.",
        "Aplikasi digunakan oleh admin/pemilik toko, bukan pelanggan umum.",
        "Prediksi yang dimaksud pada UI saat ini berfokus pada kalkulasi kebutuhan bahan berdasarkan resep dan jumlah produksi.",
        "Halaman profil digabung dengan Pengaturan karena struktur project hanya memiliki SettingsScreen.",
        "Semua rancangan difokuskan pada layar mobile portrait dengan navigasi bawah.",
    ]
    for item in assumptions:
        body.append(bullet(item))

    body.append(heading("Daftar Halaman", 1))
    page_rows = [["No", "Halaman", "Fungsi Utama"]]
    for idx, item in enumerate(PAGES, start=1):
        page_rows.append([str(idx), item["name"], item["purpose"]])
    body.append(table(page_rows, [700, 2600, 6060]))

    body.append(page_break())
    body.append(heading("User Flow Dari Awal Hingga Akhir", 1))
    flows = [
        "Pengguna membuka aplikasi dan melihat Splash Screen.",
        "Sistem mengecek sesi login yang tersimpan.",
        "Jika belum login, pengguna diarahkan ke Login.",
        "Pengguna memasukkan email/username dan password.",
        "Jika login berhasil, pengguna masuk ke Dashboard.",
        "Dari Dashboard, pengguna dapat memantau bahan digunakan hari ini, produk aktif, penggunaan bahan, dan stok menipis.",
        "Pengguna membuka Data Produk untuk melihat detail stok dan status bahan.",
        "Jika stok kurang, pengguna dapat membuka Stok Masuk untuk menambah stok bahan.",
        "Pengguna membuka Prediksi Kebutuhan Bahan, memilih produk/resep, mengisi jumlah produksi, lalu menghitung kebutuhan bahan.",
        "Sistem menampilkan kebutuhan bahan, status cukup/kurang, dan rekomendasi penambahan stok.",
        "Jika stok cukup, pengguna submit produksi dan sistem mengurangi stok bahan.",
        "Pengguna melihat Laporan & Analitik untuk mengecek rekap stok, prediksi, grafik, bahan kritis, dan export CSV/PDF.",
        "Pengguna dapat membuka Pengaturan untuk melihat akun, mengubah password, atau logout.",
    ]
    for idx, item in enumerate(flows, start=1):
        body.append(numbered(idx, item))

    body.append(ascii_block("""
Splash
  |
  +-- Sesi aktif ----> Dashboard
  |
  +-- Belum login --> Login -- berhasil --> Dashboard
                         |
                         +-- Lupa Password --> OTP Reset

Dashboard
  |
  +-- Produk ----> Detail Produk ----> Tambah Stok
  |
  +-- Stok Masuk ----> Keranjang ----> Simpan Stok
  |
  +-- Prediksi ----> Hitung Bahan ----> Submit Produksi ----> Sukses
  |
  +-- Laporan ----> Export CSV/PDF
  |
  +-- Pengaturan ----> Ubah Password / Logout
"""))

    body.append(page_break())
    body.append(heading("Wireframe Mobile Per Halaman", 1))
    for idx, item in enumerate(PAGES, start=1):
        body.append(heading(f"{idx}. {item['name']}", 2))
        body.append(p(runs=[run("Tujuan: ", bold=True), run(item["purpose"])]))
        body.append(p(runs=[run("Elemen UI: ", bold=True), run(item["elements"])]))
        body.append(p(runs=[run("Navigasi: ", bold=True), run(item["nav"])]))
        body.append(p(runs=[run("Catatan desain mobile: ", bold=True), run(item["notes"])]))
        body.append(ascii_block(item["wire"]))
        if idx in {3, 6, 10, 13}:
            body.append(page_break())

    body.append(page_break())
    body.append(heading("Penjelasan Komponen UI Utama", 1))
    component_rows = [
        ["Komponen", "Fungsi", "Catatan Mobile"],
        ["Bottom Navigation", "Akses cepat ke enam halaman utama.", "Label harus singkat; gunakan ikon konsisten."],
        ["Header", "Menampilkan konteks halaman dan tombol kembali jika bukan dashboard.", "Jaga tinggi header agar konten utama tetap terlihat."],
        ["Search dan Filter Chip", "Mempercepat pencarian produk berdasarkan nama/status.", "Chip horizontal scroll cocok untuk layar kecil."],
        ["Card Produk", "Menampilkan informasi bahan secara ringkas.", "Gunakan badge status dan progress kapasitas."],
        ["Form Input", "Mengambil data login, stok masuk, produksi, dan produk baru.", "Validasi langsung dan keyboard numerik untuk angka."],
        ["Keranjang Stok Masuk", "Menampung beberapa stok masuk sebelum disimpan.", "Kontrol tambah/kurang harus mudah disentuh."],
        ["Tabel Kebutuhan Bahan", "Menampilkan bahan, kebutuhan, stok, dan status.", "Gunakan row/card jika tabel terlalu sempit."],
        ["Dialog/Bottom Sheet", "Digunakan untuk OTP, detail produk, tambah produk, sukses, logout.", "Tidak memenuhi layar penuh kecuali form panjang."],
        ["Snackbar", "Memberi feedback error/sukses singkat.", "Pesan harus pendek dan jelas."],
    ]
    body.append(table(component_rows, [2100, 3900, 3360]))

    body.append(heading("Catatan UX/UI", 1))
    ux_notes = [
        "Fokus utama aplikasi adalah efisiensi admin saat memantau stok dan menghitung kebutuhan bahan.",
        "Halaman Prediksi harus menjadi alur paling jelas karena berisi proses sistem pakar: pilih resep, input jumlah, hitung, cek stok, rekomendasi, submit.",
        "Gunakan warna status secara konsisten: hijau untuk cukup/aman, oranye untuk sedang/peringatan, merah untuk kritis/kurang.",
        "Semua tombol aksi utama perlu ukuran sentuh minimal sekitar 44 px agar nyaman di mobile.",
        "Data yang panjang seperti laporan sebaiknya dibagi menjadi section dengan heading dan list yang bisa discroll.",
        "Empty state dan error state wajib terlihat karena aplikasi bergantung pada koneksi API.",
    ]
    for item in ux_notes:
        body.append(bullet(item))

    body.append(heading("Rekomendasi Pengembangan Desain Berikutnya", 1))
    recs = [
        "Buat desain high-fidelity di Figma berdasarkan wireframe ini sebelum implementasi UI final.",
        "Pisahkan komponen reusable seperti AppHeader, StatCard, ProductCard, FormField, StatusBadge, dan EmptyState.",
        "Pertimbangkan tab atau collapsible section pada Laporan agar layar tidak terlalu panjang.",
        "Tambahkan indikator koneksi/server pada Splash atau Dashboard bila API Flask tidak aktif.",
        "Tambahkan konfirmasi sebelum submit produksi karena aksi tersebut mengurangi stok bahan.",
        "Untuk halaman Prediksi, pertimbangkan tampilan hasil berbentuk card per bahan agar lebih mudah dibaca di layar kecil.",
        "Lakukan pengujian mobile pada ukuran layar kecil agar bottom navigation enam item tetap terbaca.",
    ]
    for item in recs:
        body.append(bullet(item))

    sect = """
<w:sectPr>
  <w:pgSz w:w="12240" w:h="15840"/>
  <w:pgMar w:top="1080" w:right="1080" w:bottom="1080" w:left="1080" w:header="720" w:footer="720" w:gutter="0"/>
</w:sectPr>"""
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
 xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
 xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
 xmlns:v="urn:schemas-microsoft-com:vml"
 xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
 xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
 xmlns:w10="urn:schemas-microsoft-com:office:word"
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
 xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
 xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
 xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
 xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
 xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
 mc:Ignorable="w14 wp14">
 <w:body>{''.join(body)}{sect}</w:body>
</w:document>"""


def styles_xml() -> str:
    return """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="140" w:line="276" w:lineRule="auto"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="120"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:sz w:val="34"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle">
    <w:name w:val="Subtitle"/>
    <w:qFormat/>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:color w:val="666666"/><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="220" w:after="120"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:color w:val="5B4436"/><w:sz w:val="28"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="160" w:after="90"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:color w:val="111111"/><w:sz w:val="24"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:qFormat/>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:sz w:val="22"/></w:rPr>
  </w:style>
</w:styles>"""


def build_docx() -> None:
    content_types = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>"""
    root_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>"""
    document_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>"""
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    core = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:dcterms="http://purl.org/dc/terms/"
 xmlns:dcmitype="http://purl.org/dc/dcmitype/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Wireframe Mobile Project</dc:title>
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">{now}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{now}</dcterms:modified>
</cp:coreProperties>"""
    app = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
 xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Word</Application>
</Properties>"""
    if OUT.exists():
        OUT.unlink()
    with ZipFile(OUT, "w", ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", content_types)
        z.writestr("_rels/.rels", root_rels)
        z.writestr("word/document.xml", build_document())
        z.writestr("word/styles.xml", styles_xml())
        z.writestr("word/_rels/document.xml.rels", document_rels)
        z.writestr("docProps/core.xml", core)
        z.writestr("docProps/app.xml", app)
    print(OUT)


if __name__ == "__main__":
    build_docx()
