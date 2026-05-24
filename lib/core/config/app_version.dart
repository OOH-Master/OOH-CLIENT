/// App version info injected at build time via --dart-define.
///
/// In CI/CD workflow, the build step passes:
///   --dart-define=APP_VERSION=v1.0.0
///   --dart-define=APP_BUILD_TIME=2026-05-24T13:00:00Z
///
/// Used by footer + about dialog to show deployed version on landing page.
class AppVersion {
  AppVersion._();

  /// Git tag from CI/CD (e.g. "v1.0.0"). Defaults to "dev" for local builds.
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'dev',
  );

  /// UTC build timestamp from CI/CD (ISO 8601). Defaults to "local" for local builds.
  static const String buildTime = String.fromEnvironment(
    'APP_BUILD_TIME',
    defaultValue: 'local',
  );

  /// Short display label — "v1.0.0 · 2026-05-24"
  static String get displayLabel {
    if (buildTime == 'local') return version;
    // Take only date part of ISO timestamp (first 10 chars)
    final datePart = buildTime.length >= 10 ? buildTime.substring(0, 10) : buildTime;
    return '$version · $datePart';
  }
}
