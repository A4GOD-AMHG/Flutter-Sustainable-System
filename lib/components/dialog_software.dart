import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sustainable_system/controllers/database_controller.dart';
import 'package:sustainable_system/models/software.dart';
import 'package:sustainable_system/screens/history_page.dart';
import 'package:sustainable_system/screens/home_page.dart';
import 'package:sustainable_system/utils/functions.dart';

class DialogSoftwareWidget extends StatefulWidget {
  final String softwareName;
  final String rating;
  final int points;
  final List<Map<String, Map<int, List>>> metrics;
  final List<String> metricsNames;

  const DialogSoftwareWidget(
      {required this.metricsNames,
      required this.metrics,
      required this.rating,
      required this.points,
      this.softwareName = 'default',
      super.key});

  @override
  State<DialogSoftwareWidget> createState() => _DialogSoftwareWidgetState();
}

class _DialogSoftwareWidgetState extends State<DialogSoftwareWidget> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  bool _existSoftwareName = false;
  bool _saving = false;

  bool get _editing => widget.softwareName != 'default';

  @override
  void initState() {
    super.initState();
    _name = _editing ? widget.softwareName : '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${_editing ? "Editar" : "Guardar"} software"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: "Nombre",
            prefixIcon: Icon(Icons.apps_rounded),
            border: OutlineInputBorder(),
          ),
          onSaved: (newValue) => _name = newValue!.trim(),
          validator: (value) {
            final name = value?.trim() ?? '';
            if (name.isEmpty) {
              return "Llene este campo";
            }
            if (name.toLowerCase() == 'default') {
              return "Este nombre de software no está disponible";
            }
            final isSameName =
                _editing && name.toLowerCase() == widget.softwareName.toLowerCase();
            if (_existSoftwareName && !isSameName) {
              return "Este software ya existe";
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_editing ? "Editar" : "Guardar"),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    form.save();
    // La comprobación es asíncrona, se resuelve antes de validar para no usar un valor viejo.
    _existSoftwareName =
        await databaseController.containSoftwareName(_name.toLowerCase());
    if (!mounted || !form.validate()) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final software = Software(
          name: _editing ? widget.softwareName : _name,
          rating: widget.rating,
          points: widget.points);
      await databaseController.executeAll(_editing
          ? getDataUpdateQuery(
              newName: _name, software: software, list: widget.metrics)
          : getDataInsertQuery(
              software: software,
              list: widget.metrics,
              metrics: widget.metricsNames));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text("No se pudo guardar el software")));
      return;
    }

    messenger.showSnackBar(SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text(
            "Software ${_editing ? "modificado" : "añadido"} satisfactoriamente")));
    Get.offAll(() => _editing ? const HistoryPage() : const HomePage());
  }
}
