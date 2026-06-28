<!--
SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Cómo contribuir a Kalendaryo

¡Gracias por tu interés! Kalendaryo es software libre y se construye en comunidad.

## Principios no negociables

1. **Local-First estricto.** Ninguna contribución puede introducir llamadas de red,
   telemetría, ni dependencias de servicios propietarios (Firebase, GMS, Analytics…).
2. **Solo dependencias libres.** Toda librería nueva debe tener una licencia
   compatible con GPL-3.0-or-later y estar disponible como fuente para F-Droid.
3. **Compatibilidad con F-Droid.** No se aceptan binarios precompilados ni blobs.

## Licenciamiento de tus aportes

Al enviar un *patch* aceptas que tu contribución se licencie bajo
**GPL-3.0-or-later**. Añade a cada archivo nuevo la cabecera SPDX:

```
// SPDX-FileCopyrightText: <año> <Tu Nombre> <tu@correo>
// SPDX-License-Identifier: GPL-3.0-or-later
```

Firma tus commits con DCO (`git commit -s`).

## Antes de abrir un Pull Request

```bash
reuse lint            # licencias OK
flutter analyze       # estático
flutter test          # pruebas
```
