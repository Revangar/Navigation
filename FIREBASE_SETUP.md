# Firebase setup for IOSDT 1.3

The code for Firebase Authentication is already integrated into the project. The remaining Firebase Console configuration is account-specific.

1. Create a Firebase project in Firebase Console.
2. Add an iOS app with Bundle Identifier:
   `ru.ilyatrundaev.navigation`
3. Download `GoogleService-Info.plist`.
4. Put the file at:
   `Navigation/GoogleService-Info.plist`
5. In Firebase Console open Authentication → Sign-in method and enable **Email/Password**.
6. From the repository root run:
   `pod install`
7. Open `Navigation.xcworkspace` rather than `Navigation.xcodeproj`.

Firebase documents `GoogleService-Info.plist` as containing project/app identifiers rather than secret credentials, so it can be committed to this educational repository after the Firebase app is created.
