import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import your LoginPage

class DeliveryTracker extends StatefulWidget {
  final String userEmail;

  DeliveryTracker({Key? key, required this.userEmail}) : super(key: key);

  @override
  _DeliveryTrackerState createState() => _DeliveryTrackerState();
}

class _DeliveryTrackerState extends State<DeliveryTracker> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = LatLng(0, 0);
  String driverId = 'DriverOne';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _startTracking();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startTracking() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        await _sendLocationUpdate(position);

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentLocation),
          );
        }
      } catch (e) {
        print('Error updating location: $e');
      }
    });
  }

  Future<void> _sendLocationUpdate(Position position) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/tracking/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'driverId': driverId,
          'location': [position.longitude, position.latitude],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Location updated successfully');
      } else {
        print('Failed to update location: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  void _showUserInfoDialog() {
    String email = widget.userEmail;
    String role = 'Customer'; // Hardcoded role

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Account Details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email),
                SizedBox(width: 10),
                Text(email),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text(role),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('http://localhost:3100/api/v1/users/logout'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Logout successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Logout failed: ${responseData['message']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logout failed: Server error"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Container(
          width: double.infinity,
          child: Center(
            child: Text(
              'Delivery Tracker',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              child: Text(
                widget.userEmail.isNotEmpty ? widget.userEmail[0].toUpperCase() : 'U',
                style: TextStyle(color: Colors.blue),
              ),
              backgroundColor: Colors.white,
            ),
            onPressed: _showUserInfoDialog, // Corrected this line
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          _mapController?.moveCamera(
            CameraUpdate.newLatLng(_currentLocation),
          );
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId('driver'),
            position: _currentLocation,
          ),
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}