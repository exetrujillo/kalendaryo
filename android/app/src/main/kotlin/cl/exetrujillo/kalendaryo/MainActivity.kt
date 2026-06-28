// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

package cl.exetrujillo.kalendaryo

import android.os.Bundle
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import cl.exetrujillo.kalendaryo.widget.MidnightAlarmScheduler
import cl.exetrujillo.kalendaryo.widget.WidgetUpdateWorker
import io.flutter.embedding.android.FlutterActivity
import java.util.concurrent.TimeUnit

/**
 * Punto de entrada Android de la app Flutter.
 *
 * Al iniciar, asegura las DOS vías de refresco del widget (ambas 100% locales,
 * sin red ni Google Play Services):
 *  1. [MidnightAlarmScheduler]: alarma exacta encadenada a cada medianoche
 *     (mecanismo primario y preciso).
 *  2. [WidgetUpdateWorker] vía WorkManager periódico (~24 h): red de seguridad
 *     para fabricantes que matan las alarmas exactas (Xiaomi, Huawei, etc.).
 */
class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MidnightAlarmScheduler.scheduleNext(this)
        enqueueDailyWidgetRefresh()
    }

    private fun enqueueDailyWidgetRefresh() {
        val request = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
            1, TimeUnit.DAYS,
        ).build()

        // KEEP: si ya hay un trabajo encolado de una ejecución previa, no lo
        // reemplazamos en cada arranque (evita reiniciar la ventana de 24 h).
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            WidgetUpdateWorker.UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
    }
}
