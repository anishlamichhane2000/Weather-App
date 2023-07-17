import 'package:flutter/material.dart';
import 'package:moru_assiqnment/screens/help_screen.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'provider/weatherdata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/help', // Updated initial route
        routes: {
          '/': (context) => const HomeScreen(),
          '/help': (context) => const HelpScreen(),
        },
      ),
    );
  }
}
