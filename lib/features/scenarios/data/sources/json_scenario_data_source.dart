import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:path_provider/path_provider.dart';

class JsonScenarioDataSource {
  Future<List<String>> getScenarioPaths() async {
    final AssetManifest assetManifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );
    final List<String> scenarioPaths = assetManifest
        .listAssets()
        .where((key) => key.startsWith('assets/data/scenarios/'))
        .toList();
    return scenarioPaths;
  }

  Future<List<Scenario>> loadScenariosFromAssets() async {
    try {
      final scenarioPaths = await getScenarioPaths();
      if (scenarioPaths.isEmpty) {
        print("Warning: No scenario files found in assets/data/scenarios/");
        return [];
      }

      final List<Scenario> scenarios = [];
      for (final path in scenarioPaths) {
        final jsonString = await rootBundle.loadString(path);
        final scenario = Scenario.fromJsonString(jsonString);

        final updatedScenario = await readScenarioFromDocuments(scenario.name);
        scenarios.add(updatedScenario ?? scenario);
      }

      return scenarios;
    } catch (e) {
      print("Error loading scenarios from assets: $e");
      return [];
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String scenarioName) async {
    final path = await _localPath;
    final sanitizedName = scenarioName.replaceAll(
      RegExp(r'[^a-zA-Z0-9_\-]'),
      '',
    );
    return File('$path/scenarios/$sanitizedName.json');
  }

  Future<void> _ensureDirectoryExists() async {
    final path = await _localPath;
    final directory = Directory('$path/scenarios');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<File> writeScenarioToDocuments(Scenario scenario) async {
    await _ensureDirectoryExists();
    final file = await _localFile(scenario.name);
    final jsonString = scenario.toJsonString(pretty: true);
    return file.writeAsString(jsonString);
  }

  Future<Scenario?> readScenarioFromDocuments(String scenarioName) async {
    try {
      final file = await _localFile(scenarioName);
      if (!await file.exists()) {
        return null;
      }
      final contents = await file.readAsString();
      return Scenario.fromJsonString(contents);
    } catch (e) {
      print("Error reading scenario '$scenarioName' from documents: $e");
      return null;
    }
  }

  Future<File> updateScenario(Scenario scenario) async {
    await _ensureDirectoryExists();
    final file = await _localFile(scenario.name);
    final jsonString = scenario.toJsonString(pretty: true);
    return file.writeAsString(jsonString);
  }

  Future<bool> deleteScenario(String scenarioName) async {
    try {
      final file = await _localFile(scenarioName);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting scenario '$scenarioName': $e");
      return false;
    }
  }
}
