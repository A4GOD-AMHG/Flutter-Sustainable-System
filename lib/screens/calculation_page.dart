import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sustainable_system/components/dialog_software.dart';
import 'package:sustainable_system/components/my_stepper.dart';
import 'package:sustainable_system/components/step_content.dart';
import 'package:sustainable_system/screens/history_page.dart';
import 'package:sustainable_system/screens/home_page.dart';
import 'package:sustainable_system/utils/constants.dart';
import 'package:sustainable_system/utils/features_discoveries.dart';
import 'package:sustainable_system/utils/functions.dart';
import 'package:sustainable_system/utils/navigation.dart';
import 'package:sustainable_system/utils/pdf.dart';

class CalculationPage extends StatefulWidget {
  final List<String>? metricsNames;
  final String softwareName;
  final List<Map<String, Map<int, List>>>? metrics;

  const CalculationPage(
      {super.key,
      this.softwareName = 'default',
      this.metricsNames,
      this.metrics});

  @override
  State<CalculationPage> createState() => _CalculationPageState();
}

class _CalculationPageState extends State<CalculationPage> {
  late final List<String> _metricsNames;
  late final List<Map<String, Map<int, List>>> _metrics;
  late final List<int> _currentSteps;
  late List<int> _values;
  late List<String> _filed;
  late String _clasification;
  late int _total;
  bool _generatingPdf = false;

  bool get _isNew => widget.softwareName == 'default';

  @override
  void initState() {
    super.initState();
    if (getShowDiscovery(keyCalculation) ?? true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDiscovery(context,
            listId: [
              kFeatureId6SaveSoftware,
              kFeatureId7GeneratePDF,
              kFeatureId8Points,
              kFeatureId9Clasification,
              kFeatureId10Metric,
              kFeatureId11MetricPoints,
              kFeatureId12Factor,
            ],
            key: keyCalculation),
      );
    }

    _metricsNames = widget.metricsNames ?? metricsNames;
    _metrics = widget.metrics ?? metrics;
    _currentSteps = List.filled(_metrics.length, 0);
    _computeScores();
  }

  void _computeScores() {
    _values = getMetricsValues(_metrics);
    _filed = [
      for (int i = 0; i < _values.length; i++) clasifications[i][_values[i]]!
    ];
    _total = _values.fold(0, (a, b) => a + b);
    _clasification = getClasification(_total);
  }

  void _goBack() =>
      navigateTo(_isNew ? const HomePage() : const HistoryPage(), back: true);

  @override
  Widget build(BuildContext context) {
    final iconSave = FaIcon(_isNew
        ? FontAwesomeIcons.solidFloppyDisk
        : FontAwesomeIcons.penToSquare);
    final ratingColor = clasificationColor[_clasification]!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: _goBack,
            icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          ),
          actions: [
            buildWidget(context,
                child: _ScoreBadge(
                    text: _clasification,
                    tooltip: 'Clasificación: $_clasification',
                    color: ratingColor),
                featureId: kFeatureId9Clasification,
                tapTarget: Text(_clasification,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: ratingColor)),
                contentLocation: ContentLocation.below,
                title: 'Clasificación',
                description: 'Aquí se muestra la clasificación'),
            buildWidget(context,
                child: _ScoreBadge(
                    text: '$_total',
                    tooltip: 'Puntos: $_total',
                    color: ratingColor),
                featureId: kFeatureId8Points,
                tapTarget: Text('$_total',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: ratingColor)),
                contentLocation: ContentLocation.below,
                title: 'Puntos',
                description: 'Aquí se muestra los puntos'),
            buildWidget(context,
                child: IconButton(
                  tooltip: 'Generar PDF',
                  onPressed: _generatingPdf ? null : _createPDF,
                  icon: _generatingPdf
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const FaIcon(FontAwesomeIcons.solidFilePdf),
                ),
                featureId: kFeatureId7GeneratePDF,
                tapTarget: const FaIcon(FontAwesomeIcons.solidFilePdf),
                contentLocation: ContentLocation.below,
                title: 'Generar PDF',
                description:
                    'Pulse aquí para generar una documentación en un archivo PDF'),
            buildWidget(context,
                child: IconButton(
                  tooltip: _isNew ? 'Guardar' : 'Editar',
                  onPressed: _showDialogAddSoftware,
                  icon: iconSave,
                ),
                featureId: kFeatureId6SaveSoftware,
                tapTarget: iconSave,
                contentLocation: ContentLocation.below,
                title: _isNew ? 'Guardar' : 'Editar',
                description:
                    'Pulse aquí para ${_isNew ? 'guardar' : 'editar'} el cálculo'),
          ],
        ),
        body: DefaultTabController(
          length: _metrics.length,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: _isNew ? 0 : 40,
                  centerTitle: true,
                  title: _isNew ? null : Text(widget.softwareName),
                  pinned: true,
                  bottom: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.white,
                    indicatorWeight: 4,
                    labelColor: Colors.white,
                    unselectedLabelColor: primarySwatch[100],
                    tabs: [
                      for (final metricMap in _metricsNames.asMap().entries)
                        metricMap.key == 1
                            ? buildWidget(context,
                                featureId: kFeatureId10Metric,
                                tapTarget: Text(metricMap.value),
                                child: _buildTabMetric(context, metricMap),
                                contentLocation: ContentLocation.below,
                                title: 'Métrica',
                                description:
                                    'Pulse aquí o deslice la pantalla para desplazarse por las métricas')
                            : _buildTabMetric(context, metricMap),
                    ],
                  ),
                )
              ];
            },
            body: TabBarView(
              physics: GetPlatform.isDesktop
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              children: [
                for (final metric in _metrics.asMap().entries)
                  MyStepper(
                    currentStep: _currentSteps[metric.key],
                    onStepChanged: (value) =>
                        setState(() => _currentSteps[metric.key] = value),
                    steps: [
                      for (final factor
                          in metric.value.entries.toList().asMap().entries)
                        Step(
                          isActive: _currentSteps[metric.key] >= factor.key,
                          state: StepState.complete,
                          title: (metric.key == 0 && factor.key == 0)
                              ? buildWidget(context,
                                  featureId: kFeatureId12Factor,
                                  tapTarget: Text(factor.value.key),
                                  child: Text(factor.value.key),
                                  contentLocation: ContentLocation.below,
                                  title: 'Factor',
                                  description:
                                      'Pulse aquí o en otro factor,\no en los botones Siguiente\no Anterior para, navegar\nentre los factores y marcar\nuna opción')
                              : Text(factor.value.key),
                          content: StepContent(
                            stepMap: factor.value.value,
                            onChange: (value) => setState(() {
                              _metrics[metric.key][factor.value.key] = value;
                              _computeScores();
                            }),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Tab _buildTabMetric(BuildContext context, MapEntry<int, String> metricMap) {
    final points = Text(' ${_values[metricMap.key]} ',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold));
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(metricMap.value),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: clasificationColor[_filed[metricMap.key]],
            ),
            child: (metricMap.key == 1)
                ? buildWidget(context,
                    featureId: kFeatureId11MetricPoints,
                    tapTarget: Text(' ${_values[metricMap.key]} '),
                    child: points,
                    contentLocation: ContentLocation.below,
                    title: 'Puntos de Métrica',
                    description: 'Aquí se muestra los puntos de esta métrica')
                : points,
          ),
        ],
      ),
    );
  }

  void _showDialogAddSoftware() {
    showDialog(
      context: context,
      builder: (context) => DialogSoftwareWidget(
        softwareName: widget.softwareName,
        metricsNames: _metricsNames,
        metrics: _metrics,
        rating: _clasification,
        points: _total,
      ),
    );
  }

  Future<void> _createPDF() async {
    setState(() => _generatingPdf = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await buildSustainabilityReport(
        metricsNames: _metricsNames,
        metrics: _metrics,
        values: _values,
        total: _total,
        clasification: _clasification,
      );
      final opened = await saveAndLaunchFile(bytes, 'documentation.pdf');
      if (!opened) {
        messenger.showSnackBar(const SnackBar(
            content: Text(
                'PDF generado, pero no se encontró una aplicación para abrirlo')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text('No se pudo generar el PDF')));
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }
}

/// Píldora blanca con la puntuación/clasificación en la AppBar.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge(
      {required this.text, required this.tooltip, required this.color});

  final String text;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 12, color: color),
        ),
      ),
    );
  }
}
