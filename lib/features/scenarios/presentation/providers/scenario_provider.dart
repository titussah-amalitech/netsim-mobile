import 'package:riverpod/riverpod.dart';
import '../../data/models/scenario_model.dart';
import '../../data/sources/json_scenario_data_source.dart';

final scenariosProvider = FutureProvider<List<Scenario>>((ref) async {
  final dataSource = JsonScenarioDataSource();
  return await dataSource.loadScenariosFromAssets();
});

final scenarioDataSourceProvider = Provider<JsonScenarioDataSource>((ref) {
  return JsonScenarioDataSource();
});

class ScenarioNotifier extends Notifier<AsyncValue<List<Scenario>>> {
  @override
  AsyncValue<List<Scenario>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadScenarios() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(scenarioDataSourceProvider);
      return await dataSource.loadScenariosFromAssets();
    });
  }

  Future<void> updateScenario(Scenario scenario) async {
    final dataSource = ref.read(scenarioDataSourceProvider);
    await dataSource.updateScenario(scenario);
    await loadScenarios();
  }
}

final scenarioNotifierProvider =
    NotifierProvider<ScenarioNotifier, AsyncValue<List<Scenario>>>(() {
      return ScenarioNotifier();
    });
