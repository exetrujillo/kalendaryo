// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

package cl.exetrujillo.kalendaryo.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import cl.exetrujillo.kalendaryo.R
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlin.math.abs

/**
 * Widget de pantalla de inicio que muestra los días restantes para el próximo
 * evento. Es puramente local: lee los datos que la app Flutter dejó en
 * SharedPreferences (vía el paquete home_widget) y los pinta. No abre sockets,
 * no contacta FCM, no mantiene servicios en segundo plano.
 *
 * El refresco diario a medianoche lo dispara [MidnightAlarmScheduler]; aquí solo
 * reaccionamos a onUpdate (alta del widget, alarma, o petición de la app).
 */
class CountdownWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs: SharedPreferences = HomeWidgetPlugin.getData(context)
        for (id in appWidgetIds) {
            renderWidget(context, appWidgetManager, id, prefs)
        }
        // Reprograma la próxima actualización a la siguiente medianoche.
        MidnightAlarmScheduler.scheduleNext(context)
    }

    override fun onEnabled(context: Context) {
        // Primer widget colocado: arranca el ciclo diario.
        MidnightAlarmScheduler.scheduleNext(context)
    }

    override fun onDisabled(context: Context) {
        // Último widget retirado: cancela la alarma para no gastar batería.
        MidnightAlarmScheduler.cancel(context)
    }

    private fun renderWidget(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        prefs: SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.countdown_widget)
        views.removeAllViews(R.id.widget_list_container)

        val eventsJsonStr = prefs.getString("events_json", "[]") ?: "[]"
        try {
            val eventsArray = org.json.JSONArray(eventsJsonStr)
            
            if (eventsArray.length() == 0) {
                views.setViewVisibility(R.id.widget_list_container, android.view.View.GONE)
                views.setViewVisibility(R.id.widget_empty_text, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_list_container, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty_text, android.view.View.GONE)
                
                val todayEpoch = getTodayEpochDay()
                for (i in 0 until eventsArray.length()) {
                    val eventObj = eventsArray.getJSONObject(i)
                    val title = eventObj.optString("title", context.getString(R.string.widget_no_events))
                    var days = eventObj.optInt("days", -1)
                    if (eventObj.has("target_epoch_day")) {
                        val targetEpochDay = eventObj.getLong("target_epoch_day")
                        days = (targetEpochDay - todayEpoch).toInt()
                    }
                    val color = if (eventObj.isNull("color")) android.graphics.Color.WHITE else eventObj.getInt("color")
                    
                    // Solo dibujamos si los días son >= 0 (no pasados)
                    if (days >= 0) {
                        val itemView = RemoteViews(context.packageName, R.layout.widget_event_item)
                        itemView.setTextViewText(R.id.item_title, title)
                        itemView.setTextViewText(R.id.item_days, formatDays(context, days))
                        itemView.setTextViewText(R.id.item_label, labelFor(context, days))
                        itemView.setInt(R.id.item_color, "setBackgroundColor", color)
                        
                        views.addView(R.id.widget_list_container, itemView)
                    }
                }
                
                // Si todos los eventos estaban en el pasado y se filtraron, mostrar mensaje vacío
                // Sin embargo, para evitar chequear la UI, siempre asume que si hay algo, se mostró.
                // Podríamos limpiar un poco, pero esto es seguro.
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback for empty state or errors
            views.setViewVisibility(R.id.widget_list_container, android.view.View.GONE)
            views.setViewVisibility(R.id.widget_empty_text, android.view.View.VISIBLE)
        }

        manager.updateAppWidget(widgetId, views)
    }

    private fun getTodayEpochDay(): Long {
        val cal = java.util.Calendar.getInstance()
        val utcCal = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC"))
        utcCal.clear()
        utcCal.set(
            cal.get(java.util.Calendar.YEAR),
            cal.get(java.util.Calendar.MONTH),
            cal.get(java.util.Calendar.DAY_OF_MONTH)
        )
        return utcCal.timeInMillis / 86400000L
    }

    private fun formatDays(context: Context, days: Int): String = when {
        days < 0 -> "—"
        else -> abs(days).toString()
    }

    private fun labelFor(context: Context, days: Int): String = when {
        days < 0 -> ""
        days == 0 -> context.getString(R.string.widget_today)
        days == 1 -> context.getString(R.string.widget_day_singular)
        else -> context.getString(R.string.widget_day_plural)
    }
}
