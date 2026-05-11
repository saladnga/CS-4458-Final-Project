# Field Logs App — An Vu Hoang

Flutter mobile app for **field logs**: each entry has a **title**, **notes**, **GPS coordinates** (Geolocator), **weather** from [Open-Meteo](https://open-meteo.com/) (temperature, humidity, wind, etc.), and an optional **photo** stored in **Firebase Storage**. Data is cached in **SQLite** on device and synced to **Firebase Firestore** when online. **Firebase Auth** (email/password) protects access. **Provider** drives app state; theme (light/dark) is saved with **SharedPreferences**.

---

## What it does

| Area | Behavior |
|------|-----------|
| **Auth** | Sign up / sign in; `AuthGate` in `main.dart` supplies `FieldLogController` per signed-in user. |
| **Feed** | Lists logs from SQLite; **search** filters by title; **sort** by date or title (A–Z / Z–A). **Swipe** deletes a log. |
| **New log** | Saves title + notes, captures **location** (permission required), optional **camera/gallery** image → upload to Storage path `logs/{userId}/{logId}.jpg`. Writes row locally, **upserts** Firestore doc `logs/{userId}/entries/{logId}`, then fetches **weather** for those coordinates and saves text to the log. |
| **Detail** | View/edit title and notes, image, coordinates, weather lines, created time. Saves update to SQLite + Firestore. |
| **Profile / settings** | **Profile** tab: update display name and password. From the **log feed**, the menu opens a **drawer**: **theme** (light/dark), link to profile, **sign out**. |

**Sync note:** Created/updated/deleted logs are **written to Firestore** when the operation succeeds. **`refresh()`** reloads from SQLite; it **loads documents from Firestore only when the local log list is empty** (e.g. fresh install). If the device already has local rows, use the app normally—**writes** still push to Firebase.

---

## Setup

1. **Install dependencies** (from this folder):

   ```bash
   flutter pub get
   ```

2. **Firebase** — add these locally (see `.gitignore`; they are not committed):

   | File | How |
   |------|-----|
   | `lib/firebase_options.dart` | `dart pub global activate flutterfire_cli` then `flutterfire configure` |
   | `android/app/google-services.json` | Firebase Console → Project settings → Android app |
   | `ios/Runner/GoogleService-Info.plist` | Same for iOS if you build for iPhone |

3. **Firestore / Storage rules** must allow the signed-in user access only under their `userId` (paths above).

---

## Run & build

```bash
flutter run
flutter run --release
```

**Android APK:**

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Requirements

- Flutter / Dart per `pubspec.yaml` (`sdk: ^3.11.4`).
- Android SDK (and Xcode on macOS for iOS).

---

## Troubleshooting

- **`firebase_options` / `google-services.json` missing** → run FlutterFire and add the JSON files.  
- **Permission errors (Firestore/Storage)** → check rules match `logs/...` paths.  
- **Location or camera** → grant permissions in system settings.
