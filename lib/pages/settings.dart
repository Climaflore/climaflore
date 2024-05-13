import 'package:flutter/material.dart';
import '../config.dart';

import '../pages/weather/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaFlore'),
        backgroundColor: Colors.blue,
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
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  // Remplace la page actuelle
                  context,
                  MaterialPageRoute(builder: (context) => const MainWeather()),
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature Unit',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            RadioListTile(
              title: const Text('Fahrenheit'),
              value: TemperatureUnit.fahrenheit,
              groupValue: Config.unit,
              onChanged: (TemperatureUnit? value) {
                setState(() {
                  Config.unit = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Celsius'),
              value: TemperatureUnit.celsius,
              groupValue: Config.unit,
              onChanged: (TemperatureUnit? value) {
                setState(() {
                  Config.unit = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
