// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/get_countdowns.dart';
import 'event_controller.dart';

/// Provee la BD cifrada como singleton para toda la app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(AppDatabase.openConnection());
  ref.onDispose(db.close);
  return db;
});

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepositoryImpl(ref.watch(databaseProvider)),
);

final getCountdownsProvider = Provider<GetCountdowns>(
  (ref) => GetCountdowns(ref.watch(eventRepositoryProvider)),
);

/// Stream reactivo de cuentas regresivas, ya ordenadas por días restantes.
/// Es la única fuente de verdad de la UI; cualquier alta/edición/borrado se
/// refleja aquí y, vía el listener en la raíz, vuelca los datos al widget.
final countdownsProvider = StreamProvider<List<Countdown>>(
  (ref) => ref.watch(getCountdownsProvider).watch(),
);

/// Controlador de mutaciones (alta/edición/borrado) de eventos.
final eventControllerProvider =
    NotifierProvider<EventController, void>(EventController.new);
