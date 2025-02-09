import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DeliveryTracker());
  }
}

class DeliveryTracker extends StatefulWidget {
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
    // Check location permissions first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle denied permissions
        return;
      }
    }
    
    // Get initial position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
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
          desiredAccuracy: LocationAccuracy.high
        );
        
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        await _sendLocationUpdate(position);
        
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentLocation)
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
          'location': [position.longitude, position.latitude]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delivery Tracker')),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          _mapController?.moveCamera(
            CameraUpdate.newLatLng(_currentLocation)
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