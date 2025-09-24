# FITDJ iOS App Skeleton

This repository contains the SwiftUI-based FITDJ application scaffold. It targets iOS 15+ and includes placeholder implementations for authentication, workouts, audio, and payments while keeping integration points ready for Spotify, ElevenLabs, Firebase, and StoreKit 2.

## Project Structure

```
FITDJ/
  App/
  Core/
  Features/
  Seeds/
  Tests/
```

## Seed Data & Assets

Seed JSON, placeholder audio/video folders, and stub services allow the app to boot in a simulator without secrets. Replace stub implementations with production-ready services and add the necessary SDKs (Spotify, Firebase, StoreKit 2) to complete functionality. See [`Seeds/README.md`](Seeds/README.md) for a short reminder when populating real data.

## Running in Xcode

1. Open the project in Xcode 15 or newer (use `File > Open...` and select `FITDJ.xcodeproj`).
2. Ensure the active scheme is **FITDJ** and a simulator (iPhone 15 Pro or similar) is selected.
3. Press **Cmd+R** to build and launch the app. The stubbed services will let the demo run without real backend credentials.
4. When you are ready for production integrations, add the Spotify, Firebase, and StoreKit 2 SDKs via Swift Package Manager or XCFrameworks, swap the stub services for the real implementations, and configure any required capabilities (Background Modes, Sign in with Apple, etc.).

## Requirements

- Xcode 15+
- iOS 15.0+ deployment target
- Swift 5.9 toolchain

## Testing

Unit and UI test targets are included under `Tests/`. You can run them from Xcode with **Product > Test** once you flesh out the implementations.
