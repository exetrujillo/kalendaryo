<!--
SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Changelog

Todas las modificaciones notables se documentan aquí. El formato sigue
[Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto adopta
[Versionado Semántico](https://semver.org/lang/es/).

## [No publicado]

## [0.1.2] - 2026-07-01

### Añadido
- El widget de pantalla de inicio ahora lista múltiples eventos (hasta 4) de forma simultánea.
- Rediseño visual del widget a un estilo más moderno (fondo oscuro redondeado semi-transparente, textos mejor contrastados).

### Corregido
- El widget ahora recalcula correctamente los días restantes a medianoche, usando la fecha absoluta del evento y no el número estático del momento en que se guardó.
## [0.1.1] - 2026-06-29

### Corregido
- La base de datos no abría en el dispositivo (`Failed to load dynamic library
  libsqlite3.so`): el override a SQLCipher se aplicaba en el isolate principal,
  pero `createInBackground` abre la BD en otro isolate. Movido a `isolateSetup`.

## [0.1.0] - 2026-06-28

### Añadido
- Esqueleto del proyecto (Clean Architecture: domain / data / presentation).
- Esquema de base de datos local cifrada para eventos (drift + SQLCipher), con
  la clave en el Android Keystore vía `flutter_secure_storage`.
- Interfaz de eventos con Riverpod: lista de cuentas regresivas ordenada por días
  restantes, alta/edición/borrado y selector de color con paleta fija.
- Sincronización reactiva del widget: cualquier cambio en la base de datos
  dispara la actualización del widget vía un `StreamProvider` en la raíz.
- Lógica nativa del widget de cuenta regresiva (AppWidgetProvider + AlarmManager
  a medianoche, con WorkManager como red de seguridad; sin FCM ni GMS).
- Garantía Local-First: sin permiso `INTERNET` en release (solo en debug/profile
  para el VM Service de Dart).
- Reproducible Builds para F-Droid: exclusión del bloque de metadatos de
  dependencias de AGP (`dependenciesInfo`), verificación de determinismo en CI
  (doble compilación + diff) y borrador de receta de F-Droid.
- Conformidad REUSE y licencia GPL-3.0-or-later.
