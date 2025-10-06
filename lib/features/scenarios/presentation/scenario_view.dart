import 'package:flutter/material.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../data/models/scenario.dart';

class ScenarioViewScreen extends StatelessWidget {
  final Scenario scenario;

  const ScenarioViewScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(scenario.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Difficulty: ${scenario.difficulty}"),
                  Text("Time Limit: ${scenario.timeLimit}s"),
                  Text("Created By: ${scenario.metadata.createdBy}"),
                  Text("Description: ${scenario.metadata.description}"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Devices",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: scenario.devices.length,
                itemBuilder: (context, index) {
                  final device = scenario.devices[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ShadCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Device ID: ${device.id}"),
                          Text("Online: ${device.status.online}"),
                          Text("Latency: ${device.status.latency} ms"),
                          Text(
                            "Traffic Load: ${device.parameters.trafficLoad}%",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
