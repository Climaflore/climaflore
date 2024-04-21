import 'package:climaflore/components/progresscircle.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2385BC), // Couleur de haut : bleu clair
              Color(0xFF07577B) // Couleur de bas : bleu foncé
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20), // Espacement
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              ), // Affiche l'image du logo
              Image.asset('assets/nom.png'), // Affiche l'image du nom
              const SizedBox(height: 20), // Espacement
              const ProgressCircle() // Affiche le cercle de progression
            ],
          ),
        ),
      ),
    );
  }
}
