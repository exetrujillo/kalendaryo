// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/countdown_tile.dart';
import 'event_form_screen.dart';

/// Pantalla principal: lista de cuentas regresivas ordenadas por días
/// restantes (orden que ya garantiza el repositorio vía `targetEpochDay`).
class CountdownListScreen extends ConsumerWidget {
  const CountdownListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalendaryo')),
      body: countdowns.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar los eventos.\n$error',
                textAlign: TextAlign.center),
          ),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => CountdownTile(countdown: items[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EventFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Aún no hay eventos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Toca «Nuevo» para crear tu primera cuenta regresiva.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
