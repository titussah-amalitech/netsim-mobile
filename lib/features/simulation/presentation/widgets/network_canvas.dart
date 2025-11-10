// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:netsim_mobile/features/devices/data/models/device_model.dart';

class NetworkCanvas extends StatefulWidget {
  final List<Device> devices;
  final List<List<String>> connections;
  final Set<String> activeErrorDeviceIds;
  final Function(String deviceId)? onDeviceTap;
  final Map<String, DeviceWidgetController>? controllers;
  final bool isPaused;

  const NetworkCanvas({
    super.key,
    required this.devices,
    required this.connections,
    this.activeErrorDeviceIds = const {},
    this.onDeviceTap,
    this.controllers,
    required bool showLabels,
    this.isPaused = false,
  });
  @override
  State<NetworkCanvas> createState() => _NetworkCanvasState();
}

class _NetworkCanvasState extends State<NetworkCanvas> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      if (widget.isPaused) {
    _controller.stop();
  } else if (!_controller.isAnimating) {
    _controller.repeat();
  }
    return Container(
      width: MediaQuery.of(context).size.width*0.95,
      height: MediaQuery.of(context).size.height*0.80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
       child: LayoutBuilder(
         builder: (context, constraints) {
           return IgnorePointer(
  ignoring: widget.isPaused, // 👈 disable interaction when paused
  child: Stack(
    children: [
      CustomPaint(
        painter: NetworkConnectionsPainter(
          devices: widget.devices,
          connections: widget.connections,
          animation: _controller,
          offlineDeviceIds: widget.activeErrorDeviceIds,
        ),
        size: Size(constraints.maxWidth, constraints.maxHeight),
      ),
      ...widget.devices.asMap().entries.map((entry) {
        final idx = entry.key;
        final device = entry.value;
        return DeviceWidget(
          key: ValueKey('${device.id}-$idx'),
          device: device,
          hasError: widget.activeErrorDeviceIds.contains(device.id) &&
              !device.status.online,
          onTap: () => widget.onDeviceTap?.call(device.id),
          controller: widget.controllers != null
              ? widget.controllers![device.id]
              : null,
        );
      }).toList(),
    ],
  ),
);
  },
      ),
    );
  }
}

class DeviceWidget extends StatefulWidget {
  final Device device;
  final bool hasError;
  final VoidCallback? onTap;
  final DeviceWidgetController? controller;

  const DeviceWidget({
    super.key,
    required this.device,
    this.hasError = false,
    this.onTap,
    this.controller,
  });

  @override
  State<DeviceWidget> createState() => _DeviceWidgetState();
}

class _DeviceWidgetState extends State<DeviceWidget>
    with SingleTickerProviderStateMixin {
  late Timer _blinkTimer;
  bool _isBlinkingVisible = true;

  @override
  void initState() {
    super.initState();

    // Blinking effect for error state
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (widget.hasError) {
        setState(() => _isBlinkingVisible = !_isBlinkingVisible);
      } else {
        if (!_isBlinkingVisible) setState(() => _isBlinkingVisible = true);
      }
    });

    // Register controller callbacks if provided
    widget.controller?._bind(
      onSuccess: _playSuccessGlow,
      onFailure: _playFailureShake,
    );
  }

  @override
  void didUpdateWidget(covariant DeviceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset blink visibility if error cleared
    if (!widget.hasError && oldWidget.hasError) {
      setState(() => _isBlinkingVisible = true);
    }
  }

  @override
  void dispose() {
    _blinkTimer.cancel();
    _glowController?.dispose();
    _shakeController?.dispose();
    widget.controller?._unbind();
    super.dispose();
  }

  // --- Animations for success (glow) and failure (shake) ---
  AnimationController? _glowController;
  AnimationController? _shakeController;

  void _ensureGlowController() {
    if (_glowController != null) return;
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _ensureShakeController() {
    if (_shakeController != null) return;
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) _shakeController!.reset();
    });
  }

  void _playSuccessGlow() {
    _ensureGlowController();
    _glowController!
      ..stop()
      ..value = 0.0
      ..forward().then((_) => _glowController!.reverse());
    // schedule rebuilds
    _glowController!.addListener(() => setState(() {}));
  }

  void _playFailureShake() {
    _ensureShakeController();
    _shakeController!
      ..stop()
      ..value = 0.0
      ..forward();
    _shakeController!.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    const deviceVisualSize = 64.0;
    final half = deviceVisualSize / 2;

    final isError = widget.hasError;
    final isOnline = widget.device.status.online;

    // Compute shake offset
    double shakeOffsetX = 0;
    if (_shakeController != null) {
      final t = _shakeController!.value;
      // oscillate left-right using sine
      shakeOffsetX = math.sin(t * math.pi * 4) * 8.0;
    }

    final glowVal = _glowController?.value ?? 0.0;

    return Positioned(
      left: widget.device.position.x.toDouble() - half,
      top: widget.device.position.y.toDouble() - half,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.translate(
          offset: Offset(shakeOffsetX, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: deviceVisualSize,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isError
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isError
                    ? (_isBlinkingVisible
                        ? Theme.of(context).colorScheme.error
                        : Colors.transparent)
                    : (isOnline ? Colors.green : Colors.grey),
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                if (isError)
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                else if (isOnline)
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3 + (glowVal * 0.5)),
                    blurRadius: 8 + (glowVal * 12),
                    spreadRadius: 1 + (glowVal * 6),
                  )
                else
                  BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getDeviceIcon(widget.device.type),
                  size: 24,
                  color: isError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.device.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'router':
        return LucideIcons.router;
      case 'switch':
        return LucideIcons.network;
      case 'pc':
        return LucideIcons.monitor;
      case 'server':
        return LucideIcons.server;
      case 'firewall':
        return LucideIcons.shield;
      default:
        return LucideIcons.server;
    }
  }
}

class NetworkConnectionsPainter extends CustomPainter {
  final List<Device> devices;
  final List<List<String>> connections;
  final Listenable animation;
  final Set<String> offlineDeviceIds;

  NetworkConnectionsPainter({
    required this.devices,
    required this.connections,
    required this.animation,
    this.offlineDeviceIds = const {},
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Determine current animation phase in logical pixels.
    double phase = 0.0;
    try {
      if (animation is Animation<double>) {
        final animValue = (animation as Animation<double>).value;
        // Normal connections move 3x faster than error connections
        final baseSpeed = 18.0; // Base unit (dash+gap length)
        phase = animValue * baseSpeed * 3.0; // Faster for normal state
      }
    } catch (_) {
      phase = 0.0;
    }

    // Draw all connections from the saved connection list
    for (final connection in connections) {
      final deviceA = devices.firstWhere((d) => d.id == connection[0]);
      final deviceB = devices.firstWhere((d) => d.id == connection[1]);
      
      final start = Offset(
        deviceA.position.x.toDouble(),
        deviceA.position.y.toDouble(),
      );
      final end = Offset(
        deviceB.position.x.toDouble(),
        deviceB.position.y.toDouble(),
      );

      final isOffline = offlineDeviceIds.contains(deviceA.id) ||
          offlineDeviceIds.contains(deviceB.id) ||
          !deviceA.status.online ||
          !deviceB.status.online;

      // Calculate pulse effect for error connections
      final errorPulse = isOffline
          ? 0.6 + (0.3 * math.sin((animation as Animation<double>).value * math.pi * 2))
          : 0.7;

      // THICKER CONNECTION LINES - increased from 2.5 to 4.0
      final paint = Paint()
        ..strokeWidth = 4.0 // Increased from 2.5 to 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = isOffline
            ? Colors.red.withOpacity(errorPulse)
            : Colors.lightBlue.withOpacity(0.7);

      // Use different speeds based on connection state
      if (isOffline) {
        // SLOW animation for error connections
        final slowPhase = (animation as Animation<double>).value * 6.0; // Much slower
        _drawDashedLineFallback(canvas, start, end, paint, 
            dash: 12, gap: 8, phase: slowPhase);
      } else {
        // FAST animation for normal connections
        _drawDashedLineFallback(canvas, start, end, paint, 
            dash: 16, gap: 6, phase: phase);
      }
    }
  }

  void _drawDashedLineFallback(Canvas canvas, Offset a, Offset b, Paint paint,
      {double dash = 10, double gap = 8, double phase = 0}) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist;
    final uy = dy / dist;
    
    double offset = -phase % (dash + gap);
    while (offset < dist) {
      final start = offset.clamp(0, dist);
      final end = (offset + dash).clamp(0, dist);
      if (end > start) {
        final p1 = Offset(a.dx + ux * start, a.dy + uy * start);
        final p2 = Offset(a.dx + ux * end, a.dy + uy * end);
        canvas.drawLine(p1, p2, paint);
      }
      offset += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant NetworkConnectionsPainter oldDelegate) {
    return oldDelegate.devices != devices ||
        oldDelegate.offlineDeviceIds != offlineDeviceIds ||
        oldDelegate.animation != animation;
  }
}

/// Controller that allows external widgets to trigger animations on a DeviceWidget.
class DeviceWidgetController {
  void Function()? _onSuccess;
  void Function()? _onFailure;

  void _bind({void Function()? onSuccess, void Function()? onFailure}) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
  }

  void _unbind() {
    _onSuccess = null;
    _onFailure = null;
  }

  /// Trigger success glow animation on the target DeviceWidget
  void playSuccess() => _onSuccess?.call();

  /// Trigger failure shake animation on the target DeviceWidget
  void playFailure() => _onFailure?.call();
}