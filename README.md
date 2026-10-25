# TrachCare

TrachCare is a Flutter application for patients, doctors, and administrators to
manage tracheostomy care, daily reports, and therapy content. The PHP backend
sources are in `backend_upload/Trachcare`.

## Development

Install Flutter, then fetch dependencies and run the app:

```sh
flutter pub get
flutter run
```

To use a different backend, provide its base URL at build or run time:

```sh
flutter run --dart-define=API_BASE=http://localhost/Trachcare
```

Do not commit local signing credentials, machine-specific SDK settings, or
database exports containing patient information.
