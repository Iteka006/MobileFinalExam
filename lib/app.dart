import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'residential_location_screen.dart';
import 'drawer.dart';
import 'homePage.dart';

class ThemePreference {
  static const String key = "theme";

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> setTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, isDark);
  }
}





class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ThemePreference().getTheme(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Apply the selected theme
          isDarkMode = snapshot.data ?? false;

          return MaterialApp(
            theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: Scaffold(
              appBar: AppBar(
                title: Text(''),
              ),
              drawer: MyDrawer(onItemTap: (index) {
  setState(() {
    _selectedIndex = index;
  });
  Navigator.popUntil(context, (route) => route.isFirst);
}),

              body: _getBody(),
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    backgroundColor: Colors.grey[200],
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.location_on),
                    label: 'My Location',
                  ),

                ],
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _toggleTheme();
                },
                tooltip: 'Toggle Theme',
                child: Icon(Icons.brightness_6),
              ),
            ),
          );
        } else {
          // Show loading indicator or return a default theme
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return ResidentialLocationScreen();
   

      default:
        return Container();
    }
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentThemeIndex = prefs.getInt(ThemePreference.key) ?? 0;
    int nextThemeIndex = (currentThemeIndex + 1) % 3; // Assuming you have 3 themes

    prefs.setInt(ThemePreference.key, nextThemeIndex);

    setState(() {
      // Rebuild the widget tree to reflect the theme change
    });
  }
}

