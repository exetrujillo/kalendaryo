// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import 'providers.dart';

/// Encapsula las mutaciones de eventos y la gestión de timestamps.
///
/// No toca el widget nativo directamente: el repintado lo dispara el listener
/// reactivo de [countdownsProvider] en la raíz de la app, de modo que toda
/// escritura en la BD se propaga al widget sin acoplar este controlador al
/// puente nativo.
class EventController extends Notifier<void> {
  @override
  void build() {}

  EventRepository get _repo => ref.read(eventRepositoryProvider);

  /// Normaliza la fecha a medianoche local para eventos de día completo.
  static DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> createEvent({
    required String title,
    String? description,
    required DateTime targetDate,
    int? colorArgb,
  }) async {
    final now = DateTime.now();
    await _repo.create(
      Event(
        title: title.trim(),
        description: _blankToNull(description),
        targetDate: _normalize(targetDate),
        colorArgb: colorArgb,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateEvent(
    Event original, {
    required String title,
    String? description,
    required DateTime targetDate,
    int? colorArgb,
  }) async {
    await _repo.update(
      Event(
        id: original.id,
        title: title.trim(),
        description: _blankToNull(description),
        targetDate: _normalize(targetDate),
        colorArgb: colorArgb,
        allDay: original.allDay,
        createdAt: original.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteEvent(int id) => _repo.delete(id);

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
