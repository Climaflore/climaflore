import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const WeatherHomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
  int? _apparentTemperature;
  int? _weatherCode;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    const apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=45.760002&longitude=4.72&current=temperature_2m,apparent_temperature,is_day,weather_code&timezone=auto';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);
      int weatherCode = data['current']['weather_code'];

      setState(() {
        _temperature = (data['current']['temperature_2m'] as double).round();
        _apparentTemperature =
            (data['current']['apparent_temperature'] as double).round();
        _weatherCode = weatherCode;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load weather data: $e');
    }
  }

  String getWeatherDescription(int weatherCode) {
    if (weatherCode case 0) {
      return "Clear sky";
    } else if (weatherCode case 1) {
      return "Mainly clear";
    } else if (weatherCode case 2) {
      return "Mainly clear";
    } else if (weatherCode case 3) {
      return "Mainly clear";
    } else if (weatherCode case 45) {
      return "Fog and depositing rime fog";
    } else if (weatherCode case 48) {
      return "Fog and depositing rime fog";
    } else if (weatherCode case 51 || 53 || 55) {
      return "Drizzle: Light, moderate, or dense intensity";
    } else if (weatherCode case 56 || 57) {
      return "Freezing Drizzle: Light or dense intensity";
    } else if (weatherCode case 61 || 63 || 65) {
      return "Rain: Slight, moderate, or heavy intensity";
    } else if (weatherCode case 66 || 67) {
      return "Freezing Rain: Light or heavy intensity";
    } else if (weatherCode case 71 || 73 || 75) {
      return "Snow fall: Slight, moderate, or heavy intensity";
    } else if (weatherCode case 77) {
      return "Snow grains";
    } else if (weatherCode case 80 || 81 || 82) {
      return "Rain showers: Slight, moderate, or violent";
    } else if (weatherCode case 85 || 86) {
      return "Snow showers: Slight or heavy";
    } else if (weatherCode case 95 || 96 || 99) {
      return "Thunderstorm: Slight or moderate";
    } else {
      return "Unknown weather code";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climaflore'),
        backgroundColor: Colors.blue.shade100,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.lightBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Align the row to the center
              children: [
                Expanded(
                  child: Text(
                    '${_temperature ?? ""}°C',
                    style: const TextStyle(
                        fontSize: 85,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (_apparentTemperature != null)
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Feels like $_apparentTemperature°C',
                    style: const TextStyle(fontSize: 25, color: Colors.white70),
                  ),
                ],
              ),
            const SizedBox(
                height: 10),
            if (_weatherCode != null)
              Text(
              getWeatherDescription(_weatherCode!),
              style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
          ]),
        ),
      ),
    );
  }
}
