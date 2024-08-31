import 'package:flutter/material.dart';
import '../models/crime_service.dart';
import '../services/crime_service.dart' as service_crime_service;
import '../services/location_service.dart';
import '../models/crime_model.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service_crime_service.CrimeService _crimeService = service_crime_service.CrimeService();
  final LocationService _locationService = LocationService();
  List<Crime> _crimes = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadCrimes();
    _getCurrentLocation();
  }

  Future<void> _loadCrimes() async {
    final crimes = await _crimeService.loadCrimes();
    setState(() {
      _crimes = crimes;
    });
    // Print the loaded crimes for debugging
    print('Loaded crimes: $_crimes');
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
      // Print the current position for debugging
      print('Current position: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}');
      _checkNearbyCrimes();
    } catch (e) {
      // Handle any errors while getting the location
      print('Error getting location: $e');
    }
  }

  void _checkNearbyCrimes() {
    if (_currentPosition == null) return;

    bool alertShown = false; // Flag to ensure only one notification is shown
    for (var crime in _crimes) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        crime.latitude,
        crime.longitude,
      );

      print('Checking crime: ${crime.crime}');
      print('Distance to crime: ${distanceInMeters.toStringAsFixed(2)} meters');

      if (distanceInMeters < 1000) { // Notify if within 1km
        if (!alertShown) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alert: You are near a reported crime area! Crime type: ${crime.crime}. Description: ${crime.description}'),
              duration: Duration(seconds: 5),
            ),
          );
          alertShown = true; // Ensure only one notification is shown
        }
        break; // Exit the loop after showing the notification
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crime Alert'),
      ),
      body: Center(
        child: _currentPosition == null
            ? CircularProgressIndicator()
            : Text(
          'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
