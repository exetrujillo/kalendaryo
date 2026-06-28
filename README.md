<!--
SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Kalendaryo

**Cuenta regresiva de eventos en tu pantalla de inicio — 100 % local, 100 % libre.**

Kalendaryo registra eventos y muestra, mediante un *widget* de pantalla de inicio,
cuántos días faltan para cada uno. Todo el cálculo y el almacenamiento ocurren en
tu dispositivo. **Sin cuentas, sin nube, sin telemetría, sin rastreadores.**

## Filosofía (Zero-Register / Local-First)

- 🔒 **Sin backend ni APIs centralizadas.** No hay servidor que contactar.
- 🛡️ **Datos cifrados en el dispositivo** (SQLCipher + clave en el Keystore).
- 📡 **Cero permiso de red.** El widget se actualiza a medianoche con `AlarmManager`
  nativo, no con notificaciones push (sin Firebase/FCM).
- 🆓 **Software Libre (GPL-3.0-or-later).** Garantiza las 4 libertades de la FSF.
- 📦 **F-Droid first.** Construible 100 % desde fuente, sin blobs propietarios.

## Anti-Features (declaradas para F-Droid)

Ninguna. El objetivo explícito es **cero** anti-features: sin `NonFreeNet`,
sin `Tracking`, sin `NonFreeDep`, sin `UpstreamNonFree`.

## Stack

| Capa | Tecnología | Licencia |
|------|-----------|----------|
| UI | Flutter (sin Play Services) | BSD-3 |
| Estado | Riverpod | MIT |
| Persistencia | drift + SQLCipher | MIT / BSD |
| Puente widget | `home_widget` | MIT |
| Widget nativo | Kotlin · AppWidgetProvider · AlarmManager · WorkManager | Apache-2.0 (AndroidX) |

## Compilar desde fuente

```bash
flutter pub get
flutter build apk --release
```

## Conformidad de licencias

Este repositorio sigue la especificación [REUSE](https://reuse.software/).
Verifica que todos los archivos tengan licencia válida con:

```bash
reuse lint
```

## Licencia

Copyright (C) 2026 Exequiel Trujillo.

Este programa es software libre: puedes redistribuirlo y/o modificarlo bajo los
términos de la GNU General Public License publicada por la Free Software
Foundation, ya sea la versión 3 de la Licencia o (a tu elección) cualquier
versión posterior. Ver [`LICENSE`](./LICENSE).
