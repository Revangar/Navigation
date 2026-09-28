# Firebase setup for IOSDT

Firebase Authentication is integrated with Swift Package Manager.

## Firebase Console

1. Firebase project: `Navigation-IOSDT`.
2. iOS Bundle Identifier: `ru.ilyatrundaev.navigation`.
3. `Navigation/GoogleService-Info.plist` is included in the app target.
4. Authentication → Sign-in method → **Email/Password** is enabled.

## Swift Package Manager

The Xcode project contains the package:

`https://github.com/firebase/firebase-ios-sdk.git`

Products linked to the `Navigation` target:

- `FirebaseCore`
- `FirebaseAuth`

Minimum package version: `12.19.2`.

No CocoaPods installation is required. Open `Navigation.xcodeproj`; Xcode resolves the Swift packages automatically.

## Note for course review

The previous Firebase homework was accepted in advance because the instructor could not install the CocoaPods-based version. The project has now been migrated to SPM as requested, so the next Firebase review can be performed directly from the Xcode project.
