<!--
SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Reproducible Builds

Kalendaryo se distribuye **F-Droid first**. F-Droid compila la app desde el
código fuente y la verifica reconstruyéndola: el APK resultante debe coincidir,
byte a byte (salvo la firma), con cualquier otra compilación del mismo commit.
Este documento describe cómo garantizamos ese determinismo.

## Fuentes de no-determinismo y cómo las neutralizamos

| Fuente | Riesgo | Mitigación |
| --- | --- | --- |
| Bloque de metadatos de dependencias de AGP | Blob **firmado por Google**, no libre y variable entre máquinas | `dependenciesInfo { includeInApk = false; includeInBundle = false }` en `android/app/build.gradle` |
| Marcas de tiempo en el ZIP/DEX | APK distinto en cada compilación | `SOURCE_DATE_EPOCH=1` + ordenamiento/timestamps fijos de AGP 8.x |
| Bloque de firma (`META-INF/`) | Depende de la clave; F-Droid re-firma | La verificación compara el contenido **excluyendo `META-INF/`** |
| Ofuscación / shrink | R8 puede introducir variación | `minifyEnabled = false`, `shrinkResources = false` |
| Jetifier | Reescritura no determinista de libs | `android.enableJetifier=false` (todo es AndroidX puro) |
| Toolchain | Versiones distintas -> bytes distintos | Pinned: Gradle 8.7, AGP 8.3.0, Kotlin 1.9.23, JDK 17, Flutter `stable` |

## Sin red, sin GMS

El manifest de `release`/`main` **no** declara `INTERNET` (solo `debug`/`profile`
lo hacen, para el VM Service de Dart). No hay Google Play Services, Firebase ni
`google-services.json`; la receta de F-Droid incluye `rm:` de ese archivo como
garantía adicional.

## Verificación en CI

El workflow `.github/workflows/build.yml` compila el APK **dos veces** (con
`flutter clean` entre medias) y compara su contenido ignorando `META-INF/`. Si
las dos compilaciones difieren, el job falla.

Reproducir localmente (en una máquina con el toolchain Flutter):

```sh
export SOURCE_DATE_EPOCH=1
flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk /tmp/a.apk
flutter clean
flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk /tmp/b.apk

mkdir -p /tmp/a /tmp/b
unzip -q /tmp/a.apk -d /tmp/a -x 'META-INF/*'
unzip -q /tmp/b.apk -d /tmp/b -x 'META-INF/*'
diff -r /tmp/a /tmp/b && echo "Reproducible ✔"
```

## Receta de F-Droid

`metadata/cl.exetrujillo.kalendaryo.yml` es el borrador de la receta. Notas:

- **Sin `subdir`**: el proyecto Flutter (`pubspec.yaml`) vive en la raíz del
  repo; ahí debe ejecutarse `flutter build`. `output` es relativo a esa raíz.
- `srclibs: flutter@stable` provee el SDK; el NDK lo fija `flutter.ndkVersion`.
- No se requiere `sudo`/`lib32stdc++6`: Flutter stable moderno trae binarios de
  64 bits. (Si una compilación en el buildserver de F-Droid se quejara de libs
  de 32 bits, reintroducir `sudo: apt-get install -y lib32stdc++6`.)
