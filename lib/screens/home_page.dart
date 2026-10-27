import 'package:animate_do/animate_do.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:sustainable_system/components/my_button.dart';
import 'package:sustainable_system/components/header.dart';
import 'package:sustainable_system/screens/history_page.dart';
import 'package:sustainable_system/utils/constants.dart';
import 'package:sustainable_system/utils/features_discoveries.dart';
import 'package:sustainable_system/utils/navigation.dart';

class ButtonItem {
  final IconData icon;
  final String text;
  final Color color1;
  final Color color2;
  final String featureId;
  final void Function() onPress;
  const ButtonItem(
      {required this.icon,
      required this.text,
      required this.color1,
      required this.color2,
      required this.featureId,
      required this.onPress});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<GlobalKey<EnsureVisibleState>> ensureVisibleGlobalKey =
      List.generate(4, (_) => GlobalKey<EnsureVisibleState>());

  @override
  void initState() {
    super.initState();
    if (getShowDiscovery(keyHome) ?? true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDiscovery(context,
            listId: [
              kFeatureId1PopupMenu,
              kFeatureId2CalculateSoftware,
              kFeatureId3History,
              kFeatureId4Settings,
              kFeatureId5Help
            ],
            key: keyHome),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ButtonItem(
        icon: FontAwesomeIcons.calculator,
        text: 'Calcular',
        color1: const Color(0xFF1B5E20),
        color2: const Color(0xFF66BB6A),
        featureId: kFeatureId2CalculateSoftware,
        onPress: () => openCalculation('default'),
      ),
      ButtonItem(
        icon: FontAwesomeIcons.clockRotateLeft,
        text: 'Historial',
        color1: const Color(0xFF085195),
        color2: const Color(0xFF1D8DE9),
        featureId: kFeatureId3History,
        onPress: () => navigateTo(const HistoryPage()),
      ),
      ButtonItem(
        icon: FontAwesomeIcons.gear,
        text: 'Ajustes',
        color1: const Color(0xFF455A64),
        color2: const Color(0xFF90A4AE),
        featureId: kFeatureId4Settings,
        onPress: () => _showDialogSettings(context),
      ),
      ButtonItem(
        icon: FontAwesomeIcons.circleInfo,
        text: 'Acerca de',
        color1: const Color(0xFF424242),
        color2: const Color(0xFF9E9E9E),
        featureId: kFeatureId5Help,
        onPress: () => _showAbout(context),
      ),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 180),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 80, bottom: 24),
                children: [
                  for (final (index, item) in items.indexed)
                    FadeInLeft(
                      delay: Duration(milliseconds: 80 * index),
                      duration: const Duration(milliseconds: 450),
                      child: buildWidget(context,
                          child: EnsureVisible(
                            key: ensureVisibleGlobalKey[index],
                            child: MyButton(
                              icon: item.icon,
                              onPress: item.onPress,
                              color1: item.color1,
                              color2: item.color2,
                              child: Text(item.text,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          featureId: item.featureId,
                          tapTarget: FaIcon(item.icon),
                          contentLocation: ContentLocation.above,
                          onOpen: () async {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ensureVisibleGlobalKey[index]
                                  .currentState
                                  ?.ensureVisible();
                            });
                            return true;
                          },
                          title: item.text,
                          description:
                              'Pulse aquí para abrir la pantalla ${item.text}${item.text == 'Ajustes' ? ' (En desarrollo)' : ''}'),
                    ),
                ],
              ),
            ),
            const _Header(),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w900, fontSize: 16);
    const normal = TextStyle(fontSize: 16);
    showAboutDialog(
      context: context,
      applicationName: "Sistema Sostenible",
      applicationVersion: appVersion,
      applicationIcon: Image.asset("assets/images/icon.png", width: 48),
      children: const [
        Text("Autores:", textAlign: TextAlign.center, style: bold),
        Text("Leonardo Alain Moreira Rodríguez\nAlexis Manuel Hurtado García",
            style: normal, textAlign: TextAlign.center),
        SizedBox(height: 15),
        Text("Tutora:", textAlign: TextAlign.center, style: bold),
        Text("MsC. Dailyn Sosa López",
            style: normal, textAlign: TextAlign.center),
      ],
    );
  }

  void _showDialogSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.construction_rounded),
        title: const Text("Ajustes"),
        content: const Text("En desarrollo...", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    const iconMenu = FaIcon(
      FontAwesomeIcons.ellipsisVertical,
      color: Colors.white,
    );
    return Stack(
      children: [
        const IconHeader(
          icon: FontAwesomeIcons.leaf,
          title: 'Sistema Sostenible',
          subtitle: 'Menú',
        ),
        Positioned(
          right: 4,
          top: MediaQuery.paddingOf(context).top + 4,
          child: buildWidget(
            context,
            title: 'Menú de Opciones',
            description: 'Pulse aquí para abrir el Menú de Opciones',
            featureId: kFeatureId1PopupMenu,
            tapTarget: iconMenu,
            contentLocation: ContentLocation.below,
            child: PopupMenuButton<int>(
              tooltip: 'Opciones',
              icon: iconMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.school_outlined),
                    title: Text('Reiniciar tutoriales'),
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  await setShowDiscovery(true, keyHome);
                  await setShowDiscovery(true, keyCalculation);
                  await setShowDiscovery(true, keyHistory);
                  navigateTo(const HomePage());
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
