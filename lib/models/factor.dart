// Los nombres de campo reflejan las columnas de la base de datos.
// ignore_for_file: non_constant_identifier_names

class Factor {
  late String name;
  late String metric_name;

  Factor({required this.name, required this.metric_name});

  Factor.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    metric_name = map['metric_name'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'metric_name': metric_name,
    };
  }

  @override
  String toString() => 'Factor(name: $name, metric_name: $metric_name)';
}
