import 'dart:async';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading JSON file
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _crimes = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadCrimesFromFile();
    _getCurrentLocation();
  }

  Future<void> _loadCrimesFromFile() async {
    try {
      String jsonString = await rootBundle.loadString('assets/crime_data.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);
      setState(() {
        _crimes = jsonResponse.map((crime) => crime as Map<String, dynamic>).toList();
      });
      print('Loaded crimes: $_crimes');
    } catch (e) {
      print('Error loading crime data: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
      print('Current position: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}');
      _checkNearbyCrimes();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _checkNearbyCrimes() {
    if (_currentPosition == null || _crimes.isEmpty) return;

    for (var crime in _crimes) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        crime['latitude'],
        crime['longitude'],
      );

      print('Checking crime: ${crime['crime']} at distance: ${distanceInMeters.toStringAsFixed(2)} meters');

      if (distanceInMeters < 100) { // 100 meters threshold for exact location match
        _showPopup(crime);
        break; // Exit after showing the first notification
      }
    }
  }

  void _showPopup(Map<String, dynamic> crime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crime Alert'),
          content: Text(
            'You are near a reported crime area!\n\nCrime type: ${crime['crime']}\nDescription: ${crime['description']}',
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Auto-dismiss the popup after 1 minute (60 seconds)
    Timer(Duration(minutes: 1), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
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
