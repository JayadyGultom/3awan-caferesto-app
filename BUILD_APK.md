# 📱 Panduan Build APK untuk Android

## 🎯 Cara Build APK ke HP Android

### **Metode 1: Build APK Debug (Paling Mudah - Untuk Testing)**

#### Langkah-langkah:

1. **Buka Terminal/Command Prompt**
   - Buka folder project: `cd 3awan_caferesto_app`

2. **Pastikan Flutter sudah terinstall dan siap**
   ```bash
   flutter doctor
   ```
   Pastikan semua checklist hijau (✓)

3. **Build APK Debug**
   ```bash
   flutter build apk --debug
   ```

4. **Lokasi APK**
   - APK akan tersimpan di: `build/app/outputs/flutter-apk/app-debug.apk`

5. **Transfer ke HP**
   - Copy file `app-debug.apk` ke HP via:
     - USB cable
     - Email
     - Google Drive / Dropbox
     - Bluetooth
     - WhatsApp

6. **Install di HP**
   - Buka file manager di HP
   - Cari file `app-debug.apk`
   - Tap untuk install
   - Izinkan "Install from Unknown Sources" jika diminta

---

### **Metode 2: Build APK Release (Untuk Production)**

#### Langkah-langkah:

1. **Buka Terminal di folder project**
   ```bash
   cd 3awan_caferesto_app
   ```

2. **Build APK Release**
   ```bash
   flutter build apk --release
   ```

3. **Lokasi APK**
   - APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

4. **Transfer dan Install**
   - Sama seperti metode 1

---

### **Metode 3: Build APK Split per ABI (Ukuran Lebih Kecil)**

Untuk mengurangi ukuran APK, build per arsitektur:

```bash
flutter build apk --split-per-abi
```

Ini akan menghasilkan 3 file APK:
- `app-armeabi-v7a-release.apk` (untuk HP lama)
- `app-arm64-v8a-release.apk` (untuk HP modern)
- `app-x86_64-release.apk` (untuk emulator)

Pilih yang sesuai dengan HP Anda (biasanya `arm64-v8a` untuk HP modern).

---

## 🔧 Persiapan Sebelum Build

### 1. **Update Dependencies**
```bash
flutter pub get
```

### 2. **Cek Android Setup**
```bash
flutter doctor -v
```

Pastikan:
- ✓ Android toolchain - develop for Android devices
- ✓ Android Studio (optional tapi recommended)

### 3. **Pastikan Internet Connection**
- Build membutuhkan koneksi internet untuk download dependencies

---

## ⚙️ Konfigurasi Tambahan (Opsional)

### **Ubah Nama Aplikasi**

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Cafe Resto"  <!-- Ganti nama aplikasi -->
    ...>
```

### **Ubah Icon Aplikasi**

Ganti file icon di:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

### **Ubah Package Name**

Edit `android/app/build.gradle.kts`:
```kotlin
applicationId = "com.caferesto.app"  // Ganti dengan package name Anda
```

---

## 🚀 Build dengan Command Lengkap

### **Build APK Release dengan Nama Custom**
```bash
flutter build apk --release --build-name=1.0.0 --build-number=1
```

### **Build APK dengan Target Specific**
```bash
flutter build apk --release --target-platform android-arm64
```

---

## 📦 Alternatif: Build App Bundle (untuk Google Play Store)

Jika ingin upload ke Google Play Store:

```bash
flutter build appbundle --release
```

File akan tersimpan di: `build/app/outputs/bundle/release/app-release.aab`

---

## ⚠️ Troubleshooting

### **Error: "Gradle build failed"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### **Error: "SDK location not found"**
- Pastikan Android SDK sudah terinstall
- Set environment variable `ANDROID_HOME`

### **Error: "Java version"**
- Pastikan Java 11 atau lebih tinggi terinstall
- Cek dengan: `java -version`

### **APK terlalu besar?**
- Gunakan `--split-per-abi` untuk mengurangi ukuran
- Atau build App Bundle untuk Play Store

---

## 📱 Install APK di HP

### **Via USB Cable:**
1. Hubungkan HP ke PC via USB
2. Enable "USB Debugging" di HP (Settings > Developer Options)
3. Copy APK ke HP
4. Buka file manager di HP dan install

### **Via Email/Cloud:**
1. Upload APK ke Google Drive/Dropbox
2. Download di HP
3. Install dari file manager

### **Via ADB (Advanced):**
```bash
flutter install
```
atau
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ Checklist Sebelum Build

- [ ] Flutter SDK terinstall
- [ ] Android SDK terinstall
- [ ] Dependencies sudah di-update (`flutter pub get`)
- [ ] Koneksi internet tersedia
- [ ] Tidak ada error di code
- [ ] Test aplikasi di emulator/device dulu

---

## 🎉 Setelah Build Berhasil

APK siap digunakan! File APK bisa diinstall di:
- ✅ HP Android (semua versi yang support)
- ✅ Emulator Android
- ✅ Tablet Android

**Catatan:** APK Debug lebih besar ukurannya tapi mudah untuk testing. APK Release lebih kecil dan optimized untuk production.

