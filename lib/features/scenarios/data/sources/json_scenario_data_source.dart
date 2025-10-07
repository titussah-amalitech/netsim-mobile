import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:path_provider/path_provider.dart';

class JsonScenarioDataSource {
  Future<List<Scenario>> loadScenariosFromAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final scenarioPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/data/scenarios/'))
          .toList();
      if (scenarioPaths.isEmpty) {
        print("Warning: No scenario files found in assets/data/scenarios/");
        return [];
      }
      final List<Future<Scenario>> futureScenarios = scenarioPaths.map((
        path,
      ) async {
        final jsonString = await rootBundle.loadString(path);
        return Scenario.fromJsonString(jsonString);
      }).toList();
      final scenarios = await Future.wait(futureScenarios);
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
    return File('$path/$sanitizedName.json');
  }

  Future<File> writeScenarioToDocuments(Scenario scenario) async {
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
}
