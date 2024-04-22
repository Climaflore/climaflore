import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climaflore',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHome(title: 'Page d\'accueil'),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key, required this.title});

  final String title;

  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenue sur la page d\'accueil!',
            ),
          ],
        ),
      ),
    );
  }
}
