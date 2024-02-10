import 'package:flutter/material.dart';
import 'package:flutter_case/src/sample_feature/book_item_details_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'styles.dart';

class BookFavoriteListView extends StatefulWidget {
  const BookFavoriteListView({Key? key}) : super(key: key);
  static const routeName = '/';
  @override
  BookFavoriteListViewState createState() => BookFavoriteListViewState();
}

class BookFavoriteListViewState extends State<BookFavoriteListView> {
  final _list = <dynamic>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFavorites();
    });
  }

  void _navigateToDetails(BuildContext context, Map<String, dynamic> args) {
    Navigator.restorablePushNamed(
      context,
      BookItemDetailsView.routeName,
      arguments: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                dynamic data = _list[index];
                String id = data['id'];
                String smallThumbnail =
                    (data?['smallThumbnail'] as String?) ?? '';
                String title = (data?['title'] as String?) ?? '';
                String subTitle = (data?['subTitle'] as String?) ?? '';

                return ListTile(
                  leading: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(smallThumbnail),
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: MyStyles.titleStyle,
                    maxLines: 2,
                  ),
                  subtitle: Text(
                    subTitle,
                    style: MyStyles.subtitleStyle,
                  ),
                  onTap: () {
                    _navigateToDetails(
                      context,
                      {
                        'id': id,
                        'title': title,
                        'subTitle': subTitle,
                        'smallThumbnail': smallThumbnail,
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favorites = prefs.getString('favorites') ?? '[]';
    return jsonDecode(favorites);
  }

  Future<void> loadFavorites() async {
    List<dynamic> favorites = await getFavorites();
    setState(() {
      _list.clear();
      _list.addAll(favorites);
    });
  }
}
