import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/crime_model.dart';

class CrimeService {
  Future<List<Crime>> loadCrimes() async {
    final String response = await rootBundle.loadString('assets/crime_data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Crime.fromJson(json)).toList();
  }
}
