import 'package:animate_do/animate_do.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sustainable_system/components/my_button.dart';
import 'package:sustainable_system/controllers/database_controller.dart';
import 'package:sustainable_system/models/software.dart';
import 'package:sustainable_system/screens/home_page.dart';
import 'package:sustainable_system/utils/constants.dart';
import 'package:sustainable_system/utils/features_discoveries.dart';
import 'package:sustainable_system/utils/navigation.dart';

const _historyColor = Color(0xFF0777D2);

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Software>> _softwares;
  bool _discoveryScheduled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _softwares = databaseController.getSoftwares();
    _softwares.then((list) {
      // El tutorial solo tiene sentido si hay softwares que señalar.
      if (!mounted || list.isEmpty || _discoveryScheduled) return;
      if (getShowDiscovery(keyHistory) ?? true) {
        _discoveryScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => showDiscovery(
            context,
            listId: [kFeatureId13DeleteAllSoftwares, kFeatureId14Software],
            key: keyHistory));
      }
    }, onError: (_) {});
  }

  void _reload() => setState(_load);

  void _goBack() => navigateTo(const HomePage(), back: true);

  @override
  Widget build(BuildContext context) {
    const iconDelete = FaIcon(FontAwesomeIcons.trash);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _historyColor,
          title: const Text("Historial"),
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: _goBack,
            icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          ),
          actions: [
            FutureBuilder<List<Software>>(
              future: _softwares,
              builder: (context, snapshot) {
                if (!(snapshot.data?.isNotEmpty ?? false)) {
                  return const SizedBox.shrink();
                }
                return buildWidget(
                  context,
                  child: IconButton(
                    tooltip: 'Eliminar todos',
                    onPressed: () => _showDialogDeleteAllSoftwares(context),
                    icon: iconDelete,
                  ),
                  featureId: kFeatureId13DeleteAllSoftwares,
                  tapTarget: iconDelete,
                  contentLocation: ContentLocation.below,
                  title: 'Eliminar',
                  description:
                      "Pulse aquí si desea eliminar todos los softwares",
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Software>>(
          future: _softwares,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _Message(
                icon: FontAwesomeIcons.triangleExclamation,
                text: "No se pudo cargar el historial",
                action: TextButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Reintentar"),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data!;
            if (list.isEmpty) {
              return const _Message(
                icon: FontAwesomeIcons.boxOpen,
                text: "Aún no hay softwares guardados.\n"
                    "Realiza un cálculo y guárdalo para verlo aquí.",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final software = list[index];
                return (index == 0)
                    ? buildWidget(context,
                        featureId: kFeatureId14Software,
                        tapTarget:
                            const FaIcon(FontAwesomeIcons.solidWindowMaximize),
                        child: _buildButton(context, software, index),
                        contentLocation: ContentLocation.below,
                        title: "Software",
                        description:
                            "Pulsa aquí para editar el software o \nMantén pulsado para eliminarlo")
                    : _buildButton(context, software, index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Software software, int index) {
    return FadeInUp(
      // Escalonado sutil, con tope para listas largas.
      delay: Duration(milliseconds: 40 * index.clamp(0, 10)),
      duration: const Duration(milliseconds: 400),
      child: MyButton(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color1: _historyColor,
        color2: const Color(0xFF3B9BE9),
        icon: FontAwesomeIcons.solidWindowMaximize,
        onPress: () => openCalculation(software.name),
        onLongPress: () => _showDialogDeleteSoftware(context, software),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              software.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    software.rating,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: clasificationColor[software.rating]),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${software.points} puntos',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context,
      {required String message,
      required String successMessage,
      required Future<bool> Function() delete}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text("Eliminar"),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await delete()) {
        messenger.showSnackBar(SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text(successMessage)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text("No se pudo eliminar")));
    }
    if (mounted) _reload();
  }

  void _showDialogDeleteSoftware(BuildContext context, Software software) =>
      _confirmAndDelete(context,
          message: "¿Desea eliminar el software ${software.name}?",
          successMessage: "Software eliminado satisfactoriamente",
          delete: () => databaseController.deleteSoftware(software.name));

  void _showDialogDeleteAllSoftwares(BuildContext context) =>
      _confirmAndDelete(context,
          message: "¿Desea eliminar todos los softwares?",
          successMessage: "Softwares eliminados satisfactoriamente",
          delete: databaseController.deleteAllSoftwares);
}

/// Estado vacío / de error centrado con icono, texto y acción opcional.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 96, color: color.withValues(alpha: 0.4)),
              const SizedBox(height: 24),
              Text(text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color)),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
