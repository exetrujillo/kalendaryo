// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

class Event {
  const Event({
    this.id,
    required this.title,
    this.description,
    required this.targetDate,
    this.colorArgb,
    this.allDay = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String? description;

  final DateTime targetDate;

  final int? colorArgb;

  final bool allDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  int daysRemainingFrom(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }
}
