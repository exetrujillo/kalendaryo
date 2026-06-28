// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

part 'app_database.g.dart'; // Generado por build_runner (no se versiona).

/// Esquema de la tabla de eventos.
///
/// Diseño orientado al cálculo de cuenta regresiva: [targetEpochDay] guarda el
/// día como entero (días desde epoch en hora local) para que ordenar y filtrar
/// "próximos eventos" sea un simple índice entero, sin aritmética de fechas en
/// SQL ni dependencias de zona horaria del motor.
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  TextColumn get description => text().nullable()();

  /// Día objetivo como días enteros desde epoch (local). Indexado para orden.
  IntColumn get targetEpochDay => integer()();

  /// Timestamp exacto opcional (eventos con hora). Epoch millis UTC.
  IntColumn get targetTimeMillis => integer().nullable()();

  /// Color de acento ARGB para el widget. Null = tema por defecto.
  IntColumn get colorArgb => integer().nullable()();

  BoolColumn get allDay => boolean().withDefault(const Constant(true))();

  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();
}

@DriftDatabase(tables: [Events])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Índice para "próximos eventos" ordenados por día.
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_events_target '
            'ON events (target_epoch_day);',
          );
        },
      );

  /// Abre la BD cifrada con SQLCipher. La clave de 256 bits se genera una vez
  /// y se custodia en el almacenamiento seguro del SO (Android Keystore), nunca
  /// en disco en claro ni en código.
  static LazyDatabase openConnection() {
    return LazyDatabase(() async {
      // Carga las librerías nativas de SQLCipher en lugar de SQLite estándar.
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'kalendaryo.db'));
      final key = await _resolveEncryptionKey();

      return NativeDatabase.createInBackground(
        dbFile,
        setup: (rawDb) {
          // PRAGMA key DEBE ser lo primero tras abrir la conexión.
          rawDb.execute("PRAGMA key = '$key';");
          // Verifica que la clave es correcta (lanza si está mal).
          rawDb.execute('SELECT count(*) FROM sqlite_master;');
        },
      );
    });
  }

  static const _keyName = 'kalendaryo_db_key';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String> _resolveEncryptionKey() async {
    var key = await _secureStorage.read(key: _keyName);
    if (key == null) {
      // Primera ejecución: generamos una clave de 256 bits y la custodiamos
      // en el Keystore. SQLCipher la espera como hex de 64 caracteres.
      key = _generateHexKey();
      await _secureStorage.write(key: _keyName, value: key);
    }
    return key;
  }

  static String _generateHexKey() {
    final rng = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 32; i++) {
      buffer.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
