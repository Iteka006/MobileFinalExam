import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class StepCounter extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int _stepsCount = 0;
  StreamSubscription<AccelerometerEvent>? _subscription;
  static const double threshold = 200.0; // Adjust as needed
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _startListening();
  }

  void _initLocalNotifications() {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body, int id) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'step_counter_notifications', 'Step Counter Channel',
              importance: Importance.max, priority: Priority.high, ticker: 'step_counter_ticker');

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
          id, title, body, platformChannelSpecifics);
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> _startListening() async {
    try {
      _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
        double acceleration = event.x * event.x + event.y * event.y + event.z * event.z;
        if (acceleration > threshold) {
          setState(() {
            _stepsCount++;
          });
          _showNotification('Motion Detected', 'You took a step!', 0); // Trigger notification on motion detection
        }
      });
    } catch (e) {
      print('Error starting accelerometer: $e');
      // Handle error here, for example, show a message to the user
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null; // Nullify the subscription
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Steps Count: $_stepsCount',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _stepsCount = 0;
                });
              },
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
