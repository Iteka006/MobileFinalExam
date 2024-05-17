import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ResidentialLocationScreen extends StatefulWidget {
  const ResidentialLocationScreen({Key? key}) : super(key: key);

  @override
  _ResidentialLocationScreenState createState() =>
      _ResidentialLocationScreenState();
}

class _ResidentialLocationScreenState extends State<ResidentialLocationScreen> {
  late GoogleMapController googleMapController;
  static const LatLng initialLocation = LatLng(-1.9818586, 30.1155791);
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: initialLocation, zoom: 14);

  Set<Marker> markers = {};
  TextEditingController searchController = TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _startLocationTracking();
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
          AndroidNotificationDetails('geofence_notifications', 'Geofence Channel',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'geofence_ticker');

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
          id, title, body, platformChannelSpecifics);
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Residential Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              setState(() {
                googleMapController = controller;
              });
            },
          ),
          if (isMoving) // Show a custom marker indicating movement
            Positioned(
              bottom: 16,
              right: 16,
              child: Icon(
                Icons.lightbulb_outline, // Change to your desired icon
                color: Colors.yellow, // Change to your desired color
                size: 40,
              ),
            ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search place...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _searchPlace();
                    },
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Code to get user's current location
          Position position = await _determinePosition();

          // Animate camera to user's current location
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14,
              ),
            ),
          );

          // Clear previous markers and add a marker for the current location
          markers.clear();
          markers.add(
            Marker(
              markerId: const MarkerId("currentLocation"),
              position: LatLng(position.latitude, position.longitude),
            ),
          );

          // Update the UI
          setState(() {});
        },
        label: Text("Current Location"),
        icon: Icon(Icons.location_history),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service is not enabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location Permissions are permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  Future<void> _searchPlace() async {
    // Clear previous markers
    markers.clear();

    try {
      // Perform geocoding to get the coordinates of the searched place
      List<Location> locations =
          await locationFromAddress(searchController.text);

      if (locations.isNotEmpty) {
        // Add marker for the searched place
        Marker searchedMarker = Marker(
          markerId: MarkerId('searchedPlace'),
          position: LatLng(locations[0].latitude, locations[0].longitude),
          infoWindow: InfoWindow(title: searchController.text),
        );

        markers.add(searchedMarker);

        // Move camera to the searched place
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locations[0].latitude, locations[0].longitude),
              zoom: 14,
            ),
          ),
        );

        setState(() {});
      } else {
        // Show error if the place is not found
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Place not found'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog for any other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while searching for the place.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _startLocationTracking() {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Handle location updates here
      // Check if the current location is inside the geofence and trigger actions accordingly
      // For simplicity, let's assume a predefined geofence around a home location
      double homeLatitude = -1.9818586;
      double homeLongitude = 30.1155791;
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        homeLatitude,
        homeLongitude,
      );

      if (distanceInMeters < 200) {
        // User is within the geofenced area (200 meters radius around home)
        // Trigger actions or notifications for being at home
        _showNotification('Geofence Alert', 'You are at home!', 0);
      } else {
        // User is outside the geofenced area
        // Trigger actions or notifications for being away from home
        _showNotification('Geofence Alert', 'You left home!', 0);
      }

      // Check if the device is moving
      double speed = position.speed ?? 0; // Get the current speed in m/s
      bool isDeviceMoving = speed > 0.1; // Adjust the threshold as needed

      setState(() {
        isMoving = isDeviceMoving;
      });
    });
  }
}
