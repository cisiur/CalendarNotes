# 09 — Toolchain (CN-01)

The initial scaffold targets Flutter stable **3.29.3** (Dart **3.7.2**) for
Android and Windows. GitHub Actions installs that exact Flutter SDK; package
versions are declared explicitly in `pubspec.yaml` and the resolution is
recorded in `pubspec.lock` after `flutter pub get`.

Required local commands:

```text
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Android builds require a Flutter-compatible Android SDK and JDK 17. Windows
builds require Visual Studio with the Desktop development with C++ workload.

CN-01 deliberately contains no database, exchange-folder adapter, file
publication, synchronization, export or analytics implementation.
