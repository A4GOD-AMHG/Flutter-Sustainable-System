import 'package:sustainable_system/models/software.dart';

/// Sentencia SQL parametrizada: la consulta y sus argumentos.
typedef SqlStatement = (String sql, List<Object?> args);

String getClasification(int value) {
  if (value >= 0 && value <= 8) {
    return 'No Sostenible';
  } else if (value >= 9 && value <= 20) {
    return 'Poco Sostenible';
  }
  return 'Sostenible';
}

/// Puntos de cada métrica: suma del valor de la opción marcada en cada factor.
List<int> getMetricsValues(List<Map<String, Map<int, List>>> metrics) {
  return [
    for (final metric in metrics)
      metric.values.fold<int>(
          0, (sum, options) => sum + getSelectedValue(options)),
  ];
}

/// Valor (clave) de la opción marcada de un factor, o 0 si no hay ninguna.
int getSelectedValue(Map<int, List> options) {
  for (final option in options.entries) {
    if (option.value[1] == true) return option.key;
  }
  return 0;
}

/// Genera las sentencias para insertar un software con sus selecciones.
///
/// Si [software] es `null` se insertan los datos base ('default'): métricas,
/// factores y opciones además de las selecciones por defecto.
List<SqlStatement> getDataInsertQuery(
    {Software? software,
    required List<Map<String, Map<int, List>>> list,
    required List<String> metrics}) {
  final isDefault = software == null;
  final name = software?.name ?? 'default';
  final data = <SqlStatement>[
    software == null
        ? ('INSERT INTO Software(name) VALUES (?)', [name])
        : (
            'INSERT INTO Software(name, rating, points) VALUES (?, ?, ?)',
            [name, software.rating, software.points]
          ),
  ];

  for (int i = 0; i < list.length; i++) {
    if (isDefault) {
      data.add(('INSERT INTO Metric(name) VALUES (?)', [metrics[i]]));
    }
    data.add((
      'INSERT INTO SoftwareMetric(software_name, metric_name) VALUES (?, ?)',
      [name, metrics[i]]
    ));
    for (final factor in list[i].entries) {
      if (isDefault) {
        data.add((
          'INSERT INTO Factor(name, metric_name) VALUES (?, ?)',
          [factor.key, metrics[i]]
        ));
      }
      for (final option in factor.value.entries) {
        if (isDefault) {
          data.add((
            'INSERT INTO Option(name, factor_name) VALUES (?, ?)',
            [option.value[0], factor.key]
          ));
        }
        data.add((
          'INSERT INTO Selection(software_name, factor_name, option_name, isSelected, value) VALUES (?, ?, ?, ?, ?)',
          [name, factor.key, option.value[0], option.value[1] ? 1 : 0, option.key]
        ));
      }
    }
  }
  return data;
}

/// Genera las sentencias para actualizar las selecciones de [software] y
/// renombrarlo a [newName] (el renombrado se propaga por ON UPDATE CASCADE).
List<SqlStatement> getDataUpdateQuery(
    {required String newName,
    required Software software,
    required List<Map<String, Map<int, List>>> list}) {
  final data = <SqlStatement>[];

  for (final metric in list) {
    for (final factor in metric.entries) {
      for (final option in factor.value.entries) {
        data.add((
          'UPDATE Selection SET isSelected = ? WHERE software_name = ? AND factor_name = ? AND option_name = ?',
          [option.value[1] ? 1 : 0, software.name, factor.key, option.value[0]]
        ));
      }
    }
  }
  data.add((
    'UPDATE Software SET name = ?, rating = ?, points = ? WHERE name = ?',
    [newName, software.rating, software.points, software.name]
  ));
  return data;
}
