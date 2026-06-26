---
date: 2026-06-26
type: fix
origin: docs/brainstorms/2026-06-26-android-built-in-kotlin-requirements.md
---

# Plan: Android built-in Kotlin migration (cm_cmp_sdk_v3 3.12.0)

## Summary

Remove direct Kotlin Gradle Plugin application from the plugin and example app Android Gradle files, adopt Flutter's built-in Kotlin pattern, bump minimum Flutter/Dart constraints, and validate with an AGP 9+ example build for release **3.12.0**.

---

## Problem Frame

Support reported that `cm_cmp_sdk_v3` applies KGP in `android/build.gradle`, which Flutter flags as unsupported and which breaks on AGP 9+ customer apps. The fix is a Gradle integration change only — no Dart API changes.

---

## Requirements Traceability

| ID | Plan coverage |
|----|----------------|
| R1 | U1 — remove KGP classpath and `kotlin-android` from plugin Gradle |
| R2 | U1 — replace `kotlinOptions` with top-level `kotlin { compilerOptions {} }` |
| R3 | U3 — existing Kotlin unit test + example app smoke path |
| R4 | U2 — `pubspec.yaml` Flutter/Dart minimum bump |
| R5 | U4 — version 3.12.0 + changelog note |
| R6 | U3 — example app Gradle migration + AGP 9+ build validation |

---

## Key Technical Decisions

- **KTD1: Remove plugin buildscript AGP/KGP classpaths** — Review flagged that keeping AGP 7.4.2 in the plugin `buildscript` conflicts with built-in Kotlin. Remove the entire `buildscript` block and let the host Flutter app supply AGP/Kotlin. This is a minimal scope expansion beyond “KGP only” but required for R1/R2 to work in practice.
- **KTD2: Keep JVM target 11** — Plugin already uses Java 11 (`compileOptions` and current `jvmTarget "11"`). Stay on JVM 11 in `compilerOptions` to avoid an unrelated bytecode bump; Flutter examples use 17 for greenfield apps, not a mandate for this plugin.
- **KTD3: Upgrade example app to AGP 9.x** — `example/android/settings.gradle` currently pins AGP 8.9.1 while R6/AE1 require AGP 9+. Bump example Android tooling to AGP 9+ for validation fidelity.
- **KTD4: Changelog via external docs process** — In-repo `CHANGELOG.md` redirects to ConsentManager help site. Add a brief in-repo stub entry linking to the external changelog and coordinate the full entry on help.consentmanager.net per existing release process.

---

## Implementation Units

### U1. Migrate plugin `android/build.gradle` to built-in Kotlin

**Goal:** Satisfy R1 and R2.

**Files:**
- `android/build.gradle`

**Approach:**
1. Remove `buildscript` block (AGP 7.4.2 + KGP 1.9.0 classpaths).
2. Remove `apply plugin: 'kotlin-android'`.
3. Remove `kotlinOptions` from the `android` block.
4. Add top-level Groovy block:

```groovy
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}
```

5. Keep `apply plugin: 'com.android.library'`, namespace, compileSdk, sourceSets, dependencies, and testOptions unchanged unless build failure requires adjustment.
6. Move `dependencies { ... }` out of the `android { }` block if Gradle complains (currently nested inside `android`, which is non-standard but pre-existing).

**Patterns:** Follow [Flutter built-in Kotlin migration for plugin authors](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors) (legacy Groovy `apply` path).

**Test scenarios:**
- Gradle sync / plugin module compiles Kotlin sources under `android/src/main/kotlin`.
- No `kotlin-android` apply and no `kotlin-gradle-plugin` on classpath in `android/build.gradle`.

**Verification:** Static inspection of `android/build.gradle`; run existing `android/src/test/kotlin/.../CmpSdkPluginTest.kt` if Gradle test task works in isolation.

---

### U2. Bump package constraints and version

**Goal:** Satisfy R4 and prepare R5.

**Files:**
- `pubspec.yaml`

**Approach:**
1. Set `version: 3.12.0`.
2. Set `environment.sdk: ^3.12.0`.
3. Set `environment.flutter: ">=3.44.0"`.

**Test scenarios:**
- `flutter pub get` on Flutter 3.44+ succeeds.
- On Flutter <3.44, pub resolution fails with constraint message.

**Verification:** `flutter pub get` at repo root with current Flutter SDK.

---

### U3. Migrate example app Android Gradle and validate

**Goal:** Satisfy R3 and R6.

**Files:**
- `example/android/settings.gradle` — bump AGP to 9.x (align with Flutter 3.44 defaults)
- `example/android/build.gradle` — remove KGP classpath from buildscript
- `example/android/app/build.gradle` — remove `kotlin-android`, replace `kotlinOptions` with built-in Kotlin `compilerOptions` (or rely on AGP built-in defaults if app-level Kotlin config is unnecessary after migration)

**Approach:**
1. Remove KGP from `example/android/build.gradle` buildscript.
2. Migrate `example/android/app/build.gradle` per Flutter app-developer built-in Kotlin guidance (remove `kotlin-android`, use `kotlin { compilerOptions {} }` if JVM target still needed).
3. Upgrade AGP in `example/android/settings.gradle` to **9.x** so AE1/R6 preconditions hold.
4. Run `flutter build apk` from `example/` on Flutter 3.44+.
5. Confirm no Flutter warning that `cm_cmp_sdk_v3` applies KGP.

**Test scenarios:**
- `flutter build apk` succeeds in `example/`.
- No KGP warning for `cm_cmp_sdk_v3`.
- Example app launches on Android emulator/device (smoke test for R3 — existing Dart API paths still work).

**Verification:** Build log inspection + manual smoke of example app consent flow if device available.

---

### U4. Release notes

**Goal:** Satisfy R5.

**Files:**
- `CHANGELOG.md`

**Approach:**
1. Add **3.12.0** section noting:
   - Migrated Android integration to built-in Kotlin (no direct KGP application).
   - Minimum Flutter `>=3.44.0`, Dart `^3.12.0`.
   - Link to external changelog on help.consentmanager.net for full release notes.
2. Coordinate external changelog entry with release process (outside repo if required by team workflow).

**Verification:** Changelog section present with correct minimum versions.

---

## Sequencing

1. U1 (plugin Gradle) — core fix
2. U2 (pubspec/version) — constraint alignment
3. U3 (example + validation) — proves fix end-to-end
4. U4 (changelog) — support handoff

---

## Risks and Dependencies

| Risk | Mitigation |
|------|------------|
| Removing plugin buildscript breaks standalone Gradle evaluation | Validate via `flutter build apk` in example (composite build path customers use) |
| AGP 9 example upgrade surfaces unrelated Gradle drift | Limit changes to KGP/built-in Kotlin + AGP version bump only |
| Customers on Flutter <3.44 cannot adopt 3.12.0 | Document in changelog; support tells them to stay on 3.11.x until Flutter upgrade |
| External changelog lag | In-repo stub entry still states minimums for pub.dev readers |

---

## Out of Scope

- Full migration of plugin `build.gradle` to `plugins {}` DSL
- Native SDK version alignment between plugin and example
- iOS changes
- Conditional KGP path for Flutter <3.44

---

## Support Response Template

> Fix for KGP application is included in **cm_cmp_sdk_v3 3.12.0**. Requires **Flutter >=3.44.0** (Dart ^3.12.0). Upgrade Flutter, then upgrade the plugin. Apps that cannot upgrade Flutter should remain on **3.11.x** until they can.
