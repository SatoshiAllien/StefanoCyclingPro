# StefanoCyclingPro

Professional cycling app for iOS + watchOS — BLE sensors, HealthKit, Apple Watch HR streaming, Swift Charts.

**Created by Stefano Ciancimino**

## Quick Start

```bash
git clone https://github.com/SatoshiAllien/StefanoCyclingPro.git
cd StefanoCyclingPro
```

1. Edit `Config/Development.xcconfig` — replace `TEAMID_PLACEHOLDER` with your Apple Team ID
2. `open StefanoCyclingPro.xcodeproj`
3. Clean (⇧⌘K) → Build (⌘B) → Run (⌘R) on iPhone

## Requirements

- macOS + Xcode 15+
- iPhone iOS 16+
- Apple Watch watchOS 9+ (optional, for live HR)
- Apple Developer account (device deployment)

## Project Structure

```
StefanoCyclingPro/
├── StefanoCyclingPro.xcodeproj
├── Sources/
│   ├── App/              # iOS entry + AppState
│   ├── Features/         # Dashboard, Workout, Sensors, History
│   ├── Charts/           # Swift Charts views (iOS 16/17)
│   ├── Models/           # CyclingWorkout, MetricsSample, LiveMetrics
│   ├── Services/         # HealthKit, WorkoutRecorder, MetricsMerger
│   ├── Bluetooth/        # BLE manager + sensor profiles
│   ├── Watch/            # watchOS app + iOS WatchConnectivity
│   └── UIComponents/     # Theme, gauges, cards
├── Assets/
├── Config/               # Info.plist, entitlements, xcconfig
└── scripts/              # generate_xcodeproj.py, fix_watch_plist.sh
```

## Targets

| Target | Platform | Bundle ID |
|--------|----------|-----------|
| StefanoCyclingPro | iOS | `com.example.StefanoCyclingPro` |
| StefanoCyclingProWatch | watchOS | `com.example.StefanoCyclingPro.watch` |

watchOS 9+ uses a **unified watch app** (extension embedded by the system). No separate Watch Extension target is required.

## Signing

```
DEVELOPMENT_TEAM = YOUR_TEAM_ID   # in Config/Development.xcconfig
CODE_SIGN_STYLE = Automatic
```

Enable **HealthKit** capability on both targets. See `IMPOSTA_TEAM.txt`.

## Features

- BLE: power (0x1818), HR (0x180D), speed/cadence (0x1816), Wahoo KICKR/Speedplay
- HR priority: Apple Watch → BLE strap → HealthKit
- HealthKit workouts + iOS 17 `cyclingPower` availability guards
- Live dashboard, workout recorder, elevation (barometer)
- Charts: iOS 17 SectorMark + iOS 16 BarMark fallback
- Local workout history (UserDefaults JSON)

## Regenerate Xcode Project

```bash
python3 scripts/generate_xcodeproj.py
```

## Troubleshooting Install (CoreDeviceError 3002)

See `FIX_COREDEVICE_3002.txt`. The watch target runs `scripts/fix_watch_plist.sh` to inject `WKApplication` keys.

## License

Copyright © 2026 Stefano Ciancimino. All rights reserved.