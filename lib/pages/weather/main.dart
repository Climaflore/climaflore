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
  int? _apparentTemperature;
  late int _weatherCode;
  String? _weatherIcon; // Declare this variable to store the icon path

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
      bool isDay = data['current']['is_day'] == 1;
      int weatherCode = data['current']['weather_code'];

      setState(() {
        _temperature = (data['current']['temperature_2m'] as double).round();
        _apparentTemperature =
            (data['current']['apparent_temperature'] as double).round();
        _weatherCode = weatherCode;
        _weatherIcon = getWeatherIcon(weatherCode, isDay);
      });
    } catch (e) {
      print('Failed to load weather data: $e');
    }
  }

  String getWeatherIcon(int code, bool isDay) {
    String timeOfDay = isDay ? 'Light' : 'Dark';
    switch (code) {
      case 0:
        return 'Weather Type-Clear, Colour-$timeOfDay.png';
      case 1:
      case 2:
      case 3:
        return 'Weather Type-Normal, Colour-$timeOfDay.png';
      case 45:
      case 48:
        return 'Weather Type-Fog, Colour-$timeOfDay.png';
      case 51:
      case 53:
      case 55:
        return 'Weather Type-Drizzle, Colour-$timeOfDay.png';
      case 56:
      case 57:
        return 'Weather Type-Freezing Drizzle, Colour-$timeOfDay.png';
      case 61:
      case 63:
      case 65:
        return 'Weather Type-Rainy, Colour-$timeOfDay.png';
      case 66:
      case 67:
        return 'Weather Type-Freezing Rain, Colour-$timeOfDay.png';
      case 71:
      case 73:
      case 75:
        return 'Weather Type-Snow, Colour-$timeOfDay.png';
      case 77:
        return 'Weather Type-Snow Grains, Colour-$timeOfDay.png';
      case 80:
      case 81:
      case 82:
        return 'Weather Type-Sunny Rain, Colour-$timeOfDay.png';
      case 85:
      case 86:
        return 'Weather Type-Snow Showers, Colour-$timeOfDay.png';
      case 95:
      case 96:
      case 99:
        return 'Weather Type-Thunder, Colour-$timeOfDay.png';
      default:
        return 'Weather Type-Normal, Colour-$timeOfDay.png'; // Default icon if code is not recognized
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20.0),
              Row(
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
                  if (_weatherIcon != null)
                    Expanded(
                      child: Image.asset('assets/icons/$_weatherIcon',
                          fit: BoxFit.cover),
                    ),
                ],
              ),
              if (_apparentTemperature != null)
                Text(
                  'Feels like $_apparentTemperature°C',
                  style: const TextStyle(fontSize: 60, color: Colors.white70),
                ),
              Text(
                'Weather Code: $_weatherCode', // Displaying weather code for debug or information
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
