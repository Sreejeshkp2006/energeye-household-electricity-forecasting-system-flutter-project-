# EnergEYE Deployment Guide

This guide provides step-by-step instructions for hosting the EnergEYE application.

## 1. Hosting the Flutter Web App (Firebase)

### Prerequisites
- [Firebase CLI](https://firebase.google.com/docs/cli) installed.
- Logged into Firebase (`firebase login`).

### Steps
1. Navigate to the `miniproject` directory:
   ```bash
   cd miniproject
   ```
2. Build the Flutter web application:
   ```bash
   flutter build web
   ```
3. Deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```
4. Once completed, your web app will be available at your Firebase Hosting URL (e.g., `https://energeye-54685.web.app`).

---

## 2. Distributing the Android App

There are multiple ways to share your Android version.

### A. Direct Download (Hosting APK on your Website)
1. Build the release APK:
   ```bash
   cd miniproject
   flutter build apk --release
   ```
2. Copy the APK to your web public folder:
   ```bash
   mkdir -p build/web/downloads
   cp build/app/outputs/flutter-apk/app-release.apk build/web/downloads/energeye.apk
   ```
3. Add a link to your `index.html` or dashboard for users to download it.
4. Deploy to Firebase:
   ```bash
   firebase deploy --only hosting
   ```

### B. Firebase App Distribution (Best for Private Testing)
1. In the [Firebase Console](https://console.firebase.google.com/), go to **App Distribution**.
2. Upload your `build/app/outputs/flutter-apk/app-release.apk`.
3. Add tester emails, and they will receive a link to download the app.

### C. Google Play Store (Production)
1. Generate an App Bundle:
   ```bash
   flutter build appbundle
   ```
2. Upload the `.aab` file to the [Google Play Console](https://play.google.com/console/).

---

## 3. Hosting the Python ML Backend (Render)

Render is a simple platform for hosting FastAPI apps.

### Steps
1. Create a new account on [Render](https://render.com/).
2. Click **New +** > **Web Service**.
3. Connect your GitHub repository (specifically the `backend` folder).
4. Configure the following:
   - **Runtime**: `Python`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Render will provide you with a URL (e.g., `https://energeye-backend.onrender.com`).

### Alternative: Google Cloud Run (Docker)
Since we created a `Dockerfile`, you can also deploy to Google Cloud Run:
```bash
cd backend
gcloud run deploy --source .
```

---

## 4. Connecting Frontend to Backend

After hosting the backend, update the API URL in your Flutter code (typically in a constants file) from `http://localhost:8000` to your new production URL.
