import 'package:flutter/material.dart';
import './book_item_details_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'styles.dart';

class BookItemListView extends StatefulWidget {
  const BookItemListView({Key? key}) : super(key: key);
  static const routeName = '/';
  @override
  BookItemListViewState createState() => BookItemListViewState();
}

class BookItemListViewState extends State<BookItemListView> {
  final _scrollController = ScrollController();
  final _list = <dynamic>[];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    _scrollController.addListener(_loadMore);
    _fetchData(_currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(int pageKey) async {
    if (!mounted) return;
    int perPageItemCount = 10;
    int startIndex = pageKey * perPageItemCount;
    setState(() {
      _isLoading = true;
    });
    try {
      String url =
          'https://www.googleapis.com/books/v1/volumes?maxResults=$perPageItemCount&startIndex=$startIndex&orderBy=relevance&q=Tolkien';

      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedData = json.decode(response.body);
        List<dynamic> result = decodedData['items'] as List<dynamic>? ?? [];
        setState(() {
          if (result.length < perPageItemCount) {
            _hasMore = false;
          }
          _list.addAll(result);
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMore() {
    if (!_hasMore) {
      return;
    }
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _currentPage++;
      _fetchData(_currentPage);
    }
  }

  void _navigateToDetails(BuildContext context, Map<String, dynamic> args) {
    Navigator.restorablePushNamed(
      context,
      BookItemDetailsView.routeName,
      arguments: args,
    );
  }

  Future<void> _refreshList() async {
    _hasMore = true;
    _currentPage = 0;
    _list.clear();
    await _fetchData(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitap Listesi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _list.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _list.length) {
                    return _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container();
                  }
                  dynamic volumeInfo = _list[index]['volumeInfo'];
                  String id = _list[index]['id'];
                  String description =
                      (_list[index]['volumeInfo']?['description'] as String?) ??
                          '';
                  String authors =
                      volumeInfo['authors']?.join(', ') ?? 'Unknown Author';

                  return ListTile(
                    leading: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            volumeInfo['imageLinks']?['smallThumbnail'] ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      volumeInfo['title'] ?? '',
                      style: MyStyles.titleStyle,
                      maxLines: 2,
                    ),
                    subtitle: Text(
                      volumeInfo['subtitle'] ?? '',
                      style: MyStyles.subtitleStyle,
                    ),
                    onTap: () {
                      _navigateToDetails(
                        context,
                        {
                          'id': id,
                          'title': volumeInfo['title'],
                          'description': description,
                          'index': index,
                          'authors': authors,
                          'thumbnail': volumeInfo['imageLinks']?['thumbnail'] ??
                              'https://via.placeholder.com/150',
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
