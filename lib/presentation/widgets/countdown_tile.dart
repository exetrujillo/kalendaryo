// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_countdowns.dart';
import '../format/countdown_labels.dart';
import '../providers/providers.dart';
import '../screens/event_form_screen.dart';

/// Fila de la lista: muestra un evento, su color de acento y los días
/// restantes. Tocar abre la edición; deslizar borra (con confirmación).
class CountdownTile extends ConsumerWidget {
  const CountdownTile({super.key, required this.countdown});

  final Countdown countdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final event = countdown.event;
    final accent = event.colorArgb != null
        ? Color(event.colorArgb!)
        : theme.colorScheme.primary;
    final days = countdown.daysRemaining;
    final isPast = days < 0;

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline,
            color: theme.colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) => _confirmDelete(context, event.title),
      onDismissed: (_) =>
          ref.read(eventControllerProvider.notifier).deleteEvent(event.id!),
      child: ListTile(
        leading: Container(
          width: 6,
          height: 40,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(dateLabel(event.targetDate)),
        trailing: Text(
          daysRemainingLabel(days),
          style: theme.textTheme.labelLarge?.copyWith(
            color: isPast
                ? theme.colorScheme.outline
                : theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventFormScreen(event: event),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Eliminar «$title»? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
