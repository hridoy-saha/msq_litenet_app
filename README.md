# MSQ-LiteNet — Mango Quality & Shelf-Life Assessment (Flutter App)

Complete, production-structured Flutter application with the embedded `MSQ-LiteNet_fp16.tflite` model (`assets/models/msq_litenet_fp16.tflite`).

## Option A: Build APK Automatically in the Cloud (No Android Studio Needed)

1. Extract `msq_litenet_app.zip`.
2. Create a new repository on GitHub and push all extracted files (including `.github/workflows/build_apk.yml`).
3. Open the **Actions** tab in your GitHub repository.
4. Wait ~3 minutes for **Build MSQ-LiteNet Release APK** to finish.
5. Download **`MSQ-LiteNet-Release-APK`** from the **Artifacts** section and install `app-release.apk` on your Android phone.

## Option B: Build APK Locally on Your PC

Make sure Flutter SDK & Python 3 are installed, then inside the `msq_litenet_app` folder run:

- **Windows:** Double-click `build_apk.bat` (or run in PowerShell/CMD)
- **macOS / Linux:**
  ```bash
  chmod +x build_apk.sh
  ./build_apk.sh
  ```

Output APK path:
`build/app/outputs/flutter-apk/app-release.apk`
