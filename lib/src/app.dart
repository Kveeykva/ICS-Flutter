// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_case/src/sample_feature/book_favorite_list.dart';
import 'package:flutter_case/src/sample_feature/book_item_details_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/book_item_list_view.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const BookItemListView(),
    const BookFavoriteListView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: widget.settingsController.themeMode,
      onGenerateRoute: (settings) {
        if (settings.name == BookItemDetailsView.routeName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => const BookItemDetailsView(),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const BookItemListView(),
        );
      },
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Kitaplar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorilerim',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
