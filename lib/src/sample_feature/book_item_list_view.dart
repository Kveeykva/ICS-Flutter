import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'book_item.dart';
import 'book_item_details_view.dart';

class BookItemListView extends StatelessWidget {
  const BookItemListView({
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
        restorationId: 'bookItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              title: Text('BookItem ${item.id}'),
              leading: const CircleAvatar(
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
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
