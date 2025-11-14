# ⚡ Quick Build APK

## 🚀 Build APK dalam 3 Langkah

### 1. Buka Terminal di folder project
```bash
cd 3awan_caferesto_app
```

### 2. Build APK
```bash
flutter build apk --release
```

### 3. Cari file APK di:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Selesai!** Copy file APK ke HP dan install.

---

## 📱 Install di HP

1. Copy `app-release.apk` ke HP
2. Buka file manager di HP
3. Tap file APK
4. Install

**Note:** Jika muncul "Install from Unknown Sources", izinkan di Settings.

---

## 🔧 Jika Error

```bash
flutter clean
flutter pub get
flutter build apk --release
```

