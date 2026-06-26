---
date: 2026-06-26
topic: android-built-in-kotlin
---

# Requirements: Android built-in Kotlin migration

## Summary

Migrate `cm_cmp_sdk_v3` off direct Kotlin Gradle Plugin (KGP) application so customer apps remain buildable on current and future Flutter versions. Ship in release **3.12.0** with minimum Flutter **>=3.44.0** / Dart **^3.12.0**.

---

## Problem Frame

Flutter and Android Gradle Plugin (AGP) 9+ treat Kotlin as built-in. Plugins that still apply KGP directly trigger build warnings today and hard failures on AGP 9+ apps. Support reported that `cm_cmp_sdk_v3` applies KGP in its Android integration, putting customer apps at risk as Flutter removes temporary KGP compatibility.

The plugin's `android/build.gradle` uses legacy `buildscript` classpath wiring and `apply plugin: 'kotlin-android'`. That matches the failure mode Flutter documents for plugin authors.

---

## Key Decisions

- **Full built-in Kotlin migration** — Remove unconditional KGP application rather than conditional apply-for-AGP-less-than-9. Simpler maintenance and aligned with Flutter's primary recommendation.
- **Raise minimum Flutter to 3.44** — Required for the `kotlin { compilerOptions {} }` DSL and KGP 2.0+ baseline Flutter expects for built-in Kotlin.
- **Target release 3.12.0** — Minor bump because minimum SDK constraints change; treat as a compatibility release for support response.

---

## Requirements

**Android plugin integration**

- R1. The plugin must not apply `kotlin-android` or declare KGP on the buildscript classpath in `android/build.gradle`.
- R2. Remove `kotlinOptions` from the `android` block and configure JVM target via a top-level `kotlin { compilerOptions { ... } }` block per Flutter built-in Kotlin guidance.
- R3. The plugin must continue to compile its existing Kotlin sources under `android/src/main/kotlin` without behavioral changes to the Dart-facing API.

**Package constraints and release**

- R4. `pubspec.yaml` must require Flutter `>=3.44.0` and `environment.sdk: ^3.12.0` (Dart SDK paired with Flutter 3.44 per Flutter guidance).
- R5. Release **3.12.0** must document the migration and the new minimum Flutter/Dart versions in the plugin changelog entry.

**Validation**

- R6. The example app must be migrated off direct KGP application and validated on Flutter 3.44+ with an AGP 9+ Android toolchain so `flutter build apk` (or `flutter run` on Android) succeeds without Flutter KGP warnings attributable to this package.

---

## Acceptance Examples

- AE1. **Covers R1, R2, R6.**
  - **Given:** A clean checkout on Flutter 3.44+ with the example app configured for a current AGP 9+ Android toolchain.
  - **When:** The developer runs `flutter build apk` in `example/`.
  - **Then:** The build succeeds and Flutter does not warn that `cm_cmp_sdk_v3` applies KGP.

- AE2. **Covers R4.**
  - **Given:** An app pinned to Flutter 3.3.x (current published minimum).
  - **When:** The developer upgrades to `cm_cmp_sdk_v3` 3.12.0.
  - **Then:** Pub resolution fails because `pubspec.yaml` enforces Flutter `>=3.44.0` and `environment.sdk: ^3.12.0`.

---

## Success Criteria

- Support can tell the customer the fix ships in plugin version **3.12.0** with minimum Flutter **>=3.44.0** (not Dart SDK 3.12 alone).
- No plugin-induced KGP warning for `cm_cmp_sdk_v3` on a migrated example app build.
- Customer apps on Flutter 3.44+ and AGP 9+ can depend on the updated plugin without KGP application conflicts from this package.
- The **3.12.0** changelog entry documents the built-in Kotlin migration and states the new Flutter/Dart minimums.

---

## Scope Boundaries

**In scope**

- `android/build.gradle` built-in Kotlin migration
- `pubspec.yaml` minimum version bump
- Example app Android Gradle files needed for validation
- Version bump to 3.12.0 and changelog entry

**Deferred for later**

- Broader Gradle modernization (migrating plugin `build.gradle` from legacy `apply` to `plugins {}` block, aligning plugin AGP/Kotlin versions with the example app)
- Native Android SDK dependency version alignment between plugin and example
- iOS-side changes

**Outside this product's identity**

- Maintaining indefinite compatibility with Flutter versions below 3.44 via conditional KGP application

---

## Dependencies / Assumptions

- Flutter's plugin-author migration guide remains the authoritative reference: [Built-in Kotlin migration for plugin authors](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors).
- Customers affected by AGP 9+ / future Flutter builds can upgrade to Flutter 3.44+.
- Plugin Kotlin sources require no API changes; this is a Gradle integration fix only.

---

## Sources / Research

- Plugin applies KGP today in `android/build.gradle` (`apply plugin: 'kotlin-android'`, buildscript KGP classpath, `kotlinOptions`).
- Current published constraints: `pubspec.yaml` requires `flutter: '>=3.3.0'`; package version **3.11.0**.
- Example app partially modernized (`example/android/settings.gradle` declares Kotlin plugin apply false) but still classpath-applies KGP in `example/android/build.gradle` and uses `kotlin-android` in `example/android/app/build.gradle`.

---

## Deferred / Open Questions

### From 2026-06-26 review

- **AE1 Then clause does not verify compilerOptions DSL** — Acceptance Examples / AE1 vs R2 (P1, coherence, confidence 100)

  Build success and absence of KGP warnings do not prove `kotlinOptions` was removed and the top-level `kotlin { compilerOptions {} }` block was adopted; R2 could regress without a static Gradle check in AE1.

- **R3 has no acceptance example** — Requirements / R3 (P2, coherence, product-lens, confidence 100)

  No-behavior-change and Kotlin compilation continuity are untestable at release; a Gradle-only build pass could ship while native or Dart-facing behavior regresses.

- **Plugin AGP 7.4.2 may block R1/R2 without scope change** — Scope Boundaries vs Requirements / R1–R2 (P1, feasibility, confidence 100)

  Removing KGP and using `kotlin { compilerOptions {} }` assumes AGP built-in Kotlin from the host toolchain, but the plugin still pins AGP 7.4.2 in `android/build.gradle` while AGP alignment is explicitly deferred.

- **Example app AGP 8.9.1 vs AGP 9+ validation target** — Requirements / R6 vs example/android/settings.gradle (P1, feasibility, confidence 100)

  R6 and AE1 require AGP 9+, but the example app pins AGP 8.9.1 today, so validation may not exercise the primary failure mode the doc describes.

- **R1 may be insufficient without removing plugin AGP classpath** — Requirements / R1 (P1, feasibility, confidence 75)

  Flutter's built-in Kotlin migration often requires dropping the plugin-pinned AGP classpath so the host app supplies compilation; R1 only forbids KGP, not AGP buildscript wiring.

- **R5 changelog location is external, not in-repo** — Requirements / R5 vs CHANGELOG.md (P2, feasibility, confidence 75)

  R5 requires a 3.12.0 changelog entry, but the repository `CHANGELOG.md` redirects to external ConsentManager docs; the release process for that entry is unstated.

- **JVM target (11 vs 17) not decided in R2** — Requirements / R2 (P2, product-lens, confidence 75)

  The plugin currently targets JVM 11 while Flutter's author guide examples use JVM 17; R2 mandates the DSL shape but not the target, which affects customer JDK/toolchain expectations.

- **Support release timing not scheduled** — Success Criteria / Key Decisions (P2, product-lens, confidence 75)

  The doc names 3.12.0 as the support answer but does not set a publish date, prerelease path, or SLA for customers blocked before release.

