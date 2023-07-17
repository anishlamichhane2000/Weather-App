// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import '../provider/weatherdata.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationController = TextEditingController();
  late SharedPreferences _prefs;
  late String _previousLocation;
  late bool _isEditMode = false;

  Future<Position?> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _fetchWeatherData(); // Fetch weather data when the screen is initially loaded
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    _prefs = await SharedPreferences.getInstance();
    _previousLocation = _prefs.getString('location') ?? '';
    _isEditMode = _previousLocation.isNotEmpty;
    setState(() {
      _locationController.text = _previousLocation;
    });
  }

  void _fetchWeatherData() async {
    final weatherData = Provider.of<WeatherData>(context, listen: false);
    if (_locationController.text.isNotEmpty) {
      weatherData.location = _locationController.text;
      _prefs.setString('location', _locationController.text);
    } else {
      final position = await _getCurrentPosition();
      if (position != null) {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          weatherData.latitude = position.latitude;
          weatherData.longitude = position.longitude;
          weatherData.location = '${placemark.locality}, ${placemark.country}';
        }
      }
    }
    weatherData.fetchWeatherData();
  }

  void _clearData() {
    final weatherData = Provider.of<WeatherData>(context, listen: false);
    weatherData.clearData();
    _locationController.text = '';
    _prefs.remove('location');
    setState(() {
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherData = Provider.of<WeatherData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
            icon: const Icon(Icons.help),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Location: ${weatherData.location}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Temperature: ${weatherData.temperature}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Condition: ${weatherData.conditionText}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Image.network(
                weatherData.conditionIcon.isNotEmpty
                    ? weatherData.conditionIcon
                    : 'https://img.freepik.com/premium-vector/photo-icon-picture-icon-image-sign-symbol-vector-illustration_64749-4409.jpg',
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _locationController,
                onChanged: (value) {
                  setState(() {
                    _isEditMode = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter location',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _fetchWeatherData,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
                child: Text(
                  _isEditMode ? 'Update' : 'View my Location',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearData,
        child: const Icon(Icons.clear),
      ),
    );
  }
}
