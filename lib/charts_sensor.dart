import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorDisplay extends StatefulWidget {
  @override
  _SensorDisplayState createState() => _SensorDisplayState();
}

class _SensorDisplayState extends State<SensorDisplay> {
  List<SensorData> _chartData = [];
  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _chartUpdateTimer;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _startListening();
    _startChartUpdate();
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
              'sensor_data_notifications', 'Sensor Data Channel',
              importance: Importance.max, priority: Priority.high, ticker: 'sensor_data_ticker');

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
        setState(() {
          _chartData.add(SensorData(DateTime.now().millisecondsSinceEpoch.toDouble(), acceleration));
        });
        if (acceleration > 50.0) {
          _showNotification('High Acceleration Detected', 'Acceleration value: $acceleration', 0);
        }
      });
    } catch (e) {
      print('Error starting accelerometer: $e');
    }
  }

  void _startChartUpdate() {
    _chartUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        // Keep only the latest 10 data points
        if (_chartData.length > 10) {
          _chartData.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null; // Nullify the subscription
    _chartUpdateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Display'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SfCartesianChart(
          primaryXAxis: NumericAxis(
            title: AxisTitle(text: 'Time'),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Acceleration'),
          ),
          series: <LineSeries<SensorData, double>>[
            LineSeries<SensorData, double>(
              dataSource: _chartData,
              xValueMapper: (SensorData data, _) => data.time,
              yValueMapper: (SensorData data, _) => data.value,
            ),
          ],
        ),
      ),
    );
  }
}

class SensorData {
  final double time;
  final double value;

  SensorData(this.time, this.value);
}
