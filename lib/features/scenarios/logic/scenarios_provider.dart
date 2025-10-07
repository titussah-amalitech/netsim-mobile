import 'package:riverpod/legacy.dart';
import '../data/sources/mock_scenarios.dart';
import '../data/models/scenario_model.dart';
import '../data/sources/persistent_scenarios.dart';

class ScenariosNotifier extends StateNotifier<List<Scenario>> {
  ScenariosNotifier() : super(List<Scenario>.from(MockScenarios.scenarios)) {
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    final fromDisk = await PersistentScenarios.load();
    if (fromDisk != null && fromDisk.isNotEmpty) {
      state = fromDisk;
    } else {
      // No persisted scenarios found; persist the in-code mock scenarios so
      // newly-added mock entries are saved and will be loaded on subsequent runs.
      try {
        PersistentScenarios.save(state).then((_) {});
      } catch (_) {}
    }
  }

  void setAll(List<Scenario> list) {
    state = List<Scenario>.from(list);
  }

  /// Replace the current scenarios with the in-code mock scenarios and persist them.
  void resetToMock() {
    try {
      state = List<Scenario>.from(MockScenarios.scenarios);
      PersistentScenarios.save(state).then((_) {});
    } catch (_) {}
  }

  void updateScenario(Scenario oldScenario, Scenario newScenario) {
    final idx = state.indexWhere((s) => identical(s, oldScenario) || (s.name == oldScenario.name && s.metadata.createdAt == oldScenario.metadata.createdAt));
    if (idx != -1) {
      final next = [...state];
      next[idx] = newScenario;
      state = next;
      // keep MockScenarios in sync for any non-reactive code
      try {
        final msIdx = MockScenarios.scenarios.indexWhere((s) => identical(s, oldScenario) || (s.name == oldScenario.name && s.metadata.createdAt == oldScenario.metadata.createdAt));
        if (msIdx != -1) MockScenarios.scenarios[msIdx] = newScenario;
      } catch (_) {}
      // persist changes (fire-and-forget)
      PersistentScenarios.save(state).then((_) {});
    }
  }
}

final scenariosProvider = StateNotifierProvider<ScenariosNotifier, List<Scenario>>((ref) {
  return ScenariosNotifier();
});
