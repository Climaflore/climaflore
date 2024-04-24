import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaFlore',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({Key? key}) : super(key: key);

  @override
  _WeatherHomeScreenState createState() => _WeatherHomeScreenState();
}

class WeatherData {
  final int? temperature;

  WeatherData({this.temperature});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['current']['temperature_2m'] as double?)?.round(),
    );
  }
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  int? _temperature;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    const apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=45.757&longitude=4.726&current=temperature_2m,apparent_temperature,is_day,weather_code&timezone=auto';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);
      setState(() {
        _temperature = (data['current']['temperature_2m'] as double?)?.round();
      });
    } catch (e) {
      print('Failed to load weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text('ClimaFlore'),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                // Logique de navigation ou autre
              },
            ),
            // Ajoutez d'autres éléments de navigation ici si nécessaire
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0), // Add spacing above the temperature
              if (_temperature != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left:
                            50.0), // Adjust this value to move the text more or less to the left
                    child: Text(
                      '$_temperature°C',
                      style: const TextStyle(
                        fontSize: 85,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
