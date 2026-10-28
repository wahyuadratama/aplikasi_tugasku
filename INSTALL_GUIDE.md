# Panduan Install TugasKu di HP

## File APK
- **Lokasi**: `build/app/outputs/flutter-apk/app-release.apk`
- **Ukuran**: ~51 MB
- **Kompatibilitas**: Android 5.0+ (API 21+)

## Cara Install

### Opsi 1: Via USB (Recommended)
1. **Hubungkan HP ke PC** dengan kabel USB
2. **Enable USB Debugging** di HP:
   - Buka Settings → About Phone
   - Tap "Build Number" 7x sampai muncul "Developer Options"
   - Kembali ke Settings → Developer Options
   - Enable "USB Debugging"
3. **Install APK**:
   ```bash
   flutter install
   ```
   atau
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### Opsi 2: Via File Transfer
1. **Copy APK ke HP**:
   - Hubungkan HP via USB
   - Copy file `app-release.apk` ke folder Download HP
2. **Install di HP**:
   - Buka File Manager → Download
   - Tap file `app-release.apk`
   - Tap "Install"
   - Izinkan akses jika diminta

### Opsi 3: Via Email/Cloud
1. **Upload APK** ke Google Drive / Email
2. **Download di HP** dari Drive/Email
3. **Install** seperti Opsi 2

## Izin yang Diperlukan
Saat pertama kali membuka app, izinkan:
- **Notifications** (untuk reminder deadline)
- **Calendar** (opsional, untuk integrasi kalender)

## Fitur yang Tersedia
✅ Daftar tugas aktif dengan kategori  
✅ Filter per kategori (case-insensitive)  
✅ Prioritas tugas: Tinggi / Sedang / Rendah  
✅ Deadline dengan tanggal sungguhan  
✅ Reminder otomatis H-1 dan hari-H pukul 08:00  
✅ Sub-tugas (checklist dalam tugas)  
✅ Sorting: Manual / Deadline / Prioritas / Nama  
✅ Pencarian tugas real-time  
✅ Dark mode / Light mode  
✅ Layar tugas selesai  
✅ Data disimpan lokal (tanpa server)

## Troubleshooting

### "App tidak terinstall"
- Pastikan HP mengizinkan instalasi dari sumber tidak dikenal:
  - Settings → Security → Unknown Sources (ON)
  - atau Settings → Apps → Special app access → Install unknown apps

### "Notifikasi tidak muncul"
- Pastikan izin notifikasi sudah diberikan
- Cek pengaturan notifikasi app di Settings

### "Data hilang setelah uninstall"
- Data disimpan lokal di HP, akan hilang jika app diuninstall
- Backup data sebelum uninstall (fitur backup akan ditambahkan)

## Uninstall
- Buka Settings → Apps → TugasKu → Uninstall
- atau gunakan: `adb uninstall com.tugasku.app`

## Update
- Download APK versi terbaru
- Install ulang (akan replace versi lama)
- Data tetap tersimpan

---

**Versi**: 1.0.0  
**Build Date**: 2024  
**Min SDK**: Android 5.0 (API 21)
