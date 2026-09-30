# Hotel TV apps

Flutter client for phone and Android TV. The Laravel repo stays the backend and the Blade web UI for browser TVs.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE=http://YOUR-HOTEL-SERVER
```

Android TV uses the same project. D-pad focus is on the tiles; OK opens the item. Playback uses `play_url` from `GET /api/channels`, which is the portal stream proxy.

Do not point this at a public internet host. The portal API is meant for the hotel LAN.
