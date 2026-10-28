# TugasKu

Aplikasi pengatur tugas kuliah dan harian, dibuat dengan Flutter.
Data disimpan lokal di perangkat (SharedPreferences) — tanpa server, tanpa akun.

## Fitur

- Daftar tugas aktif dengan centang "selesai", edit, dan hapus.
- Filter per kategori (chip), case-insensitive: "Kuliah" dan "kuliah" dianggap sama.
- Prioritas tugas: Tinggi / Sedang / Rendah.
- Deadline berupa tanggal sungguhan — bisa diurutkan, ditandai otomatis kalau lewat.
- Layar khusus "Tugas Selesai" (bisa diedit juga).
- **Pencarian tugas real-time** (cari berdasarkan judul & deskripsi).
- Sub-tugas dengan progress tracking.
- Reminder otomatis (H-1 dan hari-H pukul 08:00).
- Sorting: Manual / Deadline / Prioritas / Nama.
- Dark mode & Light mode.
- Data contoh muncul saat pertama kali dibuka.

## Menjalankan

```bash
flutter pub get
flutter run
```

Target yang tersedia: Android, iOS, Web, Windows, macOS, Linux.

## Build APK untuk Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (recommended)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (51 MB)

# Install ke HP
flutter install
# atau
adb install build/app/outputs/flutter-apk/app-release.apk
```

Lihat [INSTALL_GUIDE.md](INSTALL_GUIDE.md) untuk panduan lengkap.

## Test

```bash
flutter analyze    # Cek kualitas kode
flutter test       # Jalankan semua test (47/47 passing ✅)
```

## Struktur

```
lib/
  main.dart                      MaterialApp + tema (dark/light mode)
  models/
    task.dart                    Task + TaskPriority + TaskSort enum
    sub_task.dart               SubTask model
  services/
    task_storage.dart           SharedPreferences (baca/tulis tahan error)
    notification_service.dart   Local notifications & reminders
  screens/
    home_screen.dart            Daftar tugas + filter + search
    add_task_screen.dart        Tambah/edit tugas + sub-tugas
    completed_screen.dart       Tugas selesai
  widgets/
    task_card.dart              Kartu tugas dengan progress bar
    empty_state.dart            Ilustrasi empty state
  utils/
    app_router.dart             Navigasi dengan animasi
    date_label.dart             Format label deadline
test/                           Unit test + widget test (47 tests)
```

## Catatan

- Bundle ID: `com.tugasku.app` (Android, iOS, macOS, Linux). Ganti ke domain
  sendiri sebelum rilis.
- Penulisan signing Android masih memakai debug key — wajib diganti untuk rilis.
- Skema data disimpan di `tugasku_schema_version`. Format lama (deadline berupa
  teks "Hari ini"/"Besok") masih bisa dibaca dan dimigrasikan otomatis.
- Min SDK: Android 5.0 (API 21)
- Target SDK: Android 14 (API 34)

## Dokumentasi

- [INSTALL_GUIDE.md](INSTALL_GUIDE.md) - Panduan instalasi di HP
- [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) - Checklist testing lengkap
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Referensi cepat commands & config
- [SESSION_SUMMARY.md](SESSION_SUMMARY.md) - Ringkasan fitur & implementasi
- [COMPLETION_REPORT.md](COMPLETION_REPORT.md) - Laporan penyelesaian session

## Status

✅ **Production Ready**
- 47/47 tests passing
- 0 static analysis issues
- APK built successfully (51 MB)
- Ready for deployment
