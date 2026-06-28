// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:home_widget/home_widget.dart';

import '../domain/usecases/get_countdowns.dart';

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
    final next = countdowns
        .where((c) => c.daysRemaining >= 0)
        .fold<Countdown?>(null, (best, c) {
      if (best == null || c.daysRemaining < best.daysRemaining) return c;
      return best;
    });

    await HomeWidget.saveWidgetData<String>(
      'title',
      next?.event.title ?? 'Sin eventos',
    );
    await HomeWidget.saveWidgetData<int>(
      'days_remaining',
      next?.daysRemaining ?? -1,
    );
    await HomeWidget.saveWidgetData<int?>(
      'color_argb',
      next?.event.colorArgb,
    );

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _qualifiedAndroidName,
    );
  }
}
