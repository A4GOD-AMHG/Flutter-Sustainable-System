import 'package:flutter/material.dart';

/// [Stepper] controlado: el paso actual lo guarda el padre.
class MyStepper extends StatelessWidget {
  final List<Step> steps;
  final int currentStep;
  final void Function(int) onStepChanged;

  const MyStepper(
      {super.key,
      required this.steps,
      required this.currentStep,
      required this.onStepChanged});

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == steps.length - 1;
    return Stepper(
      physics: const BouncingScrollPhysics(),
      steps: steps,
      currentStep: currentStep,
      onStepTapped: onStepChanged,
      onStepContinue: isLast ? null : () => onStepChanged(currentStep + 1),
      onStepCancel: currentStep == 0 ? null : () => onStepChanged(currentStep - 1),
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              if (!isLast)
                FilledButton.icon(
                  onPressed: details.onStepContinue,
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  label: const Text('Siguiente'),
                ),
              if (!isLast && details.currentStep != 0) const SizedBox(width: 8),
              if (details.currentStep != 0)
                TextButton.icon(
                  onPressed: details.onStepCancel,
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  label: const Text('Anterior'),
                ),
            ],
          ),
        );
      },
    );
  }
}
