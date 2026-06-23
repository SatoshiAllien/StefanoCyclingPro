#!/bin/bash
# Ensures embedded watch app Info.plist has keys required by installd (CoreDeviceError 3002).
set -euo pipefail

PLIST="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Info.plist"

if [ ! -f "$PLIST" ]; then
    echo "error: Watch Info.plist not found at ${PLIST}" >&2
    exit 1
fi

set_plist_bool() {
    local key="$1"
    /usr/libexec/PlistBuddy -c "Delete :${key}" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :${key} bool true" "$PLIST"
}

set_plist_string() {
    local key="$1"
    local value="$2"
    /usr/libexec/PlistBuddy -c "Delete :${key}" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :${key} string ${value}" "$PLIST"
}

# installd accepts WKApplication OR WKWatchKitApp — set both for maximum compatibility.
set_plist_bool "WKApplication"
set_plist_bool "WKWatchKitApp"
set_plist_string "WKCompanionAppBundleIdentifier" "com.example.StefanoCyclingPro"

echo "Watch Info.plist install keys:"
/usr/libexec/PlistBuddy -c "Print :WKApplication" "$PLIST"
/usr/libexec/PlistBuddy -c "Print :WKWatchKitApp" "$PLIST"
/usr/libexec/PlistBuddy -c "Print :WKCompanionAppBundleIdentifier" "$PLIST"