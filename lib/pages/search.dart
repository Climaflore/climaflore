import 'package:flutter/material.dart';

class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  City({required this.name, required this.country, required this.latitude, required this.longitude});
}

List<City> cities = [
  City(name: 'Bangkok', country: 'Thailand', latitude: 13.7563, longitude: 100.5018),
  City(name: 'Beijing', country: 'China', latitude: 39.9042, longitude: 116.4074),
  City(name: 'Berlin', country: 'Germany', latitude: 52.5200, longitude: 13.4050),
  City(name: 'Buenos Aires', country: 'Argentina', latitude: -34.6037, longitude: -58.3816),
  City(name: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357),
  City(name: 'Cape Town', country: 'South Africa', latitude: -33.9249, longitude: 18.4241),
  City(name: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456),
  City(name: 'Lagos', country: 'Nigeria', latitude: 6.5244, longitude: 3.3792),
  City(name: 'London', country: 'UK', latitude: 51.5074, longitude: -0.1278),
  City(name: 'Madrid', country: 'Spain', latitude: 40.4168, longitude: -3.7038),
  City(name: 'Mexico City', country: 'Mexico', latitude: 19.4326, longitude: -99.1332),
  City(name: 'Moscow', country: 'Russia', latitude: 55.7512, longitude: 37.6184),
  City(name: 'Mumbai', country: 'India', latitude: 19.0760, longitude: 72.8777),
  City(name: 'Nairobi', country: 'Kenya', latitude: -1.2864, longitude: 36.8172),
  City(name: 'New York', country: 'USA', latitude: 40.7128, longitude: -74.0060),
  City(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
  City(name: 'Rio de Janeiro', country: 'Brazil', latitude: -22.9068, longitude: -43.1729),
  City(name: 'Rome', country: 'Italy', latitude: 41.9028, longitude: 12.4964),
  City(name: 'Seoul', country: 'South Korea', latitude: 37.5665, longitude: 126.9780),
  City(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093),
  City(name: 'Tokyo', country: 'Japan', latitude: 35.6895, longitude: 139.6917),
  City(name: 'Toronto', country: 'Canada', latitude: 43.6511, longitude: -79.3470),
  // Ajoutez plus de villes ici
];

class CityTile extends StatelessWidget {
  final City city;

  const CityTile({required this.city});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.location_city),
        title: Text('${city.name}, ${city.country}'),
        subtitle: Text('(${city.latitude}°N, ${city.longitude}°E)'),
        trailing: IconButton(
          icon: const Icon(Icons.star_border),
          onPressed: () {
            // Ajouter aux favoris
          },
        ),
        onTap: () {
          // Afficher la météo de la ville sélectionnée
        },
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: const SearchForm(),
    );
  }
}

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final TextEditingController _controller = TextEditingController();
  List<City> _searchResults = cities;

  void _searchCity(String query) {
    final results = cities.where((city) => city.name.toLowerCase().contains(query.toLowerCase())).toList();
    print('Search query: $query');
    print('Results found: ${results.length}');
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter city name',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchCity(_controller.text),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return CityTile(city: _searchResults[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
      home: const SearchPage(),
    );
  }
}
