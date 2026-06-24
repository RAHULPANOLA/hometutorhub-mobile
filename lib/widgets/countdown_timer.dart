import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDateTime;
  final VoidCallback? onTimerComplete;

  const CountdownTimer({
    super.key,
    required this.targetDateTime,
    this.onTimerComplete,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.targetDateTime.difference(now);

    if (remaining.isNegative) {
      if (!_isComplete) {
        _isComplete = true;
        widget.onTimerComplete?.call();
      }
      if (mounted) {
        setState(() {
          _remaining = Duration.zero;
        });
      }
      _timer.cancel();
    } else {
      if (mounted) {
        setState(() {
          _remaining = remaining;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Started!',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '${days}d',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(' : ', style: TextStyle(color: Colors.white)),
          Text(
            '${hours}h',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(' : ', style: TextStyle(color: Colors.white)),
          Text(
            '${minutes}m',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(' : ', style: TextStyle(color: Colors.white)),
          Text(
            '${seconds}s',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
