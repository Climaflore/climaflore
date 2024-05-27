import 'package:climaflore/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../settings.dart';
import 'package:geocoding/geocoding.dart';
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
  double? _latitude;
  double? _longitude;
  String? _city;

  String _formatTemperature(double temperature) {
    switch (Config.unit) {
      case TemperatureUnit.fahrenheit:
        return '${(temperature * 9 / 5 + 32).round()}°F';
      case TemperatureUnit.celsius:
      default:
        return '${temperature.round()}°C';
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    await _getCityFromCoordinates();
    await _getWeather();
  }

  Future<void> _getCityFromCoordinates() async {
    if (_latitude == null || _longitude == null) return;

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(_latitude!, _longitude!);
      Placemark place = placemarks[0];
      setState(() {
        _city = place.locality ?? place.administrativeArea ?? place.country;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get city name: $e');
      }
    }
  }

  Future<void> _getWeather() async {
    if (_latitude == null || _longitude == null) return;

    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$_latitude&longitude=$_longitude&current=temperature_2m,apparent_temperature,weather_code&hourly=temperature_2m,precipitation_probability,weather_code&timezone=auto';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);
      List<HourlyWeather> loadedHourlyWeather = [];

      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(now);

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
              _determinePosition();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Navigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
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
              if (_weatherCode != null)
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      getWeatherDescription(_weatherCode!),
                      style: const TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ],
                ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    _city != null ? _city! : 'Current Location',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
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
                          const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyWeather.length,
                  itemBuilder: (context, index) {
                    HourlyWeather weather = hourlyWeather[index];
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
