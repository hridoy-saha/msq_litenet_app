import re
from pathlib import Path

manifest_path = Path("android/app/src/main/AndroidManifest.xml")
if manifest_path.exists():
    text = manifest_path.read_text(encoding="utf-8")
    perms = [
        '<uses-permission android:name="android.permission.CAMERA"/>',
        '<uses-permission android:name="android.permission.INTERNET"/>',
    ]
    for p in perms:
        if p not in text:
            text = text.replace("<application", f"    {p}\n    <application", 1)
    text = re.sub(r'android:label="[^"]*"', 'android:label="MSQ-LiteNet"', text, count=1)
    manifest_path.write_text(text, encoding="utf-8")

kts_path = Path("android/app/build.gradle.kts")
groovy_path = Path("android/app/build.gradle")

if kts_path.exists():
    text = kts_path.read_text(encoding="utf-8")
    text = re.sub(r"minSdk\s*=\s*[^
]+", "minSdk = 26", text)
    if "noCompress" not in text:
        block = '\n    androidResources {\n        noCompress += listOf("tflite", "lite")\n    }\n'
        text = text.replace("defaultConfig {", block + "    defaultConfig {", 1)
    kts_path.write_text(text, encoding="utf-8")
elif groovy_path.exists():
    text = groovy_path.read_text(encoding="utf-8")
    text = re.sub(r"minSdk\s*=?\s*[^
]+", "minSdk = 26", text)
    text = re.sub(r"minSdkVersion\s+[^
]+", "minSdkVersion 26", text)
    if "noCompress" not in text:
        block = "\n    aaptOptions {\n        noCompress 'tflite'\n        noCompress 'lite'\n    }\n"
        text = text.replace("defaultConfig {", block + "    defaultConfig {", 1)
    groovy_path.write_text(text, encoding="utf-8")
