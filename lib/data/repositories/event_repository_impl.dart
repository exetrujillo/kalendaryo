// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../../core/utils/date_diff.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../database/app_database.dart';

/// Implementación de [EventRepository] respaldada por la BD cifrada (drift).
/// Traduce entre filas de la tabla y entidades del dominio.
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<Event>> watchUpcoming() {
    final query = _db.select(_db.events)
      ..orderBy([(t) => OrderingTerm.asc(t.targetEpochDay)]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<Event>> getAll() async {
    final rows = await _db.select(_db.events).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Event?> getById(int id) async {
    final row = await (_db.select(_db.events)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create(Event event) {
    return _db.into(_db.events).insert(_toCompanion(event));
  }

  @override
  Future<void> update(Event event) async {
    await (_db.update(_db.events)..where((t) => t.id.equals(event.id!)))
        .write(_toCompanion(event));
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.events)..where((t) => t.id.equals(id))).go();
  }

  // ---- Mapeo fila <-> entidad ----

  Event _toEntity(EventsData row) => Event(
        id: row.id,
        title: row.title,
        description: row.description,
        targetDate: DateDiff.fromEpochDay(row.targetEpochDay),
        colorArgb: row.colorArgb,
        allDay: row.allDay,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMillis),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAtMillis),
      );

  EventsCompanion _toCompanion(Event e) => EventsCompanion(
        id: e.id == null ? const Value.absent() : Value(e.id!),
        title: Value(e.title),
        description: Value(e.description),
        targetEpochDay: Value(DateDiff.toEpochDay(e.targetDate)),
        targetTimeMillis: Value(
          e.allDay ? null : e.targetDate.toUtc().millisecondsSinceEpoch,
        ),
        colorArgb: Value(e.colorArgb),
        allDay: Value(e.allDay),
        createdAtMillis: Value(e.createdAt.millisecondsSinceEpoch),
        updatedAtMillis: Value(e.updatedAt.millisecondsSinceEpoch),
      );
}
