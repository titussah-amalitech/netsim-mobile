import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_metadata.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_parameters.dart';
import 'package:netsim_mobile/features/devices/data/models/device_position.dart';
import 'package:netsim_mobile/features/devices/data/models/device_status.dart';
import 'package:netsim_mobile/features/scenarios/data/sources/json_scenario_data_source.dart';
import 'package:netsim_mobile/features/scenarios/presentation/providers/scenario_provider.dart';

class ScenarioEditorScreen extends ConsumerStatefulWidget {
  const ScenarioEditorScreen({super.key});

  @override
  ConsumerState<ScenarioEditorScreen> createState() =>
      _ScenarioEditorScreenState();
}

class _ScenarioEditorScreenState extends ConsumerState<ScenarioEditorScreen> {
  // Undo/redo stacks
  final List<Map<String, dynamic>> _history = [];
  int _historyIndex = -1;
  final GlobalKey _canvasKey = GlobalKey();

  List<Device> _devices = [];
  List<List<String>> _connections = [];
  String? _selectedDeviceId;

  final List<String> _deviceTypes = [
    'PC',
    'Router',
    'Switch',
    'Server',
    'Firewall'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with empty state in history
    _pushHistory();
  }

  // HISTORY MANAGEMENT
  void _pushHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add({
      'devices': List<Device>.from(_devices),
      'connections': List<List<String>>.from(
          _connections.map((c) => List<String>.from(c))),
    });
    _historyIndex = _history.length - 1;
  }

  void _undo() {
    if (_historyIndex <= 0) return;
    _historyIndex--;
    final state = _history[_historyIndex];
    setState(() {
      _devices = List<Device>.from(state['devices']);
      _connections = List<List<String>>.from(
          state['connections'].map((c) => List<String>.from(c)));
      _selectedDeviceId = null;
    });
  }

  void _redo() {
    if (_historyIndex >= _history.length - 1) return;
    _historyIndex++;
    final state = _history[_historyIndex];
    setState(() {
      _devices = List<Device>.from(state['devices']);
      _connections = List<List<String>>.from(
          state['connections'].map((c) => List<String>.from(c)));
      _selectedDeviceId = null;
    });
  }

  void _addDeviceAt(String type, Offset localPos) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final device = Device(
      id: id,
      type: type,
      position: Position(x: localPos.dx.round(), y: localPos.dy.round()),
      parameters: Parameters(
        pingInterval: 30,
        latencyThreshold: 100,
        failureProbability: 0.05,
        trafficLoad: 10,
      ),
      status: Status(
        online: true,
        latency: 0,
        lastChecked: DateTime.now(),
      ),
    );
    setState(() {
      _devices.add(device);
      _pushHistory();
    });
  }

  void _updateDevicePosition(String id, Offset localPos) {
    final idx = _devices.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    final d = _devices[idx];
    _devices[idx] = d.copyWith(
        position: Position(x: localPos.dx.round(), y: localPos.dy.round()));
    setState(() {
      _pushHistory();
    });
  }

  void _toggleConnection(String a, String b) {
    if (a == b) return;
    final pair = [a, b];
    final rev = [b, a];

    for (final c in _connections) {
      if ((c[0] == pair[0] && c[1] == pair[1]) ||
          (c[0] == rev[0] && c[1] == rev[1])) {
        setState(() {
          _connections.remove(c);
          _pushHistory();
        });
        return;
      }
    }
    setState(() {
      _connections.add(pair);
      _pushHistory();
    });
  }

  void _deleteSelectedDevice() {
    if (_selectedDeviceId == null) return;
    setState(() {
      _devices.removeWhere((d) => d.id == _selectedDeviceId);
      _connections.removeWhere((c) => c.contains(_selectedDeviceId));
      _selectedDeviceId = null;
      _pushHistory();
    });
  }

  Offset _globalToLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.globalToLocal(global) ?? Offset.zero;
  }

  Future<void> _saveScenario() async {
    final nameController = TextEditingController();
    final difficultyController = TextEditingController(text: 'Medium');
    final timeController = TextEditingController(text: '300');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Save Scenario"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: difficultyController,
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time Limit (s)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final scenario = Scenario(
      name: nameController.text.trim(),
      difficulty: difficultyController.text.trim(),
      timeLimit: int.tryParse(timeController.text.trim()) ?? 300,
      score: 0,
      devices: List<Device>.from(_devices),
      metadata: Metadata(
        createdBy: 'admin',
        createdAt: DateTime.now(),
        description: 'Created in editor',
      ),
    );
    try {
      // First save to documents using JsonScenarioDataSource
      final dataSource = JsonScenarioDataSource();
      await dataSource.writeScenarioToDocuments(scenario);

      // Update the notifier to reload scenarios
      final notifier = ref.read(scenarioNotifierProvider.notifier);
      await notifier.loadScenarios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scenario "${scenario.name}" saved'),
            action: SnackBarAction(
              label: 'View Scenarios',
              onPressed: () {
                Navigator.pop(context); // Return to scenario list
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving scenario: $e')),
        );
      }
    }
  }

  // -------------------------------------------------------
  // DEVICE PARAMETER EDITOR
  // -------------------------------------------------------
  Future<void> _editDeviceParameters(Device device) async {
  // local dialog state will be used instead of text controllers

    int ping = device.parameters.pingInterval;
    int latency = device.parameters.latencyThreshold;
    double failure = device.parameters.failureProbability;
    int traffic = device.parameters.trafficLoad;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Edit ${device.type} Parameters'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ping interval (increment/decrement)
                Row(
                  children: [
                    Expanded(child: Text('Ping interval (s)')),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setStateDialog(() => ping = (ping - 1).clamp(1, 9999)),
                    ),
                    Text('$ping'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setStateDialog(() => ping = (ping + 1).clamp(1, 9999)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Latency threshold
                Row(
                  children: [
                    Expanded(child: Text('Latency threshold (ms)')),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setStateDialog(() => latency = (latency - 1).clamp(0, 60000)),
                    ),
                    Text('$latency'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setStateDialog(() => latency = (latency + 1).clamp(0, 60000)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Failure probability (slider)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Failure probability'),
                    Slider(
                      value: failure.clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: failure.toStringAsFixed(2),
                      onChanged: (v) => setStateDialog(() => failure = v),
                    ),
                    Text('Value: ${failure.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),

                // Traffic load
                Row(
                  children: [
                    Expanded(child: Text('Traffic load')),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setStateDialog(() => traffic = (traffic - 1).clamp(0, 1000000)),
                    ),
                    Text('$traffic'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setStateDialog(() => traffic = (traffic + 1).clamp(0, 1000000)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () {
                // pass values back via outer scope
                Navigator.pop(context, true);
              }, child: const Text('Save')),
            ],
          );
        },
      ),
    );

    if (saved != true) return;

    final updated = device.copyWith(
      parameters: device.parameters.copyWith(
        pingInterval: ping,
        latencyThreshold: latency,
        failureProbability: failure,
        trafficLoad: traffic,
      ),
    );

    final idx = _devices.indexWhere((d) => d.id == device.id);
    if (idx == -1) return;

    setState(() {
      _devices[idx] = updated;
      _pushHistory();
    });
  }

  IconData getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pc':
        return Icons.computer;
      case 'router':
        return Icons.router;
      case 'switch':
        return Icons.switch_right;
      case 'server':
        return Icons.storage;
      case 'firewall':
        return Icons.security;
      default:
        return Icons.device_unknown;
    }
  }

  Widget _deviceChip(String type, {bool highlighted = false}) {
    return AnimatedContainer(
      margin: EdgeInsets.all(4),
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted ? Colors.blueAccent : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.4),
                  blurRadius: 6,
                )
              ]
            : [],
        border: highlighted
            ? Border.all(color: Colors.blueAccent, width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getDeviceIcon(type),
            size: 16,
            color: highlighted ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenario Editor'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _historyIndex > 0 ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: _historyIndex < _history.length - 1 ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete selected device',
            onPressed: _selectedDeviceId != null ? _deleteSelectedDevice : null,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Scenario',
            onPressed: _saveScenario,
          ),
        ],
      ),
      body: Column(
        children: [
          // CANVAS AREA - Takes most of the space
          Expanded(
            child: Container(
              // margin: EdgeInsets.all(8),
              color: Colors.white,
              child: DragTarget<String>(
                onAcceptWithDetails: (details) {
                  final pos = _globalToLocal(details.offset);
                  _addDeviceAt(details.data, pos);
                },
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDeviceId = null),
                    child: Stack(
                      key: _canvasKey,
                      children: [
                        // Grid background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPainter(),
                          ),
                        ),

                        // Connection Lines
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ConnectionPainter(_devices, _connections),
                          ),
                        ),

                        // Devices
                        ..._devices.map((d) {
                          final pos = d.position;
                          final selected = _selectedDeviceId == d.id;

                          return Positioned(
                            left: pos.x.toDouble(),
                            top: pos.y.toDouble(),
                              child: GestureDetector(
                                // Tap to edit parameters, long-press to select/connect
                                onTap: () => _editDeviceParameters(d),
                                onLongPress: () {
                                  if (_selectedDeviceId == null) {
                                    setState(() => _selectedDeviceId = d.id);
                                  } else if (_selectedDeviceId == d.id) {
                                    setState(() => _selectedDeviceId = null);
                                  } else {
                                    _toggleConnection(_selectedDeviceId!, d.id);
                                    setState(() => _selectedDeviceId = null);
                                  }
                                },
                                onPanUpdate: (details) {
                                  final pos = _globalToLocal(details.globalPosition);
                                  _updateDevicePosition(d.id, pos);
                                },
                                child: _deviceChip(d.type, highlighted: selected),
                              ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // PALETTE BOTTOM BAR
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const Text(
                  "DRAG DEVICES TO CANVAS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _deviceTypes.map(
                        (t) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Draggable<String>(
                            data: t,
                            feedback: Material(
                              color: Colors.transparent,
                              child: _deviceChip(t, highlighted: true),
                            ),
                            childWhenDragging:
                                Opacity(opacity: 0.4, child: _deviceChip(t)),
                            child: _deviceChip(t),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// GRID PAINTER (SUBTLE)
// -------------------------------------------------------
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300.withOpacity(0.3)
      ..strokeWidth = 0.6;

    const grid = 30.0;

    for (double x = 0; x < size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// -------------------------------------------------------
// CONNECTION PAINTER (SMOOTH LINES)
// -------------------------------------------------------
class _ConnectionPainter extends CustomPainter {
  final List<Device> devices;
  final List<List<String>> connections;

  _ConnectionPainter(this.devices, this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (final link in connections) {
      final aList = devices.where((d) => d.id == link[0]).toList();
      final bList = devices.where((d) => d.id == link[1]).toList();
      if (aList.isEmpty || bList.isEmpty) continue;
      final a = aList.first;
      final b = bList.first;
      final p1 = Offset(a.position.x.toDouble() + 35, a.position.y.toDouble() + 20);
      final p2 = Offset(b.position.x.toDouble() + 35, b.position.y.toDouble() + 20);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

//======Edit device properties=======

