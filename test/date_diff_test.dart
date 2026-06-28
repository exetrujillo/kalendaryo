// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kalendaryo/core/utils/date_diff.dart';

void main() {
  group('DateDiff', () {
    test('toEpochDay y fromEpochDay son inversos (normalizado a medianoche)',
        () {
      final date = DateTime(2026, 6, 28, 15, 42);
      final epochDay = DateDiff.toEpochDay(date);
      expect(DateDiff.fromEpochDay(epochDay), DateTime(2026, 6, 28));
    });

    test('daysRemaining: hoy es 0', () {
      final now = DateTime(2026, 6, 28, 9, 0);
      final today = DateDiff.toEpochDay(now);
      expect(DateDiff.daysRemaining(today, now), 0);
    });

    test('daysRemaining: mañana es 1, ayer es -1', () {
      final now = DateTime(2026, 6, 28, 23, 59);
      final tomorrow = DateDiff.toEpochDay(DateTime(2026, 6, 29));
      final yesterday = DateDiff.toEpochDay(DateTime(2026, 6, 27));
      expect(DateDiff.daysRemaining(tomorrow, now), 1);
      expect(DateDiff.daysRemaining(yesterday, now), -1);
    });
  });
}
