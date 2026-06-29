// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

class DateDiff {
  const DateDiff._();

  /// Número de día calendario (días desde 1970-01-01) del [date] dado.
  ///
  /// La aritmética se hace en UTC a propósito: `Duration(days:)` asume días de
  /// 24 h exactas, lo que se rompe en transiciones de horario de verano (DST)
  /// si se opera en hora local. Tomamos los componentes de fecha locales y los
  /// anclamos a medianoche UTC, donde la diferencia en días es siempre exacta.
  static int toEpochDay(DateTime date) {
    final utcMidnight = DateTime.utc(date.year, date.month, date.day);
    return utcMidnight.difference(DateTime.utc(1970)).inDays;
  }

  /// Inverso de [toEpochDay]: la medianoche local del día calendario [epochDay].
  static DateTime fromEpochDay(int epochDay) {
    final utc = DateTime.utc(1970).add(Duration(days: epochDay));
    return DateTime(utc.year, utc.month, utc.day);
  }

  static int daysRemaining(int targetEpochDay, DateTime now) =>
      targetEpochDay - toEpochDay(now);
}
