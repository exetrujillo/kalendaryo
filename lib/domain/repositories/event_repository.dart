// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import '../entities/event.dart';

abstract interface class EventRepository {
  Stream<List<Event>> watchUpcoming();

  Future<List<Event>> getAll();

  Future<Event?> getById(int id);

  Future<int> create(Event event);

  Future<void> update(Event event);

  Future<void> delete(int id);
}
