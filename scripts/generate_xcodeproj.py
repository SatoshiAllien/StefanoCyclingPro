#!/usr/bin/env python3
import hashlib
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ios_sources = [
    "Sources/App/StefanoCyclingProApp.swift",
    "Sources/App/AppState.swift",
    "Sources/Models/CyclingWorkout.swift",
    "Sources/Models/MetricsSample.swift",
    "Sources/Models/LiveMetrics.swift",
    "Sources/Models/PowerZone.swift",
    "Sources/Models/SensorDevice.swift",
    "Sources/Services/HealthKitService.swift",
    "Sources/Services/WorkoutRecorder.swift",
    "Sources/Services/MetricsCalculator.swift",
    "Sources/Services/MetricsMerger.swift",
    "Sources/Services/StorageService.swift",
    "Sources/Bluetooth/BluetoothManager.swift",
    "Sources/Bluetooth/CyclingPowerProfile.swift",
    "Sources/Bluetooth/HeartRateProfile.swift",
    "Sources/Bluetooth/SpeedCadenceProfile.swift",
    "Sources/Bluetooth/WahooKICKRProfile.swift",
    "Sources/Bluetooth/WahooSpeedplayProfile.swift",
    "Sources/Watch/WatchConnectivityManager.swift",
    "Sources/Watch/WatchWorkoutModel.swift",
    "Sources/Features/Dashboard/DashboardView.swift",
    "Sources/Features/Dashboard/DashboardViewModel.swift",
    "Sources/Features/Workout/WorkoutView.swift",
    "Sources/Features/Workout/WorkoutViewModel.swift",
    "Sources/Features/Sensors/SensorListView.swift",
    "Sources/Features/Sensors/SensorDetailView.swift",
    "Sources/Features/History/HistoryView.swift",
    "Sources/Features/History/HistoryViewModel.swift",
    "Sources/Features/Charts/ChartThrottle.swift",
    "Sources/Features/Charts/PowerChartView.swift",
    "Sources/Features/Charts/HeartRateChartView.swift",
    "Sources/Features/Charts/CadenceChartView.swift",
    "Sources/Features/Charts/SpeedChartView.swift",
    "Sources/Features/Charts/ZoneDistributionChartView.swift",
    "Sources/Features/Charts/TrainingLoadChartView.swift",
    "Sources/UIComponents/GaugeView.swift",
    "Sources/UIComponents/ZoneIndicator.swift",
    "Sources/UIComponents/MetricCard.swift",
    "Sources/UIComponents/AnimatedNumber.swift",
    "Sources/UIComponents/HRSourceIndicator.swift",
    "Sources/UIComponents/Theme.swift",
]

watch_sources = [
    "Sources/Watch/WatchApp.swift",
    "Sources/Watch/WatchAppExtension.swift",
    "Sources/Watch/WatchInterface/WatchHRView.swift",
    "Sources/Watch/WatchHRSession.swift",
    "Sources/Watch/WatchWorkoutModel.swift",
    "Sources/Models/PowerZone.swift",
    "Sources/UIComponents/Theme.swift",
]


def uid(seed: str) -> str:
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()


def main() -> None:
    ids = {name: uid(name) for name in [
        "ios_target", "watch_target", "ios_app", "watch_app", "project",
        "ios_group", "watch_group", "assets", "watch_assets", "ios_build",
        "watch_build", "ios_sources_phase", "watch_sources_phase",
        "ios_frameworks", "watch_frameworks", "embed_watch", "ios_plist",
        "watch_plist", "ios_ent", "watch_ent", "ios_debug", "ios_release",
        "watch_debug", "watch_release", "proj_debug", "proj_release",
        "project_root", "root", "proxy", "dep_watch", "ios_resources",
        "watch_resources", "proj_configs", "embed_bf", "assets_ios", "assets_watch",
    ]}
    for path in set(ios_sources + watch_sources):
        ids[path] = uid(path)

    unique_paths = sorted(set(ios_sources + watch_sources), key=lambda p: p)
    file_refs = []
    for path in unique_paths:
        base = os.path.basename(path)
        file_refs.append(
            f"\t\t{ids[path]} /* {base} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {path}; sourceTree = SOURCE_ROOT; }};"
        )

    extra_refs = [
        f"\t\t{ids['ios_app']} /* StefanoCyclingPro.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = StefanoCyclingPro.app; sourceTree = BUILT_PRODUCTS_DIR; }};",
        f"\t\t{ids['watch_app']} /* StefanoCyclingProWatch.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = StefanoCyclingProWatch.app; sourceTree = BUILT_PRODUCTS_DIR; }};",
        f"\t\t{ids['assets']} /* AppAssets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets/AppAssets.xcassets; sourceTree = \"<group>\"; }};",
        f"\t\t{ids['watch_assets']} /* WatchAssets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets/WatchAssets.xcassets; sourceTree = \"<group>\"; }};",
        f"\t\t{ids['ios_plist']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Config/Info.plist; sourceTree = \"<group>\"; }};",
        f"\t\t{ids['watch_plist']} /* WatchInfo.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Config/WatchInfo.plist; sourceTree = \"<group>\"; }};",
        f"\t\t{ids['ios_ent']} /* StefanoCyclingPro.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = Config/StefanoCyclingPro.entitlements; sourceTree = \"<group>\"; }};",
        f"\t\t{ids['watch_ent']} /* StefanoCyclingProWatch.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = Config/StefanoCyclingProWatch.entitlements; sourceTree = \"<group>\"; }};",
    ]

    ios_bf = []
    for path in ios_sources:
        bf = uid("bf" + path)
        ios_bf.append(
            f"\t\t{bf} /* {os.path.basename(path)} in Sources */ = {{isa = PBXBuildFile; fileRef = {ids[path]} /* {os.path.basename(path)} */; }};"
        )

    watch_bf = []
    for path in watch_sources:
        bf = uid("wbf" + path)
        watch_bf.append(
            f"\t\t{bf} /* {os.path.basename(path)} in Sources */ = {{isa = PBXBuildFile; fileRef = {ids[path]} /* {os.path.basename(path)} */; }};"
        )

    ios_sources_list = "\n".join(
        f"\t\t\t\t{uid('bf' + path)} /* {os.path.basename(path)} in Sources */," for path in ios_sources
    )
    watch_sources_list = "\n".join(
        f"\t\t\t\t{uid('wbf' + path)} /* {os.path.basename(path)} in Sources */," for path in watch_sources
    )

    ios_children = "\n".join(f"\t\t\t\t{ids[p]} /* {os.path.basename(p)} */," for p in ios_sources)
    watch_only = [p for p in watch_sources if p not in ios_sources]
    watch_children = "\n".join(f"\t\t\t\t{ids[p]} /* {os.path.basename(p)} */," for p in watch_only)

    content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(ios_bf)}
{chr(10).join(watch_bf)}
\t\t{ids['embed_bf']} /* StefanoCyclingProWatch.app in Embed Watch Content */ = {{isa = PBXBuildFile; fileRef = {ids['watch_app']} /* StefanoCyclingProWatch.app */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
\t\t{ids['assets_ios']} /* AppAssets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ids['assets']} /* AppAssets.xcassets */; }};
\t\t{ids['assets_watch']} /* WatchAssets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ids['watch_assets']} /* WatchAssets.xcassets */; }};
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
\t\t{ids['proxy']} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {ids['project_root']} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {ids['watch_target']};
\t\t\tremoteInfo = StefanoCyclingProWatch;
\t\t}};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
\t\t{ids['embed_watch']} /* Embed Watch Content */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "$(CONTENTS_FOLDER_PATH)/Watch";
\t\t\tdstSubfolderSpec = 16;
\t\t\tfiles = (
\t\t\t\t{ids['embed_bf']} /* StefanoCyclingProWatch.app in Embed Watch Content */,
\t\t\t);
\t\t\tname = "Embed Watch Content";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
{chr(10).join(extra_refs)}
/* End PBXFileReference section */

/* Begin PBXGroup section */
\t\t{ids['ios_group']} /* iOS Sources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{ios_children}
\t\t\t);
\t\t\tname = "iOS Sources";
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['watch_group']} /* watchOS Sources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{watch_children}
\t\t\t);
\t\t\tname = "watchOS Sources";
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['root']} /* Root */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{ids['ios_group']} /* iOS Sources */,
\t\t\t\t{ids['watch_group']} /* watchOS Sources */,
\t\t\t\t{ids['assets']} /* AppAssets.xcassets */,
\t\t\t\t{ids['watch_assets']} /* WatchAssets.xcassets */,
\t\t\t\t{ids['ios_plist']} /* Info.plist */,
\t\t\t\t{ids['watch_plist']} /* WatchInfo.plist */,
\t\t\t\t{ids['ios_ent']} /* StefanoCyclingPro.entitlements */,
\t\t\t\t{ids['watch_ent']} /* StefanoCyclingProWatch.entitlements */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['project']} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{ids['ios_app']} /* StefanoCyclingPro.app */,
\t\t\t\t{ids['watch_app']} /* StefanoCyclingProWatch.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{ids['ios_frameworks']} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['watch_frameworks']} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXNativeTarget section */
\t\t{ids['ios_target']} /* StefanoCyclingPro */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {ids['ios_build']} /* Build configuration list for PBXNativeTarget "StefanoCyclingPro" */;
\t\t\tbuildPhases = (
\t\t\t\t{ids['ios_sources_phase']} /* Sources */,
\t\t\t\t{ids['ios_frameworks']} /* Frameworks */,
\t\t\t\t{ids['ios_resources']} /* Resources */,
\t\t\t\t{ids['embed_watch']} /* Embed Watch Content */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{ids['dep_watch']} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = StefanoCyclingPro;
\t\t\tproductName = StefanoCyclingPro;
\t\t\tproductReference = {ids['ios_app']} /* StefanoCyclingPro.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{ids['watch_target']} /* StefanoCyclingProWatch */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {ids['watch_build']} /* Build configuration list for PBXNativeTarget "StefanoCyclingProWatch" */;
\t\t\tbuildPhases = (
\t\t\t\t{ids['watch_sources_phase']} /* Sources */,
\t\t\t\t{ids['watch_frameworks']} /* Frameworks */,
\t\t\t\t{ids['watch_resources']} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = StefanoCyclingProWatch;
\t\t\tproductName = StefanoCyclingProWatch;
\t\t\tproductReference = {ids['watch_app']} /* StefanoCyclingProWatch.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{ids['project_root']} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{ids['ios_target']} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t\t{ids['watch_target']} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {ids['proj_configs']} /* Build configuration list for PBXProject "StefanoCyclingPro" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {ids['root']} /* Root */;
\t\t\tproductRefGroup = {ids['project']} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{ids['ios_target']} /* StefanoCyclingPro */,
\t\t\t\t{ids['watch_target']} /* StefanoCyclingProWatch */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{ids['ios_resources']} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{ids['assets_ios']} /* AppAssets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['watch_resources']} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{ids['assets_watch']} /* WatchAssets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{ids['ios_sources_phase']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{ios_sources_list}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['watch_sources_phase']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{watch_sources_list}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
\t\t{ids['dep_watch']} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {ids['watch_target']} /* StefanoCyclingProWatch */;
\t\t\ttargetProxy = {ids['proxy']} /* PBXContainerItemProxy */;
\t\t}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\t{ids['ios_debug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Config/StefanoCyclingPro.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Config/Info.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = StefanoCyclingPro;
\t\t\t\tINFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.sports";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.stefanociancimino.StefanoCyclingPro;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['ios_release']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Config/StefanoCyclingPro.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Config/Info.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = StefanoCyclingPro;
\t\t\t\tINFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.sports";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.stefanociancimino.StefanoCyclingPro;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{ids['watch_debug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Config/StefanoCyclingProWatch.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Config/WatchInfo.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = StefanoCyclingPro;
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.stefanociancimino.StefanoCyclingPro.watchkitapp;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = watchos;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 4;
\t\t\t\tWATCHOS_DEPLOYMENT_TARGET = 10.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['watch_release']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Config/StefanoCyclingProWatch.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Config/WatchInfo.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = StefanoCyclingPro;
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.stefanociancimino.StefanoCyclingPro.watchkitapp;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = watchos;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 4;
\t\t\t\tWATCHOS_DEPLOYMENT_TARGET = 10.0;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{ids['proj_debug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['proj_release']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{ids['ios_build']} /* Build configuration list for PBXNativeTarget "StefanoCyclingPro" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['ios_debug']} /* Debug */,
\t\t\t\t{ids['ios_release']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{ids['watch_build']} /* Build configuration list for PBXNativeTarget "StefanoCyclingProWatch" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['watch_debug']} /* Debug */,
\t\t\t\t{ids['watch_release']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{ids['proj_configs']} /* Build configuration list for PBXProject "StefanoCyclingPro" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['proj_debug']} /* Debug */,
\t\t\t\t{ids['proj_release']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {ids['project_root']} /* Project object */;
}}
"""

    out_path = os.path.join(ROOT, "StefanoCyclingPro.xcodeproj", "project.pbxproj")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as handle:
        handle.write(content)
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()