import 'package:climaflore/pages/weather/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ClimaFlore',
      home: InfoScreen(),
    );
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Bienvenue sur ClimaFlore !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Center(
              child: Text(
                'ClimaFlore est une application météorologique qui fusionne environnement avec nature.\n\nElle réunit la météo climatique d’une localisation précise, et vous proposera dans les mises à jour à venir, une météo botanique ainsi qu’une météo de voyage.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    // Remplace la page actuelle
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeatherHome(
                              title: '',
                            )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'C\'est parti !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
