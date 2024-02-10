import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'book_item.dart';
import 'book_item_details_view.dart';

/// Displays a list of BookFavorites.
class BookFavoriteListView extends StatelessWidget {
  const BookFavoriteListView({
    super.key,
    this.items = const [BookItem(1), BookItem(2), BookItem(3)],
  });

  static const routeName = '/';

  final List<BookItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        restorationId: 'bookFavoriteListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              title: Text('BookFavorite ${item.id}'),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                  context,
                  BookItemDetailsView.routeName,
                );
              });
        },
      ),
    );
  }
}
