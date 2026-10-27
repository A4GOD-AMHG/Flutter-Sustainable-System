import 'package:animate_do/animate_do.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sustainable_system/controllers/database_controller.dart';
import 'package:sustainable_system/screens/calculation_page.dart';

const _transition = Duration(milliseconds: 250);

/// Reemplaza la pila de navegación por [page] con una animación lateral.
///
/// [back] indica que se vuelve atrás (la página entra desde la izquierda).
void navigateTo(Widget page, {bool back = false}) {
  Get.offAll(() => back
      ? SlideInLeft(duration: _transition, child: page)
      : SlideInRight(duration: _transition, child: page));
}

/// Carga la evaluación de [softwareName] ('default' = nueva) y abre la pantalla de cálculo.
Future<void> openCalculation(String softwareName) async {
  final metrics = await databaseController.softwareToList(softwareName);
  final metricsNames =
      await databaseController.getMetricsNamesBySoftwareName(softwareName);
  navigateTo(CalculationPage(
    softwareName: softwareName,
    metrics: metrics,
    metricsNames: metricsNames,
  ));
}
