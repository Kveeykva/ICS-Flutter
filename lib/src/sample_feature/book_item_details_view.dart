import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookItemDetailsView extends StatefulWidget {
  const BookItemDetailsView({Key? key}) : super(key: key);

  static const routeName = '/bookItemDetailsView';

  @override
  BookItemDetailsViewState createState() => BookItemDetailsViewState();
}

class BookItemDetailsViewState extends State<BookItemDetailsView> {
  bool isFavorite = false;
  String? id;
  String? title;
  dynamic _data;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      title = arguments['title'] as String? ?? '';
      id = arguments['id'] as String? ?? '';
      _data = {'thumbnail': arguments['smallThumbnail'] as String? ?? ''};
      _fetchData(id.toString());
      checkIfFavorite();
    });
  }

  @override
  Widget build(BuildContext context) {
    String description = _data?['description'] ?? '';
    String authors = _data?['authors'] ?? 'Anonim';
    String thumbnail = _data?['thumbnail'] ?? 'https://via.placeholder.com/150';

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(title.toString()),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  Container(
                    width: 50,
                    height: 50,
                    child: const CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                if (!isLoading)
                  Image.network(
                    thumbnail,
                    fit: BoxFit.contain,
                    width: deviceWidth * 0.5,
                    height: deviceHeight * 0.2,
                  ),
                if (!isLoading)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Favoriye al:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            toggleFavorite();
                          },
                        ),
                      ],
                    ),
                  ),
                if (!isLoading) const SizedBox(height: 10),
                if (!isLoading)
                  Text(
                    'Yazar: $authors',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!isLoading) const SizedBox(height: 10),
                if (!isLoading) Text(description),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchData(String id) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      String url = 'https://www.googleapis.com/books/v1/volumes/$id';

      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedData = json.decode(response.body);
        dynamic result = decodedData;
        setState(() {
          _data = {
            'id': result['id'],
            'title': result['volumeInfo']['title'],
            'subTitle': result['volumeInfo']['subTitle'],
            'description': removeHtmlTags(result['volumeInfo']['description']),
            'thumbnail': result['volumeInfo']['imageLinks']['thumbnail'],
            'smallThumbnail': result['volumeInfo']['imageLinks']
                ['smallThumbnail'],
            'authors': result['volumeInfo']['authors'].join(', '),
          };
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String removeHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  Future<List<dynamic>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favorites = prefs.getString('favorites') ?? '[]';
    return jsonDecode(favorites);
  }

  Future<dynamic> getFavoriteBook(String id) async {
    List<dynamic> favorites = await getFavorites();
    return favorites.firstWhere((book) => book['id'] == id, orElse: () => null);
  }

  Future<void> toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic favoriteBook = await getFavoriteBook(id.toString());
    List<dynamic> favoritesList = await getFavorites();
    if (favoriteBook != null) {
      favoritesList.removeWhere((book) => book['id'] == id);
      setState(() {
        isFavorite = false;
      });
    } else {
      dynamic newBook = {
        'id': id,
        'title': title,
        'thumbnail': _data['thumbnail'] ?? '',
        'smallThumbnail':
            _data['thumbnail'] ?? 'https://via.placeholder.com/150',
        'subTitle': _data['subTitle'] ?? ''
      };

      favoritesList.add(newBook);
      setState(() {
        isFavorite = true;
      });
    }

    await prefs.setString('favorites', jsonEncode(favoritesList));
  }

  Future<void> checkIfFavorite() async {
    bool favorite = await getFavoriteBook(id.toString()) != null;
    setState(() {
      isFavorite = favorite;
    });
  }
}
