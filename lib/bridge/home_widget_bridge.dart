// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:home_widget/home_widget.dart';

import '../domain/usecases/get_countdowns.dart';
import '../core/utils/date_diff.dart';

/// Puente entre la app Flutter y el widget nativo de Android.
///
/// NO usa red ni FCM: solo escribe los datos del próximo evento en el
/// almacenamiento compartido y pide al SO redibujar el widget. El refresco
/// diario a medianoche lo gestiona AlarmManager en el lado nativo (Kotlin).
class HomeWidgetBridge {
  static const _androidWidgetName = 'CountdownWidgetProvider';
  static const _qualifiedAndroidName =
      'cl.exetrujillo.kalendaryo.widget.CountdownWidgetProvider';

  static Future<void> sync(List<Countdown> countdowns) async {
    final upcoming = countdowns
        .where((c) => c.daysRemaining >= 0)
        .toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    // Listar los próximos 4 eventos para evitar que el widget colapse en espacio
    final top = upcoming.take(4).toList();

    // Codificamos a JSON para pasarlo a Kotlin
    final jsonList = top.map((c) => {
      'title': c.event.title,
      'days': c.daysRemaining,
      'target_epoch_day': DateDiff.toEpochDay(c.event.targetDate),
      'color': c.event.colorArgb,
    }).toList();

    await HomeWidget.saveWidgetData<String>(
      'events_json',
      jsonEncode(jsonList),
    );

    // Mantenemos los antiguos para retrocompatibilidad por si se actualiza a medias
    await HomeWidget.saveWidgetData<String>(
      'title',
      top.isNotEmpty ? top.first.event.title : 'Sin eventos',
    );
    await HomeWidget.saveWidgetData<int>(
      'days_remaining',
      top.isNotEmpty ? top.first.daysRemaining : -1,
    );
    await HomeWidget.saveWidgetData<int?>(
      'color_argb',
      top.isNotEmpty ? top.first.event.colorArgb : null,
    );

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _qualifiedAndroidName,
    );
  }
}
