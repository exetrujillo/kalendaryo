// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import '../entities/event.dart';
import '../repositories/event_repository.dart';

class Countdown {
  const Countdown(this.event, this.daysRemaining);
  final Event event;
  final int daysRemaining;
}


class GetCountdowns {
  const GetCountdowns(this._repository);
  final EventRepository _repository;

  Stream<List<Countdown>> watch({DateTime? now}) {
    final reference = now ?? DateTime.now();
    return _repository.watchUpcoming().map(
          (events) => events
              .map((e) => Countdown(e, e.daysRemainingFrom(reference)))
              .toList(),
        );
  }
}
