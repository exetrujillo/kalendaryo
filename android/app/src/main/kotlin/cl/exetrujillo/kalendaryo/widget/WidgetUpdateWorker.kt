// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

package cl.exetrujillo.kalendaryo.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

/**
 * Red de seguridad para fabricantes que matan alarmas exactas (Xiaomi, Huawei…).
 * Se registra como trabajo periódico (~24h) en MainActivity al iniciar la app.
 *
 * WorkManager (AndroidX) NO depende de Google Play Services: cae a JobScheduler
 * o a AlarmManager según la versión. No requiere red (sin Constraints de red).
 */
class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters,
) : Worker(context, params) {

    override fun doWork(): Result {
        val context = applicationContext
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, CountdownWidgetProvider::class.java),
        )
        if (ids.isNotEmpty()) {
            CountdownWidgetProvider().onUpdate(context, manager, ids)
        }
        return Result.success()
    }

    companion object {
        const val UNIQUE_WORK_NAME = "kalendaryo_daily_widget_refresh"
    }
}
