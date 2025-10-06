// Dummy scenario data for testing purposes
final dummyScenario = {
  "_id": "6700a12345abcdef12345678", 
  "name": "Campus Network Simulation",
  "difficulty": "medium",
  "timeLimit": 1200,
  "devices": [
    {
      "device": "6700a12345abcdef11111111", 
      "type": "Router",
      "position": {"x": 10, "y": 15},
      "parameters": {
        "pingInterval": 20,
        "latencyThreshold": 80,
        "failureProbability": 0.05,
        "trafficLoad": 30
      },
      "status": {
        "online": true,
        "latency": 25,
        "lastChecked": "2025-10-02T10:00:00.000Z"
      }
    },
    {
      "device": "6700a12345abcdef22222222",
      "type": "Switch",
      "position": {"x": 20, "y": 25},
      "parameters": {
        "pingInterval": 30,
        "latencyThreshold": 90,
        "failureProbability": 0.1,
        "trafficLoad": 40
      },
      "status": {
        "online": false,
        "latency": 0,
        "lastChecked": "2025-10-02T10:05:00.000Z"
      }
    },
    {
      "device": "6700a12345abcdef33333333",
      "type": "Server",
      "position": {"x": 40, "y": 10},
      "parameters": {
        "pingInterval": 15,
        "latencyThreshold": 60,
        "failureProbability": 0.02,
        "trafficLoad": 70
      },
      "status": {
        "online": true,
        "latency": 50,
        "lastChecked": "2025-10-02T10:10:00.000Z"
      }
    },
    {
      "device": "6700a12345abcdef44444444",
      "type": "PC",
      "position": {"x": 60, "y": 35},
      "parameters": {
        "pingInterval": 25,
        "latencyThreshold": 100,
        "failureProbability": 0.15,
        "trafficLoad": 10
      },
      "status": {
        "online": false,
        "latency": 0,
        "lastChecked": "2025-10-02T10:15:00.000Z"
      }
    },
    {
      "device": "6700a12345abcdef55555555",
      "type": "Other",
      "position": {"x": 80, "y": 45},
      "parameters": {
        "pingInterval": 10,
        "latencyThreshold": 50,
        "failureProbability": 0.08,
        "trafficLoad": 20
      },
      "status": {
        "online": true,
        "latency": 10,
        "lastChecked": "2025-10-02T10:20:00.000Z"
      }
    }
  ],
  "metadata": {
    "createdBy": "admin",
    "createdAt": "2025-10-02T09:00:00.000Z",
    "description": "A medium-difficulty simulation of a campus network with different device states."
  },
  "createdAt": "2025-10-02T09:00:00.000Z",
  "updatedAt": "2025-10-02T09:30:00.000Z"
};
