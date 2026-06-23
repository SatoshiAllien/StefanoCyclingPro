# StefanoCyclingPro

Professional cycling app for advanced indoor/outdoor training — inspired by Wahoo ELEMNT Bolt V3.

**Created by Stefano Ciancimino**

Connect Wahoo Speedplay Power Dual pedals, KICKR ROLLR trainers, standard BLE power/speed/cadence/HR sensors, Apple Health, and Apple Watch live heart rate streaming.

## Requirements

- macOS with **Xcode 15+**
- iPhone running **iOS 16+**
- Apple Watch running **watchOS 10+** (optional, for live HR)
- Apple Developer account (for device deployment and HealthKit)

## Open in Xcode

```bash
cd StefanoCyclingPro
open StefanoCyclingPro.xcodeproj
```

Or double-click `OPEN_XCODE.command` on macOS.

1. Select the **StefanoCyclingPro** scheme
2. Choose your iPhone as the run destination
3. Set your **Development Team** in Signing & Capabilities for both targets:
   - `StefanoCyclingPro` (iOS)
   - `StefanoCyclingProWatch` (watchOS)
4. Build and run (`⌘R`)

## Enable HealthKit

1. Open the project in Xcode
2. Select the **StefanoCyclingPro** target → **Signing & Capabilities**
3. Confirm **HealthKit** is enabled (entitlements file: `Config/StefanoCyclingPro.entitlements`)
4. Repeat for **StefanoCyclingProWatch** target
5. On first launch, tap through the app — it requests Health read/write permissions automatically
6. On iPhone: **Settings → Health → Data Access & Devices → StefanoCyclingPro** — enable:
   - Heart Rate (read)
   - Cycling Distance (read)
   - VO2 Max (read)
   - Active Energy (read/write)
   - Workouts (read/write)

## Enable Bluetooth

Bluetooth permissions are declared in `Config/Info.plist`:

- `NSBluetoothAlwaysUsageDescription`
- Background mode: `bluetooth-central`

On first sensor scan, iOS prompts for Bluetooth access. Ensure Bluetooth is ON and sensors are awake (pedals spun, trainer powered).

## Pair Apple Watch & Stream HR

1. Install **StefanoCyclingPro** on iPhone **and** Apple Watch (watch app installs with iOS app)
2. Open the Watch app on iPhone → **My Watch → StefanoCyclingPro** → confirm it's installed
3. On iPhone, start a **Workout** in StefanoCyclingPro
4. The Watch app automatically receives `startHR` via WatchConnectivity and begins an HKWorkout session
5. Live BPM streams to iPhone; dashboard shows **Watch** indicator when connected
6. Stop the workout on iPhone — Watch ends the HR session and data syncs to HealthKit

**Tip:** Keep both apps in the foreground during the first connection test.

## Test with Wahoo Devices

| Device | Profile | Notes |
|--------|---------|-------|
| Speedplay Power Dual | Cycling Power (0x1818) | Auto-detected by name "Speedplay" |
| KICKR ROLLR | FTMS (0x1826) | Auto-detected by name "KICKR" / "ROLLR" |
| Generic power meter | CPS 0x2A63 | Standard BLE cycling power |
| HR strap | HRM 0x2A37 | Standard heart rate |
| Speed/Cadence | CSC 0x2A5B | Wheel/crank sensor |

**Steps:**

1. Wake the sensor (spin cranks / power on trainer)
2. Open **Sensors** tab → **Scan Sensors**
3. Tap a device → **Connect**
4. Return to **Dashboard** — power, cadence, speed update in real time

## Run on iPhone & Apple Watch

### iPhone only

1. Connect iPhone via USB or Wi-Fi debugging
2. Select iPhone destination → Run
3. Trust developer certificate on device if prompted

### iPhone + Apple Watch

1. Pair Watch with iPhone in the Watch app
2. Run StefanoCyclingPro on iPhone — Xcode installs both targets
3. Select the Watch scheme (`StefanoCyclingProWatch`) to debug watch UI separately if needed

## Project Structure

```
StefanoCyclingPro/
├── StefanoCyclingPro.xcodeproj
├── Sources/
│   ├── App/              # App entry, global state
│   ├── Models/           # Workout, metrics, zones, sensors
│   ├── Services/         # HealthKit, storage, recording, calculations
│   ├── Bluetooth/        # CoreBluetooth + Wahoo/BLE profiles
│   ├── Watch/            # WatchConnectivity (iOS) + HR session (watchOS)
│   ├── Features/         # Dashboard, Workout, Sensors, History, Charts
│   └── UIComponents/     # Gauges, zones, cards, theme
├── StefanoCyclingProWatch/
│   └── Sources/          # watchOS companion app
├── Assets/
│   └── AppAssets.xcassets
└── Config/               # Info.plist, entitlements
```

## Features

- Real-time power, cadence, speed, HR, cycling dynamics
- Heart rate zones 1–7 with Wahoo-style colors
- Swift Charts: power, cadence, speed, HR, zone pie, training load
- Auto-pause below 2 km/h
- Local JSON workout storage + Apple Health sync
- Dark mode UI with neon accents

## Bundle IDs

- iOS: `com.stefanociancimino.StefanoCyclingPro`
- watchOS: `com.stefanociancimino.StefanoCyclingPro.watchkitapp`

Change these in Xcode if you use your own developer account.

## License

Copyright © 2026 Stefano Ciancimino. All rights reserved.