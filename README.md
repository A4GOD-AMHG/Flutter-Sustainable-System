# Sistema Sostenible

Aplicación móvil en Flutter para evaluar la **sostenibilidad de un software** a partir de cinco métricas (mantenibilidad, facilidad de uso, portabilidad, fiabilidad y consumo de energía) y sus factores. Es material complementario de una tesis realizada para la Universidad de Cienfuegos, desarrollada por **Alexis Manuel Hurtado Garcia** junto a Leonardo Alain Moreira Rodríguez. Permite puntuar un software, clasificarlo, guardar el historial de evaluaciones y exportar un informe en PDF.

## Tech Stack

<div style="display: flex; align-items: center;">
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/dart/dart-original.svg" alt="dart" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/flutter/flutter-original.svg" alt="flutter" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/sqlite/sqlite-original.svg" alt="sqlite" width="65" height="65" />
</div>

## Características

- **Evaluación por métricas**: cada métrica tiene varios factores y cada factor tres opciones (0, 1 o 2 puntos), recorridos con un stepper por pestañas.
- **Clasificación en tiempo real**: puntos por métrica y total, con la clasificación *No Sostenible*, *Poco Sostenible* o *Sostenible* coloreada.
- **Historial**: guarda, edita, renombra y elimina evaluaciones en una base de datos SQLite local.
- **Informe PDF**: genera un documento con el desglose de la evaluación y la conclusión, y lo abre con el visor del sistema.
- **Tutoriales interactivos**: guías paso a paso en cada pantalla (se pueden reiniciar desde el menú).
- **Tema claro y oscuro**: Material 3 con el verde de la marca, siguiendo el tema del sistema.

## Dependencias

### Dependencias Principales

- `sqflite`: base de datos SQLite local para el historial.
- `path` / `path_provider`: rutas de la base de datos y del PDF generado.
- `shared_preferences`: recuerda qué tutoriales ya se mostraron.
- `get`: navegación entre pantallas.
- `syncfusion_flutter_pdf`: generación del informe PDF.
- `open_filex`: abre el PDF generado.
- `feature_discovery`: tutoriales interactivos.
- `animate_do`: animaciones de entrada.
- `font_awesome_flutter`: iconos.
- `cupertino_icons`: iconos de iOS.

### Dependencias de Desarrollo

- `flutter_test`: pruebas unitarias.
- `flutter_lints`: reglas de análisis estático.
- `flutter_launcher_icons`: genera el icono de la app desde `assets/images/icon.png`.

## Cómo usar

Requisitos: Flutter 3.35 o superior (Dart 3.9+).

```bash
git clone https://github.com/A4GOD-AMHG/Flutter-Sustainable-System.git
cd Flutter-Sustainable-System

# El repositorio no incluye las carpetas de plataforma; se generan con:
flutter create --platforms=android,ios .

flutter pub get
dart run flutter_launcher_icons   # opcional: icono de la app
flutter run
```

No requiere variables de entorno.

Compilar:

```bash
flutter build apk --release
```

Pruebas:

```bash
flutter test
```

## Estructura del Proyecto

```
lib/
├── main.dart                     # Punto de entrada: orientación, preferencias y base de datos
├── app.dart                      # GetMaterialApp, temas claro/oscuro y FeatureDiscovery
├── components/
│   ├── dialog_software.dart      # Diálogo para guardar/editar un software
│   ├── header.dart               # Cabecera con degradado de la pantalla de inicio
│   ├── my_button.dart            # Botón grande con degradado
│   ├── my_stepper.dart           # Stepper controlado de factores
│   └── step_content.dart         # Opciones (radio) de un factor
├── controllers/
│   └── database_controller.dart  # Fachada de acceso a datos usada por la UI
├── database/
│   └── database_provider.dart    # Esquema SQLite y consultas
├── models/                       # Software, Metric, Factor, Option, Selection, SoftwareMetric
├── screens/
│   ├── home_page.dart            # Menú principal
│   ├── calculation_page.dart     # Evaluación por métricas y factores
│   └── history_page.dart         # Historial de evaluaciones
└── utils/
    ├── constants.dart            # Métricas, factores, opciones, umbrales y colores
    ├── features_discoveries.dart # Tutoriales y preferencias
    ├── functions.dart            # Puntuación, clasificación y sentencias SQL parametrizadas
    ├── navigation.dart           # Navegación con transiciones
    └── pdf.dart                  # Generación y apertura del informe PDF
test/
└── functions_test.dart           # Pruebas de puntuación y generación de SQL
assets/images/icon.png            # Icono de la app y del PDF
```

## Licencia

Proyecto académico de código abierto. El repositorio no incluye un archivo de licencia; contacta con el autor antes de reutilizarlo.

## Autor

**Alexis Manuel Hurtado Garcia** - [GitHub](https://github.com/A4GOD-AMHG)
