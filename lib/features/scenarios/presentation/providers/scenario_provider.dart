import 'package:riverpod/riverpod.dart';
import '../../data/models/scenario_model.dart';
import '../../data/sources/json_scenario_data_source.dart';

final scenariosProvider = FutureProvider<List<Scenario>>((ref) async {
  final dataSource = JsonScenarioDataSource();
  return await dataSource.loadScenariosFromAssets();
});
