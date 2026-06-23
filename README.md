# StefanoCyclingPro 2.0

App iOS + watchOS per ciclismo — BLE, HealthKit, Apple Watch HR, Swift Charts.

## Terminale (macOS) — copia e incolla

**Prima installazione:**

```bash
git clone https://github.com/SatoshiAllien/StefanoCyclingPro.git ~/StefanoCyclingPro
cd ~/StefanoCyclingPro
chmod +x SETUP.sh
./SETUP.sh
```

**Oppure aggiornamento:**

```bash
cd ~/StefanoCyclingPro
./SETUP.sh
```

**Poi imposta il Team ID:**

```bash
nano ~/StefanoCyclingPro/Config/Development.xcconfig
# DEVELOPMENT_TEAM = IL_TUO_TEAM_ID
```

In Xcode: **⇧⌘K** → **⌘B** → **⌘R** su iPhone.

---

## Repo

https://github.com/SatoshiAllien/StefanoCyclingPro

## Versione 2.0 — fix inclusi

- Zero errori compile (Hashable, HealthKit iOS17, MainActor, Charts, OperationQueue)
- Install watch fix (WKApplication + script post-build)
- Bundle: `com.example.StefanoCyclingPro` + `.watch`
- Struttura pulita: `Sources/Charts/`, `Sources/Features/`, ecc.

## Target

| Target | Bundle ID |
|--------|-----------|
| StefanoCyclingPro | `com.example.StefanoCyclingPro` |
| StefanoCyclingProWatch | `com.example.StefanoCyclingPro.watch` |

## Requisiti

- Xcode 15+, iOS 16+, watchOS 9+
- Apple Developer Team ID

Copyright © 2026 Stefano Ciancimino.