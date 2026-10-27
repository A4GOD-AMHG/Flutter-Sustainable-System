import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sustainable_system/utils/constants.dart';
import 'package:sustainable_system/models/factor.dart';
import 'package:sustainable_system/models/metric.dart';
import 'package:sustainable_system/models/option.dart';
import 'package:sustainable_system/models/selection.dart';
import 'package:sustainable_system/models/software.dart';
import 'package:sustainable_system/models/software_metric.dart';
import 'package:sustainable_system/utils/functions.dart';

///[DatabaseProvider]  clase que provee la base de datos
class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();

  // Se cachea el Future para que llamadas concurrentes compartan una sola apertura.
  Future<Database>? _database;

  ///[database] instancia única de la base de datos, se abre la primera vez que se pide
  Future<Database> get database => _database ??= _createDatabase();

  ///[_createDatabase] método que crea/abre la base de datos
  Future<Database> _createDatabase() async {
    String dbPath = await getDatabasesPath();

    // contiene la consulta SQL para crear la tabla Software
    String querySoftware = "CREATE TABLE Software("
        "name TEXT PRIMARY KEY," // nombre del software
        "rating TEXT," // clasificación del software
        "points INTEGER);"; // puntos del software

    // contiene la consulta SQL para crear la tabla Metric
    String queryMetric = "CREATE TABLE Metric("
        "name TEXT PRIMARY KEY);"; //nombre de la métrica

    /// contiene la consulta SQL para crear la tabla SoftwareMetric
    String querySoftwareMetric = "CREATE TABLE SoftwareMetric("
        "software_name TEXT NOT NULL," //nombre del sofware al que esta relacionado
        "metric_name TEXT NOT NULL," //nombre de la métrica a la que esta relacionada
        "FOREIGN KEY(software_name) REFERENCES Software(name) ON DELETE CASCADE ON UPDATE CASCADE," //llave foránea de Software, permite la eliminación y actualización en cascada
        "FOREIGN KEY(metric_name) REFERENCES Metric(name) ON DELETE CASCADE ON UPDATE CASCADE);"; //llave foránea de Metric, permite la eliminación y actualización en cascada

    /// contiene la consulta SQL para crear la tabla Factor
    String queryFactor = "CREATE TABLE Factor("
        "name TEXT PRIMARY KEY," //nombre del factor
        "metric_name TEXT NOT NULL," //nombre de la métrica a la que pertenece el factor
        "FOREIGN KEY(metric_name) REFERENCES Metric(name) ON DELETE CASCADE ON UPDATE CASCADE);"; //llave foránea de Metric, permite la eliminación y actualización en cascada

    /// contiene la consulta SQL para crear la tabla Option
    String queryOption = "CREATE TABLE Option("
        "name TEXT PRIMARY KEY," //nombre de la opción
        "factor_name TEXT NOT NULL," //nombre del factor a la que pertenece la métrica
        "FOREIGN KEY(factor_name) REFERENCES Factor(name) ON DELETE CASCADE ON UPDATE CASCADE);"; //llave foránea de Factor, permite la eliminación y actualización en cascada

    /// contiene la consulta SQL para crear la tabla Selection
    String querySelection = "CREATE TABLE Selection("
        "software_name TEXT NOT NULL," // nombre del software que pertenece esta selección
        "factor_name TEXT NOT NULL," // nombre del factor que pertenece esta selección
        "option_name TEXT NOT NULL," // nombre de la opción que pertenece esta selección
        "isSelected INTEGER NOT NULL," // contiene el valor 1 si está seleccionado y 0 si no está seleccionado
        "value INTEGER NOT NULL," // contiene el valor que le corresponde a esta selección
        "FOREIGN KEY(software_name) REFERENCES Software(name) ON DELETE CASCADE ON UPDATE CASCADE," //llave foránea de Software, permite la eliminación y actualización en cascada
        "FOREIGN KEY(factor_name) REFERENCES Factor(name) ON DELETE CASCADE ON UPDATE CASCADE," //llave foránea de Factor, permite la eliminación y actualización en cascada
        "FOREIGN KEY(option_name) REFERENCES Option(name) ON DELETE CASCADE ON UPDATE CASCADE);"; //llave foránea de Option, permite la eliminación y actualización en cascada

    //variable que contiene todas las consultas
    List<String> queries = [
      querySoftware,
      queryMetric,
      querySoftwareMetric,
      queryFactor,
      queryOption,
      querySelection,
    ];

    onCreate(Database database, int version) async {
      for (String currentQuery in queries) {
        //ejecuta las consultas de una en una
        await database.execute(currentQuery);
      }
      final batch = database.batch();
      for (final (sql, args)
          in getDataInsertQuery(list: metrics, metrics: metricsNames)) {
        batch.execute(sql, args);
      }
      await batch.commit(noResult: true);
    }

    return openDatabase(
      join(
        dbPath,
        'sustainableSystemDB.db',
      ), //archivo que contiene la base de datos
      version: 1, //versión de la base de datos
      onConfigure: onConfigure,
      onCreate: onCreate,
    );
  }

  ///[onConfigure] método que contiene las configuraciones de la base de datos
  Future onConfigure(Database db) async {
    await db.execute(
        "PRAGMA foreign_keys = ON"); //permite la eliminación en cascada
  }

  //Operaciones de lectura

  ///[getSoftwares] método que retorna una lista de [Software]
  Future<List<Software>> getSoftwares() async {
    final db = await database;

    var softwares = await db.query('Software',
        columns: [
          'name',
          'rating',
          'points',
        ],
        where: 'name != ?',
        whereArgs: ['default']);

    List<Software> softwareList = [];
    for (final currentSoftware in softwares) {
      Software software = Software.fromMap(currentSoftware);
      softwareList.add(software);
    }
    return softwareList;
  }

  ///[getSoftwaresNames] método que retorna todos los nombres de softwares
  Future<List<String>> getSoftwaresNames() async {
    var softwares = await getSoftwares();

    var softwaresNames = <String>[];
    for (int i = 0; i < softwares.length; i++) {
      softwaresNames.add(softwares[i].name);
    }

    return softwaresNames;
  }

  ///[getSoftwareByName] método que retorna un [Software] dado su nombre
  Future<Software?> getSoftwareByName(String name) async {
    final db = await database;

    var softwares = await db.query(
      'Software',
      columns: [
        'name',
        'rating',
        'points',
      ],
      where: 'name = ?',
      whereArgs: [name],
    );

    Software? software;
    for (final currentSoftware in softwares) {
      software = Software.fromMap(currentSoftware);
    }
    return software;
  }

  ///[getMetrics] método que retorna una lista de [Metric]
  Future<List<Metric>> getMetrics() async {
    final db = await database;

    var metrics = await db.query(
      'Metric',
      columns: [
        'name',
      ],
    );

    List<Metric> metricsList = [];
    for (final currentMetric in metrics) {
      Metric metric = Metric.fromMap(currentMetric);
      metricsList.add(metric);
    }

    return metricsList;
  }

  ///[getMetricsNames] método que retorna todos los nombres de metrics
  Future<List<String>> getMetricsNames() async {
    var metrics = await getMetrics();

    var metricsNames = <String>[];
    for (int i = 0; i < metrics.length; i++) {
      metricsNames.add(metrics[i].name);
    }

    return metricsNames;
  }

  ///[getMetricsNamesBySoftwareName] método que retorna todos los nombres de metrics dado un nombre de un software
  ///
  ///[softwareName] nombre del software que se le va a buscar los nombres de metrics
  Future<List<String>> getMetricsNamesBySoftwareName(
      String softwareName) async {
    var softwareMetric = await getSoftwaresMetricsBySoftwareName(softwareName);

    var metricsNames = <String>[];
    for (var i = 0; i < softwareMetric.length; i++) {
      metricsNames.add(softwareMetric[i].metric_name);
    }

    return metricsNames;
  }

  ///[getMetricByName] método que retorna un [Metric] dado su nombre
  Future<Metric?> getMetricByName(String name) async {
    final db = await database;

    var metrics = await db.query(
      'Metric',
      columns: [
        'name',
      ],
      where: 'name = ?',
      whereArgs: [name],
    );

    Metric? metric;
    for (final currentMetric in metrics) {
      metric = Metric.fromMap(currentMetric);
    }
    return metric;
  }

  ///[getSoftwaresMetrics] método que retorna una lista de [SoftwareMetric]
  Future<List<SoftwareMetric>> getSoftwaresMetrics() async {
    final db = await database;

    var softwaresMetrics = await db.query(
      'SoftwareMetric',
      columns: [
        'software_name',
        'metric_name',
      ],
    );

    List<SoftwareMetric> softwaresMetricsList = [];
    for (final currentSoftwareMetric in softwaresMetrics) {
      SoftwareMetric softwareMetric =
          SoftwareMetric.fromMap(currentSoftwareMetric);
      softwaresMetricsList.add(softwareMetric);
    }
    return softwaresMetricsList;
  }

  ///[getSoftwareMetric] método que retorna un [SoftwareMetric] dado un nombre de un [Software] y un nombre de un [Metric]
  Future<SoftwareMetric?> getSoftwareMetric(
      String softwareName, String metricName) async {
    final db = await database;

    var softwaresMetrics = await db.query(
      'SoftwareMetric',
      columns: [
        'software_name',
        'metric_name',
      ],
      where: 'software_name = ? and metric_name = ?',
      whereArgs: [softwareName, metricName],
    );

    SoftwareMetric? softwareMetric;
    for (final currentSoftwareMetric in softwaresMetrics) {
      softwareMetric = SoftwareMetric.fromMap(currentSoftwareMetric);
    }
    return softwareMetric;
  }

  ///[getSoftwaresMetricsBySoftwareName] método que retorna una lista de [SoftwareMetric] dado un nombre de un [Software]
  Future<List<SoftwareMetric>> getSoftwaresMetricsBySoftwareName(
      String softwareName) async {
    final db = await database;

    var softwaresMetrics = await db.query(
      'SoftwareMetric',
      columns: [
        'software_name',
        'metric_name',
      ],
      where: 'software_name = ?',
      whereArgs: [softwareName],
    );

    List<SoftwareMetric> softwaresMetricsList = [];
    for (final currentSoftwareMetric in softwaresMetrics) {
      SoftwareMetric softwareMetric =
          SoftwareMetric.fromMap(currentSoftwareMetric);
      softwaresMetricsList.add(softwareMetric);
    }
    return softwaresMetricsList;
  }

  ///[getFactors] método que retorna una lista de [Factor]
  Future<List<Factor>> getFactors() async {
    final db = await database;

    var factors = await db.query(
      'Factor',
      columns: [
        'name',
        'metric_name',
      ],
    );

    List<Factor> factorsList = [];
    for (final currentFactor in factors) {
      Factor factor = Factor.fromMap(currentFactor);
      factorsList.add(factor);
    }
    return factorsList;
  }

  ///[getFactorsNames] método que retorna todos los nombres de factors
  Future<List<String>> getFactorsNames() async {
    var factors = await getFactors();

    var factorsNames = <String>[];
    for (int i = 0; i < factors.length; i++) {
      factorsNames.add(factors[i].name);
    }

    return factorsNames;
  }

  ///[getFactorsByMetricName] método que retorna una lista de [Factor] dado un nombre de un [Metric]
  Future<List<Factor>> getFactorsByMetricName(String metricName) async {
    final db = await database;

    var factors = await db.query(
      'Factor',
      columns: [
        'name',
        'metric_name',
      ],
      where: 'metric_name = ?',
      whereArgs: [metricName],
    );

    List<Factor> factorsList = [];
    for (final currentFactor in factors) {
      Factor factor = Factor.fromMap(currentFactor);
      factorsList.add(factor);
    }
    return factorsList;
  }

  ///[getFactorByName] método que retorna un [Factor] dado su nombre
  Future<Factor?> getFactorByName(String name) async {
    final db = await database;

    var factors = await db.query(
      'Factor',
      columns: [
        'name',
        'metric_name',
      ],
      where: 'name = ?',
      whereArgs: [name],
    );

    Factor? factor;
    for (final currentFactor in factors) {
      factor = Factor.fromMap(currentFactor);
    }
    return factor;
  }

  ///[getOptions] método que retorna una lista de [Option]
  Future<List<Option>> getOptions() async {
    final db = await database;

    var options = await db.query(
      'Option',
      columns: [
        'name',
        'factor_name',
      ],
    );

    List<Option> optionsList = [];
    for (final currentOption in options) {
      Option option = Option.fromMap(currentOption);
      optionsList.add(option);
    }
    return optionsList;
  }

  ///[getOptionsNames] método que retorna todos los nombres de options
  Future<List<String>> getOptionsNames() async {
    var options = await getOptions();

    var optionsNames = <String>[];
    for (int i = 0; i < options.length; i++) {
      optionsNames.add(options[i].name);
    }

    return optionsNames;
  }

  ///[getOptionsByFactorName] método que retorna una lista de [Option] dado un nombre de un [Factor]
  Future<List<Option>> getOptionsByFactorName(String factorName) async {
    final db = await database;

    var options = await db.query(
      'Option',
      columns: [
        'name',
        'factor_name',
      ],
      where: 'factor_name = ?',
      whereArgs: [factorName],
    );

    List<Option> optionsList = [];
    for (final currentOption in options) {
      Option option = Option.fromMap(currentOption);
      optionsList.add(option);
    }
    return optionsList;
  }

  ///[getOptionByName] método que retorna un [Option] dado su nombre
  Future<Option?> getOptionByName(String name) async {
    final db = await database;

    var options = await db.query(
      'Option',
      columns: [
        'name',
        'factor_name',
      ],
      where: 'name = ?',
      whereArgs: [name],
    );

    Option? option;
    for (final currentOption in options) {
      option = Option.fromMap(currentOption);
    }
    return option;
  }

  ///[getSelection] método que retorna un [Selection] dado un nombre de un [Software], un nombre de un [Factor] y un nombre de un [Option]
  Future<Selection?> getSelection(
      String softwareName, String factorName, String optionName) async {
    final db = await database;

    var selections = await db.query(
      'Selection',
      columns: [
        'software_name',
        'factor_name',
        'option_name',
        'isSelected',
        'value'
      ],
      where: 'software_name = ? and factor_name = ? and option_name = ?',
      whereArgs: [softwareName, factorName, optionName],
    );

    Selection? selection;
    for (final currentSelection in selections) {
      selection = Selection.fromMap(currentSelection);
    }
    return selection;
  }

  ///[getSelections] método que retorna una lista [Selection] dado un nombre de un [Software], un nombre de un [Factor] y un nombre de un [Option]
  Future<List<Selection>> getSelections(
      String softwareName, String factorName) async {
    final db = await database;

    var selections = await db.query(
      'Selection',
      columns: [
        'software_name',
        'factor_name',
        'option_name',
        'isSelected',
        'value'
      ],
      where: 'software_name = ? and factor_name = ?',
      whereArgs: [softwareName, factorName],
      orderBy: 'value ASC',
    );

    List<Selection> selectionsList = [];
    for (final currentSelection in selections) {
      Selection selection = Selection.fromMap(currentSelection);
      selectionsList.add(selection);
    }
    return selectionsList;
  }

  //Operaciones de inserción

  ///[executeAll] ejecuta [statements] en una única transacción: o se aplican todas o ninguna
  Future<void> executeAll(List<SqlStatement> statements) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final (sql, args) in statements) {
        batch.execute(sql, args);
      }
      await batch.commit(noResult: true);
    });
  }

  ///[insertSoftware] método para insertar un [Software]
  ///
  ///[software] [Software] a insertar
  Future<Software?> insertSoftware(Software software) async {
    final db = await database;
    await db.insert(
      'Software',
      software.toMap(),
    );
    return software;
  }

  ///[insertMetric] método para insertar un [Metric]
  ///
  ///[metric] [Metric] a insertar
  Future<Metric?> insertMetric(Metric metric) async {
    final db = await database;
    await db.insert(
      'Metric',
      metric.toMap(),
    );
    return metric;
  }

  ///[insertSoftwareMetric] método para insertar un [SoftwareMetric]
  ///
  ///[softwareMetric] [SoftwareMetric] a insertar
  Future<SoftwareMetric?> insertSoftwareMetric(
      SoftwareMetric softwareMetric) async {
    final db = await database;
    await db.insert(
      'SoftwareMetric',
      softwareMetric.toMap(),
    );
    return softwareMetric;
  }

  ///[insertFactor] método para insertar un [Factor]
  ///
  ///[factor] [Factor] a insertar
  Future<Factor?> insertFactor(Factor factor) async {
    final db = await database;
    await db.insert(
      'Factor',
      factor.toMap(),
    );
    return factor;
  }

  ///[insertOption] método para insertar un [Option]
  ///
  ///[option] [Option] a insertar
  Future<Option?> insertOption(Option option) async {
    final db = await database;
    await db.insert(
      'Option',
      option.toMap(),
    );
    return option;
  }

  ///[insertSelection] método para insertar un [Selection]
  ///
  ///[selection] [Selection] a insertar
  Future<Selection?> insertSelection(Selection selection) async {
    final db = await database;
    await db.insert(
      'Selection',
      selection.toMap(),
    );
    return selection;
  }

  //Operaciones de eliminación

  ///[deleteAllSoftwares] método para eliminar todos los softwares
  ///
  ///retorna [true] si los borra, y [false] si no
  Future<bool> deleteAllSoftwares() async {
    final db = await database;

    var deleteCount = await db.rawDelete('''
        DELETE FROM Software 
        WHERE name != ?
       ''', ['default']);
    return deleteCount != 0;
  }

  ///[deleteSoftware] método para eliminar un software
  ///
  ///[name] nombre del software a eliminar
  ///
  ///retorna [true] si la borra, y [false] si no
  Future<bool> deleteSoftware(String name) async {
    final db = await database;
    var deleteCount = await db.rawDelete(
      '''
        DELETE FROM Software 
        WHERE name = ?''',
      [name],
    );
    return deleteCount != 0;
  }

  //Otras operaciones

  ///[containSoftwareName] método para saber si existe este nombre de software en la base de datos
  ///
  ///[name] nombre a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containSoftwareName(String name) async {
    List<String> softwares = await getSoftwaresNames();
    for (int i = 0; i < softwares.length; i++) {
      softwares[i] = softwares[i].toLowerCase();
    }
    return softwares.contains(name);
  }

  ///[containMetricName] método para saber si existe este nombre de metric en la base de datos
  ///
  ///[name] nombre a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containMetricName(String name) async {
    List<String> metrics = await getMetricsNames();
    for (int i = 0; i < metrics.length; i++) {
      metrics[i] = metrics[i].toLowerCase();
    }
    return metrics.contains(name);
  }

  ///[containFactorName] método para saber si existe este nombre de factor en la base de datos
  ///
  ///[name] nombre a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containFactorName(String name) async {
    List<String> factors = await getFactorsNames();
    for (int i = 0; i < factors.length; i++) {
      factors[i] = factors[i].toLowerCase();
    }
    return factors.contains(name);
  }

  ///[containOptionName] método para saber si existe este nombre de option en la base de datos
  ///
  ///[name] nombre a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containOptionName(String name) async {
    List<String> options = await getOptionsNames();
    for (int i = 0; i < options.length; i++) {
      options[i] = options[i].toLowerCase();
    }
    return options.contains(name);
  }

  ///[softwareToList] método que busca un software dado su nombre y lo retorna en un [List<Map<String, Map<int, List>>>]
  ///
  ///[softwareName] nombre del software
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<List<Map<String, Map<int, List>>>> softwareToList(
      String softwareName) async {
    final list = <Map<String, Map<int, List>>>[];
    for (final softwareMetric
        in await getSoftwaresMetricsBySoftwareName(softwareName)) {
      final factors = <String, Map<int, List>>{};
      for (final factor in await getFactorsByMetricName(softwareMetric.metric_name)) {
        final opts = <int, List>{};
        for (final option in await getOptionsByFactorName(factor.name)) {
          final selection =
              await getSelection(softwareName, factor.name, option.name);
          if (selection != null) {
            opts[selection.value] = [option.name, selection.isSelected];
          }
        }
        factors[factor.name] = opts;
      }
      list.add(factors);
    }
    return list;
  }
}
