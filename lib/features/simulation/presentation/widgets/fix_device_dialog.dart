import 'dart:async';
import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/simulation/data/models/device_error.dart';
import 'package:netsim_mobile/features/devices/data/models/device_parameters.dart';

class FixDeviceDialog extends ConsumerStatefulWidget {
  final DeviceError error;
  final Parameters currentParameters;
  final Future<(bool success, int points)> Function(
      DeviceError error, Map<String, dynamic> fixData) onFix;
  
  const FixDeviceDialog({
    super.key,
    required this.error,
    required this.currentParameters,
    required this.onFix,
  });

  @override
  ConsumerState<FixDeviceDialog> createState() => _FixDeviceDialogState();
}

class _FixDeviceDialogState extends ConsumerState<FixDeviceDialog> {
  bool _isValid = false;
  Map<String, dynamic> _fixData = {};
  Timer? _timeoutTimer;
  Timer? _pingCooldownTimer;

  // State variables for each fix type
  double _latencyValue = 0;
  Set<String> _completedSteps = {};
  double _loadValue = 0;
  int _pingCount = 0;
  int _remainingTime = 0;
  String? _selectedRoute;

  // Offline fix state variables - SET INITIAL VALUES OUTSIDE VALID RANGES
  double _offlineLatency = 150;  // Outside 60-120 range
  double _offlineOverload = 5;   // Outside 10-60 range  
  double _offlinePing = 90;      // Outside 40-80 range

  @override
  void initState() {
    super.initState();
    _initializeFixData();
    _timeoutTimer = Timer(const Duration(seconds: 20), _onTimeout);
  }

  void _initializeFixData() {
    switch (widget.error.type) {
      case DeviceErrorType.highLatency:
        final currentLatency = widget.error.metadata['latencyValue'] as int;
        _latencyValue = currentLatency.toDouble();
        final targetLatency = widget.error.metadata['targetLatency'] as int? ?? 100;
        _isValid = _latencyValue < targetLatency;
        _fixData = {'newLatency': _latencyValue.round()};
        break;

      case DeviceErrorType.packetLoss:
        _completedSteps = {};
        _isValid = false;
        _fixData = {'completedSteps': []};
        break;

      case DeviceErrorType.overload:
        final currentLoad = widget.error.metadata['currentLoad'] as int? ?? 80;
        _loadValue = currentLoad.toDouble();
        _isValid = _loadValue < 70;
        _fixData = {'newLoad': _loadValue.round()};
        break;

      case DeviceErrorType.pingTimeout:
        _pingCount = 0;
        _remainingTime = 0;
        _isValid = false;
        _fixData = {'pingCount': _pingCount};
        break;

      case DeviceErrorType.offline:
        // Don't use metadata values - start with invalid values that user must fix
        _fixData = {
          'latencyThreshold': _offlineLatency.round(),
          'overload': _offlineOverload.round(),
          'pingInterval': _offlinePing.round(),
         
        };
        _validateOfflineFix(); // This will set _isValid to false initially
        break;

      case DeviceErrorType.routingError:
        _selectedRoute = null;
        _isValid = false;
        _fixData = {};
        break;
    }
  }

  void _onTimeout() {
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fix attempt timed out!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _pingCooldownTimer?.cancel();
    super.dispose();
  }

  Widget _buildLatencyFix() {
    final targetLatency = widget.error.metadata['targetLatency'] as int? ?? 100;
    final thresholdMax = widget.currentParameters.latencyThreshold.toDouble();
    final sliderMax = max(thresholdMax, _latencyValue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_latencyValue.round()} ms',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isValid ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adjust Latency below ${targetLatency}ms',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: _latencyValue.clamp(0, sliderMax),
          min: 0,
          max: sliderMax,
          divisions: 100,
          label: '${_latencyValue.round()}ms',
          onChanged: (value) {
            setState(() {
              _latencyValue = value;
              _isValid = value < targetLatency;
              _fixData = {'newLatency': value.round()};
            });
          },
        ),
        if (!_isValid)
          const Text(
            'Latency must be below target',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildPacketLossFix() {
    final steps = ['Check Cables', 'Reset Buffer', 'Clear Queue'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...steps.map((step) => CheckboxListTile(
              title: Text(step),
              value: _completedSteps.contains(step),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _completedSteps.add(step);
                  } else {
                    _completedSteps.remove(step);
                  }
                  _isValid = _completedSteps.length == 3;
                  _fixData = {'completedSteps': _completedSteps.toList()};
                });
              },
            )),
        if (!_isValid && _completedSteps.isNotEmpty)
          Text(
            '${3 - _completedSteps.length} steps remaining',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildOverloadFix() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_loadValue.round()}%',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isValid ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Reduce load below 70%',
          style: TextStyle(fontSize: 16),
        ),
        Slider(
          value: _loadValue,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${_loadValue.round()}%',
          onChanged: (value) {
            setState(() {
              _loadValue = value;
              _isValid = value < 70;
              _fixData = {'newLoad': value.round()};
            });
          },
        ),
        if (!_isValid)
          const Text(
            'Load must be below 70%',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildPingTimeoutFix() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pings: $_pingCount/3',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_remainingTime > 0)
          Text(
            'Cooling down... $_remainingTime',
            style: const TextStyle(color: Colors.orange),
          ),
        ElevatedButton.icon(
          onPressed: _remainingTime > 0
              ? null
              : () {
                  setState(() {
                    _pingCount++;
                    _remainingTime = 3;
                    _isValid = _pingCount >= 3;
                    _fixData = {'pingCount': _pingCount};
                  });

                  _pingCooldownTimer?.cancel();
                  _pingCooldownTimer = Timer.periodic(
                    const Duration(seconds: 1),
                    (timer) {
                      if (!mounted) {
                        timer.cancel();
                        return;
                      }
                      setState(() {
                        _remainingTime--;
                        if (_remainingTime <= 0) {
                          timer.cancel();
                        }
                      });
                    },
                  );
                },
          icon: const Icon(Icons.network_ping),
          label: Text(_remainingTime > 0 ? 'Cooling down...' : 'Send Ping'),
        ),
        if (_pingCount > 0 && !_isValid)
          Text(
            '${3 - _pingCount} more pings needed',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
      ],
    );
  }


  Widget _buildRoutingFix() {
    final correctRoute = widget.error.metadata['correctRoute'] as String;
    final wrongOptions = List.generate(2, (i) => 'Device_${i + 1}')
        .where((r) => r != correctRoute)
        .toList();
    final options = [correctRoute, ...wrongOptions]..shuffle();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Select Correct Route',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((route) => RadioListTile<String>(
              title: Text(route),
              value: route,
              groupValue: _selectedRoute,
              onChanged: (value) {
                setState(() {
                  _selectedRoute = value;
                  _isValid = value == correctRoute;
                  _fixData = {'selectedRoute': value};
                });
              },
            )),
        if (_selectedRoute != null && !_isValid)
          const Text(
            'Incorrect route selected',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }


  Widget _buildOfflineFix() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Adjust all parameters to restore device',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Show current values and target ranges
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Target Ranges:',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue,fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('Latency: 60-120ms '),
              Text("Overload: 10-60% "),
              Text('Ping: 40-80ms '),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildOfflineSlider('Latency Threshold (ms)', _offlineLatency, 0, 200, (v) {
          setState(() {
            _offlineLatency = v;
            _fixData['latencyThreshold'] = v.round();
            _validateOfflineFix();
          });
        }),

        _buildOfflineSlider('Overload (%)', _offlineOverload, 0, 100, (v) {
          setState(() {
            _offlineOverload = v;
            _fixData['overload'] = v.round();
            _validateOfflineFix();
          });
        }),

        _buildOfflineSlider('Ping Interval (ms)', _offlinePing, 0, 200, (v) {
          setState(() {
            _offlinePing = v;
            _fixData['pingInterval'] = v.round();
            _validateOfflineFix();
          });
        }),


        const SizedBox(height: 16),
        
        // Visual feedback
        if (_isValid)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'All within optimal ranges!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  _getValidationMessage(),
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOfflineSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    final isValid = _isParameterValid(label, value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red,
              size: 16,
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
        Text(
          _getRangeText(label),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  bool _isParameterValid(String label, double value) {
    switch (label) {
      case 'Latency Threshold (ms)':
        return value >= 60 && value <= 120;
      case 'Overload (%)':
        return value >= 10 && value <= 60;
      case 'Ping Interval (ms)':
        return value >= 40 && value <= 80;
      default:
        return false;
    }
  }

  String _getRangeText(String label) {
    switch (label) {
      case 'Latency Threshold (ms)':
        return 'Range: 60-120ms';
      case 'Overload (%)':
        return 'Range: 10-60%';
      case 'Ping Interval (ms)':
        return 'Range: 40-80ms';
      default:
        return '';
    }
  }

  String _getValidationMessage() {
    final issues = <String>[];
    
    if (_offlineLatency < 60 || _offlineLatency > 120) {
      issues.add('Latency must be 60-120ms');
    }
    if (_offlineOverload < 10 || _offlineOverload > 60) {
      issues.add('Overload must be 10-60%');
    }
    if (_offlinePing < 40 || _offlinePing > 80) {
      issues.add('Ping must be 40-80ms');
    }
    return issues.isEmpty ? 'All parameters valid!' : issues.join(', ');
  }

  void _validateOfflineFix() {
    final latencyOK = _offlineLatency >= 60 && _offlineLatency <= 120;
    final overloadOK = _offlineOverload >= 10 && _offlineOverload <= 60;
    final pingOK = _offlinePing >= 40 && _offlinePing <= 80;
   

    _isValid = latencyOK && overloadOK && pingOK;
  }

  Widget _buildCurrentFixUI() {
    switch (widget.error.type) {
      case DeviceErrorType.highLatency:
        return _buildLatencyFix();
      case DeviceErrorType.packetLoss:
        return _buildPacketLossFix();
      case DeviceErrorType.overload:
        return _buildOverloadFix();
      case DeviceErrorType.pingTimeout:
        return _buildPingTimeoutFix();
      case DeviceErrorType.offline:
        return _buildOfflineFix();
      case DeviceErrorType.routingError:
        return _buildRoutingFix();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Fix ${widget.error.type.displayName}'),
      content: SingleChildScrollView(child: _buildCurrentFixUI()),
      actions: [
        TextButton(
          onPressed: () {
            _timeoutTimer?.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isValid
              ? () async {
                  _timeoutTimer?.cancel();
                  _pingCooldownTimer?.cancel();
                  try {
                    await widget.onFix(widget.error, _fixData);
                  } catch (e) {
                    debugPrint('Error while applying fix: $e');
                  } finally {
                    if (mounted) Navigator.of(context).pop();
                  }
                }
              : null,
          child: const Text('Apply Fix'),
        ),
      ],
    );
  }
}