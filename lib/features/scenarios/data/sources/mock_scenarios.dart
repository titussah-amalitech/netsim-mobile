import '../../../devices/data/models/device_model.dart';
import '../../../devices/data/models/device_parameters.dart';
import '../../../devices/data/models/device_position.dart';
import '../../../devices/data/models/device_status.dart';
import '../models/scenario.dart';
import '../models/scenario_model.dart';

class MockScenarios {
  static List<Scenario> scenarios = [
    Scenario(
      name: "Basic Networking",
      difficulty: "easy",
      timeLimit: 600,
      devices: [
        Device(
          id: "1",
          position: Position(x: 0, y: 0),
          parameters: Parameters(
            pingInterval: 30,
            latencyThreshold: 100,
            failureProbability: 0.1,
            trafficLoad: 10,
          ),
          status: Status(
            online: true,
            latency: 20,
            lastChecked: DateTime.now(),
          ),
        ),
      ],
      metadata: Metadata(
        createdBy: "admin",
        createdAt: DateTime.now(),
        description: "Introductory networking scenario.",
      ),
    ),
    Scenario(
      name: "Advanced Routing",
      difficulty: "hard",
      timeLimit: 1200,
      devices: [
        Device(
          id: "2",
          position: Position(x: 10, y: 20),
          parameters: Parameters(
            pingInterval: 15,
            latencyThreshold: 50,
            failureProbability: 0.2,
            trafficLoad: 70,
          ),
          status: Status(
            online: false,
            latency: 200,
            lastChecked: DateTime.now(),
          ),
        ),
        Device(
          id: "3",
          position: Position(x: 5, y: 15),
          parameters: Parameters(
            pingInterval: 20,
            latencyThreshold: 80,
            failureProbability: 0.05,
            trafficLoad: 30,
          ),
          status: Status(
            online: true,
            latency: 40,
            lastChecked: DateTime.now(),
          ),
        ),
      ],
      metadata: Metadata(
        createdBy: "trainer",
        createdAt: DateTime.now(),
        description: "Challenging routing exercise with failures.",
      ),
    ),
  ];
}
