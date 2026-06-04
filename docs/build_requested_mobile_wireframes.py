from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import zipfile


ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT / "wireframe_mobile_requested"
COMBINED = ROOT / "wireframe-mobile-full.png"
ZIP_PATH = ROOT / "wireframe-mobile-screens.zip"

PHONE_W = 430
PHONE_H = 860
CANVAS_W = 520
CANVAS_H = 1010
MARGIN = 32

COLS = 3
ROWS = 5


def font(size: int, bold: bool = False, italic: bool = False) -> ImageFont.FreeTypeFont:
    names = []
    if bold and italic:
        names = ["arialbi.ttf", "Arial Bold Italic.ttf"]
    elif bold:
        names = ["arialbd.ttf", "Arial Bold.ttf"]
    elif italic:
        names = ["ariali.ttf", "Arial Italic.ttf"]
    else:
        names = ["arial.ttf", "Arial.ttf"]
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


F = {
    "title": font(23, True),
    "subtitle": font(16, True),
    "body": font(14),
    "small": font(12),
    "tiny": font(10),
    "button": font(14, True),
    "label": font(13, True),
}


class Screen:
    def __init__(self, title: str):
        self.title = title
        self.img = Image.new("RGB", (CANVAS_W, CANVAS_H), "white")
        self.d = ImageDraw.Draw(self.img)
        self.phone_x = (CANVAS_W - PHONE_W) // 2
        self.phone_y = 82
        self.d.text((CANVAS_W // 2, 36), title, font=F["title"], fill="#111111", anchor="mm")
        self.rounded(self.phone_x, self.phone_y, PHONE_W, PHONE_H, 36, "#ffffff", "#777777", 3)
        self.rounded(self.phone_x + 155, self.phone_y + 12, 120, 18, 9, "#eeeeee", "#bbbbbb", 1)
        self.x0 = self.phone_x + 28
        self.y0 = self.phone_y + 54
        self.w = PHONE_W - 56
        self.bottom_y = self.phone_y + PHONE_H - 86

    def rounded(self, x, y, w, h, r=10, fill="#f3f3f3", outline="#9a9a9a", width=2):
        self.d.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=fill, outline=outline, width=width)

    def rect(self, x, y, w, h, fill="#f3f3f3", outline="#9a9a9a", width=2):
        self.d.rectangle([x, y, x + w, y + h], fill=fill, outline=outline, width=width)

    def line(self, x1, y1, x2, y2, fill="#9a9a9a", width=2):
        self.d.line([x1, y1, x2, y2], fill=fill, width=width)

    def text(self, x, y, txt, style="body", fill="#111111", anchor="la", max_width=None):
        txt = str(txt)
        if max_width is None:
            self.d.text((x, y), txt, font=F[style], fill=fill, anchor=anchor)
            return
        words = txt.split()
        lines = []
        cur = ""
        for word in words:
            test = f"{cur} {word}".strip()
            if self.d.textlength(test, font=F[style]) <= max_width:
                cur = test
            else:
                if cur:
                    lines.append(cur)
                cur = word
        if cur:
            lines.append(cur)
        for i, line in enumerate(lines[:3]):
            self.d.text((x, y + i * 17), line, font=F[style], fill=fill, anchor=anchor)

    def header(self, title, sub=None, back=False):
        self.rounded(self.phone_x + 1, self.phone_y + 34, PHONE_W - 2, 92, 22, "#dedede", "#999999", 2)
        label = f"<  {title}" if back else title
        self.text(self.x0, self.phone_y + 78, label, "subtitle")
        if sub:
            self.text(self.x0, self.phone_y + 103, sub, "small", "#555555")

    def input(self, x, y, label, placeholder="", w=None, eye=False):
        w = w or self.w
        self.text(x, y, label, "label")
        self.rounded(x, y + 22, w, 44, 10, "#f7f7f7", "#999999", 2)
        self.text(x + 14, y + 51, placeholder, "small", "#666666", anchor="lm")
        if eye:
            self.text(x + w - 25, y + 51, "eye", "tiny", "#555555", anchor="mm")

    def button(self, x, y, label, w=None, dark=True):
        w = w or self.w
        fill = "#111111" if dark else "#f7f7f7"
        outline = "#111111" if dark else "#999999"
        text = "#ffffff" if dark else "#111111"
        self.rounded(x, y, w, 46, 12, fill, outline, 2)
        self.text(x + w / 2, y + 24, label, "button", text, anchor="mm")

    def card(self, x, y, w, h, title=None, sub=None, right=None):
        self.rounded(x, y, w, h, 14, "#f7f7f7", "#9a9a9a", 2)
        if title:
            self.text(x + 14, y + 18, title, "label", max_width=w - 28)
        if sub:
            self.text(x + 14, y + 42, sub, "small", "#555555", max_width=w - 28)
        if right:
            self.text(x + w - 14, y + 24, right, "small", "#111111", anchor="ra")

    def bottom_nav(self, active="Home"):
        y = self.phone_y + PHONE_H - 62
        labels = ["Home", "Produk", "Stok", "Pred", "Lapor"]
        item_w = self.w / len(labels)
        for i, label in enumerate(labels):
            x = self.x0 + i * item_w
            if label == active:
                self.rounded(x + 3, y, item_w - 6, 38, 8, "#111111", "#111111", 1)
                self.text(x + item_w / 2, y + 22, label, "tiny", "#ffffff", anchor="mm")
            else:
                self.text(x + item_w / 2, y + 22, label, "tiny", "#555555", anchor="mm")

    def plus(self, x, y):
        self.rounded(x, y, 46, 46, 23, "#111111", "#111111", 2)
        self.text(x + 23, y + 25, "+", "title", "#ffffff", anchor="mm")

    def save(self, filename: str):
        OUT_DIR.mkdir(exist_ok=True)
        path = OUT_DIR / filename
        self.img.save(path)
        return path


def splash():
    s = Screen("1. Splash Screen")
    x, y = s.x0, s.phone_y + 220
    s.rounded(x + 112, y, 150, 150, 28, "#e0e0e0", "#999999", 2)
    s.text(x + 187, y + 65, "IKON", "label", "#555555", anchor="mm")
    s.text(x + 187, y + 90, "BAHAN KUE", "tiny", "#555555", anchor="mm")
    s.text(x + 187, y + 205, "Prediksi Stok", "title", anchor="mm")
    s.text(x + 187, y + 235, "Bahan Kue", "title", anchor="mm")
    s.text(x + 187, y + 315, "Memuat aplikasi...", "small", "#555555", anchor="mm")
    s.text(x + 187, y + 350, ".  .  .", "subtitle", "#777777", anchor="mm")
    return s.save("01_splash_screen.png")


def login():
    s = Screen("2. Halaman Login")
    x, y = s.x0, s.y0 + 35
    s.rounded(x + 137, y, 100, 100, 22, "#dedede", "#999999", 2)
    s.text(x + 187, y + 53, "LOGO", "label", "#555555", anchor="mm")
    s.text(x + 187, y + 145, "Prediksi Stok Bahan Kue", "subtitle", anchor="mm")
    s.input(x, y + 190, "Email", "Masukkan email")
    s.input(x, y + 275, "Password", "Masukkan password", eye=True)
    s.button(x, y + 380, "Masuk / Login")
    s.text(x + s.w, y + 450, "Lupa Password", "small", "#555555", anchor="ra")
    s.text(x + 187, y + 500, "Belum punya akun? Daftar", "small", "#111111", anchor="mm")
    return s.save("02_login.png")


def register():
    s = Screen("3. Halaman Daftar / Register")
    s.header("Daftar Akun", "Buat akun baru", back=True)
    x, y = s.x0, s.phone_y + 165
    s.input(x, y, "Nama Pengguna", "Masukkan nama")
    s.input(x, y + 82, "Email", "Masukkan email")
    s.input(x, y + 164, "Password", "Masukkan password")
    s.input(x, y + 246, "Konfirmasi Password", "Ulangi password")
    s.button(x, y + 355, "Daftar")
    s.text(x + 187, y + 425, "Sudah punya akun? Login", "small", "#111111", anchor="mm")
    return s.save("03_register.png")


def dashboard():
    s = Screen("4. Halaman Dashboard")
    s.header("Prediksi Stok Bahan Kue", "Tobaku Sulastri")
    x, y = s.x0, s.phone_y + 150
    s.card(x, y, 176, 76, "Jumlah Bahan", "24 item")
    s.card(x + 198, y, 176, 76, "Stok Kritis", "3 bahan")
    s.card(x, y + 92, 374, 70, "Prediksi Terbaru", "Tepung: siapkan 12 kg", "RF")
    s.text(x, y + 195, "Menu Utama", "label")
    menus = [("Produk/Stok", "Bahan"), ("Stok Masuk", "Tambah"), ("Prediksi", "Kebutuhan"), ("Laporan", "Rekap")]
    for i, (a, b) in enumerate(menus):
        cx = x + (i % 2) * 198
        cy = y + 225 + (i // 2) * 98
        s.card(cx, cy, 176, 78, a, b)
    s.bottom_nav("Home")
    return s.save("04_dashboard.png")


def products():
    s = Screen("5. Data Produk / Stok Bahan")
    s.header("Data Produk / Stok", "Daftar bahan kue", back=True)
    x, y = s.x0, s.phone_y + 150
    items = [
        ("Tepung Terigu", "Bahan | Stok 20 kg | Min 5 kg"),
        ("Gula Pasir", "Bahan | Stok 2 kg | Min 5 kg"),
        ("Telur", "Bahan | Stok 10 kg | Min 3 kg"),
        ("Mentega", "Bahan | Stok 4 kg | Min 2 kg"),
    ]
    for i, (name, sub) in enumerate(items):
        s.card(x, y + i * 88, s.w, 74, name, sub)
        s.text(x + s.w - 70, y + i * 88 + 52, "Edit", "tiny", "#555555")
        s.text(x + s.w - 30, y + i * 88 + 52, "Hapus", "tiny", "#555555", anchor="ra")
    s.plus(s.phone_x + PHONE_W - 88, s.bottom_y - 16)
    s.bottom_nav("Produk")
    return s.save("05_data_produk_stok.png")


def product_form():
    s = Screen("6. Tambah / Edit Produk")
    s.header("Tambah / Edit Produk", "Input data bahan", back=True)
    x, y = s.x0, s.phone_y + 150
    s.input(x, y, "Nama Bahan", "Contoh: Tepung")
    s.input(x, y + 82, "Kategori", "Bahan / Barang")
    s.input(x, y + 164, "Jumlah Stok", "0")
    s.input(x, y + 246, "Satuan", "kg / pcs")
    s.input(x, y + 328, "Stok Minimum", "0")
    s.button(x, y + 435, "Simpan")
    return s.save("06_tambah_edit_produk.png")


def stock_in():
    s = Screen("7. Halaman Stok Masuk")
    s.header("Stok Masuk", "Riwayat penambahan stok", back=True)
    x, y = s.x0, s.phone_y + 150
    rows = [
        ("Tepung Terigu", "+10 kg | 01/06/2026", "Pembelian"),
        ("Gula Pasir", "+5 kg | 01/06/2026", "Restock"),
        ("Mentega", "+2 kg | 31/05/2026", "Supplier"),
        ("Telur", "+6 kg | 30/05/2026", "Pembelian"),
    ]
    for i, (a, b, c) in enumerate(rows):
        s.card(x, y + i * 88, s.w, 74, a, b)
        s.text(x + 14, y + i * 88 + 59, c, "tiny", "#777777")
    s.plus(s.phone_x + PHONE_W - 88, s.bottom_y - 16)
    s.bottom_nav("Stok")
    return s.save("07_stok_masuk.png")


def add_stock_in():
    s = Screen("8. Tambah Stok Masuk")
    s.header("Tambah Stok Masuk", "Stok bertambah otomatis", back=True)
    x, y = s.x0, s.phone_y + 150
    s.input(x, y, "Pilih Bahan", "Dropdown bahan")
    s.input(x, y + 82, "Jumlah Stok Masuk", "0")
    s.input(x, y + 164, "Tanggal", "Pilih tanggal")
    s.input(x, y + 246, "Keterangan", "Opsional")
    s.card(x, y + 335, s.w, 72, "Catatan", "Setelah disimpan, stok bahan bertambah otomatis.")
    s.button(x, y + 435, "Simpan")
    return s.save("08_tambah_stok_masuk.png")


def prediction():
    s = Screen("9. Prediksi Kebutuhan Bahan")
    s.header("Prediksi Kebutuhan", "Model utama: Random Forest", back=True)
    x, y = s.x0, s.phone_y + 150
    s.input(x, y, "Pilih Bahan / Produk", "Dropdown produk")
    s.input(x, y + 82, "Periode Prediksi", "Harian / Mingguan / Bulanan")
    s.input(x, y + 164, "Parameter Kebutuhan", "Jumlah produksi / input lain")
    s.card(x, y + 255, s.w, 76, "Model Prediksi", "Random Forest digunakan sebagai model utama.")
    s.button(x, y + 365, "Proses Prediksi")
    s.bottom_nav("Pred")
    return s.save("09_prediksi_kebutuhan.png")


def prediction_result():
    s = Screen("10. Hasil Prediksi")
    s.header("Hasil Prediksi", "Rekomendasi stok", back=True)
    x, y = s.x0, s.phone_y + 150
    s.card(x, y, s.w, 76, "Nama Bahan", "Tepung Terigu")
    s.card(x, y + 92, s.w, 78, "Hasil Prediksi", "Permintaan: 12 kg")
    s.card(x, y + 184, s.w, 78, "Rekomendasi", "Siapkan stok minimal 15 kg")
    s.card(x, y + 276, s.w, 70, "Status Stok", "Aman / Kritis")
    s.card(x, y + 360, s.w, 88, "Perbandingan Model", "Random Forest: 92% | Linear Regression: 78%")
    s.button(x, y + 475, "Simpan Hasil")
    s.button(x, y + 535, "Gunakan untuk Produksi", dark=False)
    s.text(x, y + 600, "Jika digunakan, stok bahan berkurang otomatis.", "tiny", "#555555")
    return s.save("10_hasil_prediksi.png")


def usage():
    s = Screen("11. Penggunaan Bahan")
    s.header("Penggunaan Bahan", "Pengurangan stok otomatis", back=True)
    x, y = s.x0, s.phone_y + 150
    rows = [
        ("Tepung Terigu", "Terpakai 3 kg | Sisa 17 kg"),
        ("Gula Pasir", "Terpakai 1 kg | Sisa 4 kg"),
        ("Telur", "Terpakai 2 kg | Sisa 8 kg"),
        ("Mentega", "Terpakai 0.5 kg | Sisa 3.5 kg"),
    ]
    for i, (a, b) in enumerate(rows):
        s.card(x, y + i * 88, s.w, 74, a, b)
        s.text(x + 14, y + i * 88 + 59, "Tanggal: 01/06/2026", "tiny", "#777777")
    s.card(x, y + 370, s.w, 64, "Info", "Stok bahan dikurangi otomatis saat produksi.")
    s.plus(s.phone_x + PHONE_W - 88, s.bottom_y - 16)
    return s.save("11_penggunaan_bahan.png")


def reports():
    s = Screen("12. Halaman Laporan")
    s.header("Laporan", "Rekap data sistem", back=True)
    x, y = s.x0, s.phone_y + 150
    cards = ["Laporan Stok Bahan", "Laporan Stok Masuk", "Laporan Penggunaan", "Laporan Hasil Prediksi"]
    for i, title in enumerate(cards):
        s.card(x, y + i * 76, s.w, 62, title, "Lihat detail")
    s.rounded(x, y + 330, s.w, 150, 14, "#f7f7f7", "#999999", 2)
    s.text(x + s.w / 2, y + 400, "Placeholder Grafik", "label", "#555555", anchor="mm")
    s.line(x + 35, y + 445, x + s.w - 35, y + 355, "#aaaaaa", 2)
    s.button(x, y + 515, "Export Laporan")
    s.bottom_nav("Lapor")
    return s.save("12_laporan.png")


def report_detail():
    s = Screen("13. Detail Laporan")
    s.header("Detail Laporan", "Data laporan terpilih", back=True)
    x, y = s.x0, s.phone_y + 150
    s.card(x, y, s.w, 78, "Ringkasan", "Total bahan: 24 | Kritis: 3")
    s.text(x, y + 110, "Tabel Data", "label")
    s.rounded(x, y + 135, s.w, 260, 12, "#f7f7f7", "#999999", 2)
    headers = ["Nama", "Jumlah", "Status"]
    for i, h in enumerate(headers):
        s.text(x + 18 + i * 118, y + 168, h, "label")
    for r in range(4):
        yy = y + 205 + r * 42
        s.line(x + 12, yy - 18, x + s.w - 12, yy - 18, "#d0d0d0", 1)
        s.text(x + 18, yy, f"Data {r+1}", "small", "#555555")
        s.text(x + 138, yy, "10 kg", "small", "#555555")
        s.text(x + 258, yy, "Aman", "small", "#555555")
    s.button(x, y + 440, "Export / Cetak Laporan")
    return s.save("13_detail_laporan.png")


def settings():
    s = Screen("14. Halaman Pengaturan")
    s.header("Pengaturan", "Menu aplikasi", back=True)
    x, y = s.x0, s.phone_y + 150
    rows = ["Profil Pengguna", "Pengaturan Akun", "Tentang Aplikasi", "Bantuan"]
    for i, row in enumerate(rows):
        s.card(x, y + i * 82, s.w, 64, row, "Buka menu", ">")
    s.button(x, y + 380, "Logout")
    s.bottom_nav("Home")
    return s.save("14_pengaturan.png")


def profile():
    s = Screen("15. Halaman Profil")
    s.header("Profil", "Informasi pengguna", back=True)
    x, y = s.x0, s.phone_y + 155
    s.rounded(x + 137, y, 100, 100, 50, "#dedede", "#999999", 2)
    s.text(x + 187, y + 55, "Avatar", "tiny", "#555555", anchor="mm")
    s.text(x + 187, y + 145, "Admin Sulastri", "subtitle", anchor="mm")
    s.text(x + 187, y + 174, "admin@sulastri.com", "small", "#555555", anchor="mm")
    s.card(x, y + 225, s.w, 72, "Nama Pengguna/Admin", "Admin Sulastri")
    s.card(x, y + 313, s.w, 72, "Email", "admin@sulastri.com")
    s.button(x, y + 420, "Edit Profil")
    s.button(x, y + 480, "Logout", dark=False)
    return s.save("15_profil.png")


BUILDERS = [
    splash,
    login,
    register,
    dashboard,
    products,
    product_form,
    stock_in,
    add_stock_in,
    prediction,
    prediction_result,
    usage,
    reports,
    report_detail,
    settings,
    profile,
]


def combine(paths: list[Path]):
    sheet_w = COLS * CANVAS_W + (COLS + 1) * MARGIN
    sheet_h = ROWS * CANVAS_H + (ROWS + 1) * MARGIN + 72
    sheet = Image.new("RGB", (sheet_w, sheet_h), "#f2f2f2")
    draw = ImageDraw.Draw(sheet)
    draw.text((sheet_w // 2, 45), "Wireframe Mobile Aplikasi Prediksi Stok Bahan Kue", font=font(30, True), fill="#111111", anchor="mm")
    for idx, path in enumerate(paths):
        img = Image.open(path)
        row = idx // COLS
        col = idx % COLS
        x = MARGIN + col * (CANVAS_W + MARGIN)
        y = 84 + MARGIN + row * (CANVAS_H + MARGIN)
        draw.rounded_rectangle([x - 8, y - 8, x + CANVAS_W + 8, y + CANVAS_H + 8], radius=18, fill="#ffffff", outline="#d0d0d0", width=2)
        sheet.paste(img, (x, y))
    sheet.save(COMBINED)


def zip_outputs(paths: list[Path]):
    if ZIP_PATH.exists():
        ZIP_PATH.unlink()
    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as z:
        for path in paths:
            z.write(path, path.name)
        z.write(COMBINED, COMBINED.name)


def main():
    OUT_DIR.mkdir(exist_ok=True)
    for old in OUT_DIR.glob("*.png"):
        old.unlink()
    paths = [builder() for builder in BUILDERS]
    combine(paths)
    zip_outputs(paths)
    print(f"Combined wireframe: {COMBINED}")
    print(f"Individual screens: {OUT_DIR}")
    print(f"ZIP: {ZIP_PATH}")


if __name__ == "__main__":
    main()
