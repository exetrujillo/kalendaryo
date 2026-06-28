// SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event.dart';
import '../format/countdown_labels.dart';
import '../providers/providers.dart';

/// Paleta de acentos predefinida (ARGB). `null` = color por defecto del tema.
/// Se usa una paleta fija en vez de un selector libre para evitar dependencias
/// y mantener la coherencia visual con el widget de pantalla de inicio.
const _palette = <int?>[
  null,
  0xFFE53935, // rojo
  0xFFFB8C00, // naranja
  0xFFFDD835, // amarillo
  0xFF43A047, // verde
  0xFF00ACC1, // cian
  0xFF1E88E5, // azul
  0xFF8E24AA, // morado
  0xFFD81B60, // rosa
];

/// Formulario de alta y edición. Si [event] es nulo, crea uno nuevo.
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.event});

  final Event? event;

  bool get isEditing => event != null;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _targetDate;
  int? _colorArgb;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _descController = TextEditingController(text: event?.description ?? '');
    _targetDate = event?.targetDate ?? _todayMidnight();
    _colorArgb = event?.colorArgb;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final controller = ref.read(eventControllerProvider.notifier);
    final original = widget.event;
    try {
      if (original == null) {
        await controller.createEvent(
          title: _titleController.text,
          description: _descController.text,
          targetDate: _targetDate,
          colorArgb: _colorArgb,
        );
      } else {
        await controller.updateEvent(
          original,
          title: _titleController.text,
          description: _descController.text,
          targetDate: _targetDate,
          colorArgb: _colorArgb,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar evento' : 'Nuevo evento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'El título es obligatorio'
                      : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Fecha objetivo'),
              subtitle: Text(dateLabel(_targetDate)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Cambiar'),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            Text('Color de acento', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ColorPicker(
              palette: _palette,
              selected: _colorArgb,
              onSelected: (value) => setState(() => _colorArgb = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(widget.isEditing ? 'Guardar cambios' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.palette,
    required this.selected,
    required this.onSelected,
  });

  final List<int?> palette;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final argb in palette)
          GestureDetector(
            onTap: () => onSelected(argb),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: argb != null
                    ? Color(argb)
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: argb == selected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.outlineVariant,
                  width: argb == selected ? 3 : 1,
                ),
              ),
              child: argb == null
                  ? Icon(Icons.format_color_reset,
                      size: 20, color: theme.colorScheme.outline)
                  : (argb == selected
                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                      : null),
            ),
          ),
      ],
    );
  }
}
