# Contributor Setup: Backend Connectivity

Welcome! This project uses a centralized configuration to manage backend connectivity, making it easy to switch between emulators, physical devices, and remote tunnels.

### 1. Start the Local Backend
Navigate to the `backend` directory and start the server:
```bash
npm install
npm start
```
By default, the server runs on `http://localhost:3000`.

### 2. Configure the Flutter App
Open [lib/core/config/app_config.dart](file:///e:/IIT%20resources/Project%20Zeylo/Zeylo-starter/zeylo/lib/core/config/app_config.dart) and update the `baseUrl` based on your target device:

| Target Device | URL to use in [AppConfig](file:///e:/IIT%20resources/Project%20Zeylo/Zeylo-starter/zeylo/lib/core/config/app_config.dart#1-10) |
| :--- | :--- |
| **Android Emulator** | `'http://10.0.2.2:3000'` |
| **iOS Simulator / Web** | `'http://localhost:3000'` |
| **Physical Phone (Wi-Fi)** | `'http://YOUR_LAPTOP_IP:3000'` |
| **Global Access (Anywhere)** | Use an **ngrok** URL (e.g., `'https://xyz.ngrok-free.app'`) |

### 3. Running the App
Once `AppConfig.baseUrl` is set, all services (AI, Admin, Discovery) will automatically point to your local backend.

```bash
flutter run
```

---

### Pro Tip: Using `--dart-define` (Optional)
If you want to avoid changing code frequently, you can modify [AppConfig](file:///e:/IIT%20resources/Project%20Zeylo/Zeylo-starter/zeylo/lib/core/config/app_config.dart#1-10) to read from environment variables:
```dart
// Example modification for AppConfig.dart
static const String baseUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://10.0.2.2:3000',
);
```
Then run the app with:
```bash
flutter run --dart-define=BACKEND_URL=https://your-ngrok-url.app
```
