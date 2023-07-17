// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherData with ChangeNotifier {
  String temperature = '';
  String conditionText = '';
  String conditionIcon = '';
  final apiKey = '0cbbbb8f5bce411190f171744231407';
  String _location = '';
  double _latitude = 0.0;
  double _longitude = 0.0;

  String get location => _location;

  set location(String value) {
    _location = value;
    notifyListeners();
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  Future<void> fetchWeatherData() async {
    String url = '';

    if (_location.isEmpty) {
      url =
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$_latitude,$_longitude';
    } else {
      url =
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$_location';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        temperature = current['temp_c'].toString();
        conditionText = current['condition']['text'];
        conditionIcon = 'https:' + current['condition']['icon'];
      } else {
        temperature = '';
        conditionText = 'Error retrieving weather data';
        conditionIcon = '';
      }
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      temperature = '';
      conditionText = 'Error retrieving weather data';
      conditionIcon = '';
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void clearData() {
    location = '';
    latitude = 0.0;
    longitude = 0.0;
    temperature = '';
    conditionText = '';
    conditionIcon = '';
    notifyListeners();
  }
}
