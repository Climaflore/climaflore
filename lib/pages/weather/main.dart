import 'package:climaflore/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../settings.dart';

import 'package:intl/intl.dart';

void main() {
  runApp(const MainWeather());
}

class MainWeather extends StatelessWidget {
  const MainWeather({super.key});

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

class HourlyWeather {
  final String time;
  final double temperature;
  final int precipitationProbability;
  final String weatherDescription;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherDescription,
  });

  static HourlyWeather fromJson(
      Map<String, dynamic> json, int index, String weatherDescription) {
    return HourlyWeather(
      time: json['hourly']['time'][index],
      temperature: json['hourly']['temperature_2m'][index],
      precipitationProbability: json['hourly']['precipitation_probability']
          [index],
      weatherDescription: weatherDescription,
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
  List<HourlyWeather> hourlyWeather = [];

  int? _temperature;
  int? _apparentTemperature;
  int? _weatherCode;

  String _formatTemperature(double temperature) {
    switch (Config.unit) {
      case TemperatureUnit.fahrenheit:
        // Conversion de Celsius en Fahrenheit
        return '${(temperature * 9 / 5 + 32).round()}°F';
      case TemperatureUnit.celsius:
      default:
        return '${temperature.round()}°C';
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    const apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=45.7453&longitude=4.7232&current=temperature_2m,apparent_temperature,is_day,weather_code&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_probability_max&timezone=auto';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);
      List<HourlyWeather> loadedHourlyWeather = [];

      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd')
          .format(now); // Utilisez DateFormat de 'package:intl/intl.dart';

      ///////////////////////////////////////////////////////////////////////////////////////////
      // Utilisation ultérieure
      // String tomorrowDate =
      //     DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));
      ///////////////////////////////////////////////////////////////////////////////////////////

      // On récupère les données météorologiques pour les prochaines heures mais seulement pour la journée actuelle
      for (int i = 0; i < data['hourly']['time'].length; i++) {
        String hourlyDate = data['hourly']['time'][i].substring(0, 10);
        if (hourlyDate == todayDate) {
          loadedHourlyWeather.add(HourlyWeather.fromJson(data, i,
              getWeatherDescription(data['hourly']['weather_code'][i])));
        }
      }

      setState(() {
        hourlyWeather = loadedHourlyWeather;
        _temperature = (data['current']['temperature_2m'] as double).round();
        _apparentTemperature =
            (data['current']['apparent_temperature'] as double).round();
        _weatherCode = data['current']['weather_code'];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load weather data: $e');
      }
    }
  }

  String getWeatherDescription(int weatherCode) {
    if (weatherCode == 0) {
      return "Clear sky";
    } else if (weatherCode == 1) {
      return "Mainly clear";
    } else if (weatherCode == 2) {
      return "Mainly clear";
    } else if (weatherCode == 3) {
      return "Mainly clear";
    } else if (weatherCode == 45) {
      return "Fog and depositing rime fog";
    } else if (weatherCode == 48) {
      return "Fog and depositing rime fog";
    } else if (weatherCode == 51 || weatherCode == 53 || weatherCode == 55) {
      return "Drizzle: Light, moderate, or dense intensity";
    } else if (weatherCode == 56 || weatherCode == 57) {
      return "Freezing Drizzle: Light or dense intensity";
    } else if (weatherCode == 61 || weatherCode == 63 || weatherCode == 65) {
      return "Rain: Slight, moderate, or heavy intensity";
    } else if (weatherCode == 66 || weatherCode == 67) {
      return "Freezing Rain: Light or heavy intensity";
    } else if (weatherCode == 71 || weatherCode == 73 || weatherCode == 75) {
      return "Snow fall: Slight, moderate, or heavy intensity";
    } else if (weatherCode == 77) {
      return "Snow grains";
    } else if (weatherCode == 80 || weatherCode == 81 || weatherCode == 82) {
      return "Rain showers: Slight, moderate, or violent";
    } else if (weatherCode == 85 || weatherCode == 86) {
      return "Snow showers: Slight or heavy";
    } else if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
      return "Thunderstorm: Slight or moderate";
    } else {
      return "Unknown weather code";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaFlore'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getWeather();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
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
            const ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushReplacement(
                  // Remplace la page actuelle
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.lightBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _temperature != null
                          ? _formatTemperature(_temperature!.toDouble())
                          : "",
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
                      'Feels like ${_formatTemperature(_apparentTemperature!.toDouble())}',
                      style:
                          const TextStyle(fontSize: 25, color: Colors.white70),
                    ),
                  ],
                ),
              if (_weatherCode != null)
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      getWeatherDescription(_weatherCode!),
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyWeather.length,
                  itemBuilder: (context, index) {
                    HourlyWeather weather = hourlyWeather[index];
                    // Utiliser _formatTemperature pour convertir la température
                    String formattedTemperature =
                        _formatTemperature(weather.temperature);

                    return Container(
                      width: 120,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(weather.time.substring(11, 16),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          Text(formattedTemperature,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text('${weather.precipitationProbability}%',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          Text(weather.weatherDescription,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
