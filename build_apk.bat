@echo off
flutter create --platforms=android --org com.msqlitenet --project-name msq_litenet_app .
python scripts\configure_android.py
flutter pub get
flutter build apk --release
echo APK Ready: build\app\outputs\flutter-apk\app-release.apk
pause
