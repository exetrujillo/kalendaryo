// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Formato de textos en español para la UI. Se hace a mano (sin `intl`) para
/// no añadir dependencias: la app es Local-First y minimalista por diseño.

const _months = <String>[
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Etiqueta humana de la cuenta regresiva. Negativo = evento pasado.
String daysRemainingLabel(int days) {
  if (days == 0) return 'Hoy';
  if (days == 1) return 'Mañana';
  if (days == -1) return 'Ayer';
  if (days > 0) return 'Faltan $days días';
  return 'Hace ${-days} días';
}

/// Fecha larga, p. ej. "28 de junio de 2026".
String dateLabel(DateTime date) =>
    '${date.day} de ${_months[date.month - 1]} de ${date.year}';
