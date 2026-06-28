// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

package cl.exetrujillo.kalendaryo.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import java.util.Calendar

/**
 * Programa una alarma exacta a la PRÓXIMA medianoche local para redibujar el
 * widget. Tras dispararse, [CountdownWidgetProvider.onUpdate] vuelve a llamar a
 * [scheduleNext], encadenando una actualización por día.
 *
 * Mecanismo 100% local (AOSP `AlarmManager`): sin red, sin FCM, sin servicio
 * persistente. Usa setExactAndAllowWhileIdle para atravesar el modo Doze.
 */
object MidnightAlarmScheduler {

    private const val REQUEST_CODE = 0xCA1E // arbitrario y estable

    fun scheduleNext(context: Context) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerAt = nextMidnightMillis()
        val pending = buildPendingIntent(context)

        // En Android 12+ las alarmas exactas pueden requerir permiso; si no se
        // concede, WorkManager (WidgetUpdateWorker) actúa como red de seguridad.
        if (canScheduleExact(alarmManager)) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC,
                triggerAt,
                pending,
            )
        } else {
            alarmManager.set(AlarmManager.RTC, triggerAt, pending)
        }
    }

    fun cancel(context: Context) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(buildPendingIntent(context))
    }

    private fun canScheduleExact(alarmManager: AlarmManager): Boolean =
        android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.S ||
            alarmManager.canScheduleExactAlarms()

    private fun nextMidnightMillis(): Long {
        val cal = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 1) // 00:00:01 para evitar borde exacto
            set(Calendar.MILLISECOND, 0)
        }
        return cal.timeInMillis
    }

    private fun buildPendingIntent(context: Context): PendingIntent {
        val provider = ComponentName(context, CountdownWidgetProvider::class.java)
        val ids = AppWidgetManager.getInstance(context)
            .getAppWidgetIds(provider)

        val intent = Intent(context, CountdownWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        return PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
