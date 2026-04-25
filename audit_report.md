# Veltrik (Premium PDF Library) - Codebase Audit Report

Berikut adalah hasil audit mendalam terhadap source code Veltrik (Flutter & Supabase).

## 1. Rating Keseluruhan: 6.5 / 10

*   **Kebersihan Kode (7/10):** Kode cukup rapi, sudah memisahkan UI, Service, dan Model. File konstan (`constants.dart`) sudah digunakan dengan baik.
*   **Arsitektur (5/10):** Sangat *basic*. Aplikasi masih sangat bergantung pada `setState` bawaan Flutter. Logika bisnis (pemanggilan Supabase) dan UI sangat berbaur di dalam *StatefulWidgets* (seperti di `DashboardScreen`). Tidak ada arsitektur yang kuat seperti *Dependency Injection* atau *Repository Pattern*.
*   **Efisiensi (6/10):** Pemanggilan data dilakukan di dalam `initState` yang bisa memicu *rebuild* berulang yang tidak efisien saat berpindah layar. 

---

## 2. Analisis Keamanan (Security Check)

> [!CAUTION]
> **Kerentanan Kritis pada Logika Pembayaran & Role:**

*   **Client-Side Premium Upgrade:** Di dalam `SupabaseService.dart` method `approveTransaction`, aplikasi mengubah status `is_premium = true` dan `status = approved` **langsung dari sisi *client/app***. 
    *   **Bahaya:** Jika *Row Level Security* (RLS) di Supabase tidak di-setting super ketat, *hacker* bisa mendekompilasi aplikasi, mendapatkan *Anon Key*, dan mengirimkan *request update* manual untuk membuat akun mereka menjadi premium secara gratis.
    *   **Solusi:** Logika validasi *approve* HARUS dipindah ke *Backend* (Supabase Edge Functions atau Database Triggers). Aplikasi hanya me-request persetujuan, server yang meng-update database.
*   **Penggunaan `.env`:** Sudah bagus menggunakan `flutter_dotenv` untuk menyembunyikan `SUPABASE_URL` dan `SUPABASE_ANON_KEY`. Namun ingat, kunci anonim di *frontend* pada dasarnya adalah *public*. RLS adalah pelindung utamanya, bukan `.env`.
*   **Hardcoded Roles:** Penggunaan string seperti `'admin'`, `'user'`, `'pending'` rentan terhadap *typo* dan eksploitasi jika disuntikkan.

---

## 3. Daftar Perbaikan (Fixes & Bad Practices)

> [!WARNING]
> Segera *refactor* bagian ini sebelum *launching* ke produksi:

1.  ***Error Handling* yang Buruk (Silent Fails):**
    Di `getMaterials()`, jika error terjadi, kode hanya mencetak di *debug console* dan mengembalikan *list* kosong (`[]`). Pengguna tidak akan tahu jika ada masalah jaringan. Harus ada mekanisme pelemparan *exception* ke UI untuk menampilkan pesan *error* (misal: "Gagal memuat materi, coba lagi").
2.  **Pelemparan *String* sebagai *Exception*:**
    Di `getUserProfile()`, tertulis `throw "Sesi tidak ditemukan.";`. Ini *bad practice* di Dart. Gunakan `throw Exception('Sesi tidak ditemukan');` atau buat *custom exception class*.
3.  **Tightly Coupled Navigation:**
    *Routing* menggunakan `Navigator.pushReplacement` yang di-*hardcode* di mana-mana. Ini membuat aplikasi sulit diskalakan (misal untuk fitur *Deep Linking*).

---

## 4. Rekomendasi Upgrade (Level Production)

Untuk membuat aplikasi lebih ringan dan berstandar industri:

*   **State Management:** Ganti `setState` dengan **Riverpod** atau **Bloc**. Ini akan memisahkan logika Supabase dari UI, membuat UI tidak *lag* dan data bisa di-*cache* (tidak perlu *loading* ulang terus menerus saat buka *dashboard*).
*   **Routing System:** Gunakan **GoRouter**. Sangat penting untuk menangani *redirect* jika pengguna belum login, atau jika sesi Supabase kadaluarsa secara otomatis.
*   **UI/UX Skeleton Loading:** Ganti `CircularProgressIndicator` dengan animasi **Shimmer Loading** (package: `shimmer`). Ini membuat aplikasi terasa jauh lebih modern dan premium daripada sekadar ikon berputar.
*   **PDF Engine Upgrade:** Pastikan `syncfusion_flutter_pdfviewer` menggunakan *lazy loading* jika ukuran PDF ratusan MB agar RAM HP pengguna tidak bocor (*Out of Memory*).

---

## 5. Ide Fitur Vibe (Futuristik & Premium)

Untuk membuat Veltrik terlihat sebagai aplikasi "Mahal" dan berbeda dari sekadar "Google Drive PDF viewer":

1.  **AI-Powered PDF Oracle (Chat with Book):**
    Integrasikan API LLM (seperti Google Gemini). Pengguna premium dapat membuka *sidebar* saat membaca PDF dan "mengobrol" dengan PDF tersebut. (Misal: *"Rangkum bab 3 ini"*, *"Jelaskan konsep 'Black Hole' secara sederhana"*).
2.  **Holographic / Gyroscope Library Shelf:**
    Ubah *Grid View* biasa di *dashboard* menjadi rak buku 3D (*parallax effect*). Saat pengguna memiringkan HP mereka, *cover* buku akan ikut miring bereaksi terhadap *Gyroscope* *device*. Efek *glassmorphism* di UI akan semakin menyempurnakan fitur ini.
3.  **Binaural Focus Mode (Neuro-Reading):**
    Tambahkan mode khusus saat membaca yang secara otomatis memudarkan UI lainnya, beralih ke warna gelap (mengurangi kelelahan mata), dan menyediakan *built-in ambient audio* (hujan, lo-fi, atau *binaural beats*) untuk membantu pengguna fokus membaca berjam-jam secara *deep work*.

Semoga laporan audit ini membantu membawa Veltrik ke level selanjutnya!
