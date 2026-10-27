import 'package:flutter/material.dart';
import 'package:sustainable_system/utils/functions.dart';

/// Opciones de un factor; [stepMap] es `{puntos: [descripción, seleccionada]}`.
class StepContent extends StatelessWidget {
  final Map<int, List> stepMap;
  final void Function(Map<int, List>) onChange;

  const StepContent({super.key, required this.stepMap, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RadioGroup<int>(
          groupValue: getSelectedValue(stepMap),
          onChanged: (value) {
            if (value == null) return;
            for (final entry in stepMap.entries) {
              entry.value[1] = entry.key == value;
            }
            onChange(stepMap);
          },
          child: Column(
            children: [
              for (final e in stepMap.entries)
                RadioListTile<int>(
                  value: e.key,
                  title: Text(e.value[0], style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${e.key} puntos'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
