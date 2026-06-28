// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

class DateDiff {
  const DateDiff._();

  static int toEpochDay(DateTime date) {
    final midnight = DateTime(date.year, date.month, date.day);
    return midnight.difference(DateTime(1970)).inDays;
  }

  static DateTime fromEpochDay(int epochDay) =>
      DateTime(1970).add(Duration(days: epochDay));

  static int daysRemaining(int targetEpochDay, DateTime now) =>
      targetEpochDay - toEpochDay(now);
}
