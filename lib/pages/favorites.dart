import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cities'),
      ),
      body: const FavoritesList(),
    );
  }
}

class FavoritesList extends StatefulWidget {
  const FavoritesList({super.key});

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  List<String> _favorites = [
    'Paris, France',
    'New York, USA',
  ]; // Liste fictive des favoris, à remplacer par une gestion réelle

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_favorites[index]),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _favorites.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }
}
