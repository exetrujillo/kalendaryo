// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bridge/home_widget_bridge.dart';
import 'domain/usecases/get_countdowns.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/countdown_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KalendaryoApp()));
}

class KalendaryoApp extends ConsumerWidget {
  const KalendaryoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sincroniza el widget nativo ante cualquier cambio en los datos: cada
    // emisión del stream (alta, edición, borrado o carga inicial) vuelca el
    // próximo evento al almacenamiento compartido y pide repintar. Así el
    // puente queda desacoplado de la UI y de los controladores.
    ref.listen<AsyncValue<List<Countdown>>>(countdownsProvider, (_, next) {
      next.whenData(HomeWidgetBridge.sync);
    });

    return MaterialApp(
      title: 'Kalendaryo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const CountdownListScreen(),
    );
  }
}
