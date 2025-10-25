<div align="center">

# MyZoom Clone (Flutter + Firebase)

Real-time meeting app built with Flutter, Firebase, and WebRTC using Clean Architecture. Currently optimized for voice calls (video UI placeholders removed) with Firestore-based signaling and BLoC state management.

</div>

## ✨ Features

- Create / Join meetings with shareable Meeting ID (copy-to-clipboard in the meeting AppBar)
- Real-time voice communication via WebRTC (audio track on/off)
- Participants list with host flag and mic status
- Firestore-based signaling (offer/answer/ICE)
- Clean Architecture (domain → data → presentation), BLoC, and dependency injection (GetIt)
- Mobile platform permissions for mic/camera pre-configured

Note: The meeting room UI is currently voice-only. Video rendering surfaces were intentionally removed to simplify stability in release builds; video can be re-enabled later.

## 🧱 Architecture

- Domain: Entities (RTCParticipant, SignalingMessage), repository contracts, use cases
- Data: Models, Firestore + flutter_webrtc integration in `webrtc_remote_data_source`
- Presentation: BLoC (`WebRTCBloc`) + pages (`WebRTCMeetingRoomPage` and meeting flows)
- DI: `GetIt` registrations in `lib/core/di`

## 🧰 Tech Stack

- Flutter (3.35.x), Dart (3.9.x)
- Firebase: Core, Auth, Firestore
- WebRTC: `flutter_webrtc`
- State: `flutter_bloc`

## 📦 Project Structure (high level)

```
lib/
	main.dart
	core/
		di/
			injection.dart
			webrtc_injection.dart
	domain/
		entities/
			rtc_entities.dart
		repositories/
			webrtc_repository.dart
		usecases/
			webrtc/
				webrtc_usecases.dart
	data/
		datasources/
			webrtc_remote_data_source.dart
		models/
			rtc_models.dart
		repositories/
			webrtc_repository_impl.dart
	presentation/
		bloc/webrtc/
			webrtc_bloc.dart
			webrtc_event.dart
			webrtc_state.dart
		pages/meeting/
			meeting_page.dart
			create_meeting_page.dart
			webrtc_meeting_room_page.dart
```

## 🚀 Getting Started

1) Prereqs
- Flutter SDK installed and on PATH
- A Firebase project created
- Android Studio/Xcode tooling as needed for target platforms

2) Configure Firebase
- Android: place `android/app/google-services.json`
- iOS/macOS: place `ios/Runner/GoogleService-Info.plist` (and macOS accordingly) if targeting Apple platforms
- Optionally run FlutterFire CLI (`flutterfire configure`) to generate `firebase_options.dart`

3) Install packages

```bash
flutter pub get
```

4) Run (debug)

```bash
flutter run
```

## 📱 Usage

1) Launch the app and create or join a meeting
2) In the meeting room:
	 - Use the mic button to toggle your audio track
	 - Use the “copy” icon in the AppBar to copy the Meeting ID and share it
	 - Open the participants panel to see members and mic status

## 🌐 WebRTC Notes

- Signaling is implemented with Firestore (offer/answer/ICE messages)
- ICE servers include public STUN; for restrictive networks, configure a TURN server for reliability
- Voice-only: the UI does not render video surfaces; local/remote audio streams are used for calls

## 🧪 Troubleshooting

Gray screen in release:
- Fixed a layout issue (Stack + Positioned.fill) in the room; if you still see a gray area, ensure permissions are granted and check device logs

Android release specifics:
- If you later enable video, ProGuard/R8 may strip WebRTC classes—add keep rules (org.webrtc, plugin packages)
- Make sure RECORD_AUDIO/CAMERA permissions are granted in Settings (release-signed apps sometimes require manual grant)

No audio heard across devices:
- Verify local tracks are added to the RTCPeerConnection and remote tracks are received (logging added in `webrtc_remote_data_source.dart`)
- Test with both devices on the same network; if cross-NAT, add a TURN server
- Try headphones to rule out audio routing; optionally force speakerphone in platform code




