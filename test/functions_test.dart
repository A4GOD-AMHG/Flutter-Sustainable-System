import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_system/models/software.dart';
import 'package:sustainable_system/utils/constants.dart';
import 'package:sustainable_system/utils/functions.dart';

void main() {
  test('getClasification respeta los umbrales', () {
    expect(getClasification(0), 'No Sostenible');
    expect(getClasification(8), 'No Sostenible');
    expect(getClasification(9), 'Poco Sostenible');
    expect(getClasification(20), 'Poco Sostenible');
    expect(getClasification(21), 'Sostenible');
  });

  test('getMetricsValues suma la opción marcada de cada factor', () {
    final data = [
      <String, Map<int, List>>{
        'a': {0: ['x', false], 2: ['y', true]},
        'b': {0: ['x', false], 1: ['y', true]},
      },
      <String, Map<int, List>>{
        'c': {0: ['x', true], 2: ['y', false]},
      },
    ];
    expect(getMetricsValues(data), [3, 0]);
  });

  test('las sentencias usan parámetros (nombres con comillas no rompen SQL)', () {
    final software = Software(name: "O'Reilly", rating: 'Sostenible', points: 3);
    final inserts =
        getDataInsertQuery(software: software, list: metrics, metrics: metricsNames);
    for (final (sql, args) in inserts) {
      expect(sql.contains("O'Reilly"), isFalse);
      expect('?'.allMatches(sql).length, args.length);
    }
    expect(inserts.first.$2, ["O'Reilly", 'Sostenible', 3]);

    final updates = getDataUpdateQuery(
        newName: "Nuevo 'x'", software: software, list: metrics);
    expect(updates.last.$2, ["Nuevo 'x'", 'Sostenible', 3, "O'Reilly"]);
  });

  test('los datos base no tienen opciones duplicadas (son PRIMARY KEY)', () {
    final options = getDataInsertQuery(list: metrics, metrics: metricsNames)
        .where((s) => s.$1.startsWith('INSERT INTO Option'))
        .map((s) => s.$2.first)
        .toList();
    expect(options.toSet().length, options.length);
  });
}
