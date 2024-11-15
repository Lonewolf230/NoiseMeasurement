import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  bool _isRecording = false;
  double noise = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _noiseMeter = NoiseMeter();
    _initializeNoiseMeter();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void _handleNoiseChange() {
    if (!_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  Future<void> _initializeNoiseMeter() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
  }

  void _startRecording() async {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen((NoiseReading reading) {
        setState(() {
          noise = (reading.meanDecibel);
          _isRecording = true;
        });
      });
    } catch (err) {
      print(err);
    }
  }

  void _stopRecording() async {
    _noiseSubscription?.cancel();
    setState(() {
      _isRecording = false;
      noise = 0.0;
    });
  }

  String _getNoiseLevel(double decibels) {
    if (decibels < 30) return 'Very Quiet';
    if (decibels < 50) return 'Quiet Room';
    if (decibels < 60) return 'Normal Conversation';
    if (decibels < 70) return 'Office Noise';
    if (decibels < 80) return 'Busy Street';
    if (decibels < 90) return 'Heavy Traffic';
    if (decibels < 100) return 'Very Loud';
    if (decibels < 120) return 'Concert Level';
    return 'Dangerous Level';
  }

  Color _getProgressColor(double value) {
    if (value <= 0.5) {
      return Colors.green;
    } else if (value <= 0.60) {
      return Colors.orange;
    } else if (value <= 0.71) {
      return Colors.red;
    } else {
      return const Color.fromARGB(255, 253, 18, 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = (noise / 140).clamp(0.0, 1.0);

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Stack(alignment: Alignment.center, children: [
            SizedBox(
              height: 300,
              width: 300,
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
                value: progressValue,
                valueColor:
                    AlwaysStoppedAnimation(_getProgressColor(progressValue)),
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            Text(
              '${(noise).toStringAsFixed(1)} dB',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
          ]),
          const SizedBox(
            height: 50,
          ),
          Text(
            _isRecording ? 'Measuring...' : 'Tap mic to start',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(
            height: 50,
          ),
          IconButton(
              onPressed: _handleNoiseChange,
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.red : Colors.blue,
                size: 40,
              )),
          const SizedBox(
            height: 40,
          ),
          Text(
            _getNoiseLevel(noise),
            style: TextStyle(
                color: _getProgressColor(progressValue),
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
