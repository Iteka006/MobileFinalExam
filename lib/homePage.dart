import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; // Import Awesome Notifications


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkNewQuizNotification();
  }

  Future<void> _checkNewQuizNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newQuizName = prefs.getString('newQuizName');
    if (newQuizName != null) {
      // Show the new quiz notification to the user
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 11,
          channelKey: 'basic_channel',
          title: 'New Quiz Available!',
          body: 'Check out the new quiz: $newQuizName',
        ),
      );
      // Clear the stored new quiz name
      await prefs.remove('newQuizName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildFeaturedContent(),
          SizedBox(height: 16.0),
          _buildRecentPosts(),
          SizedBox(height: 16.0),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFeaturedContent() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.network(
              'https://images.unsplash.com/photo-1533450718592-29d45635f0a9?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8anBnfGVufDB8fDB8fHww',
              height: 200.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover the Beauty of Nature',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Explore breathtaking landscapes and connect with nature.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recent Posts',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        _buildPostItem(
          'Awesome Sunset',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Anatomy_of_a_Sunset-2.jpg/800px-Anatomy_of_a_Sunset-2.jpg',
        ),
        _buildPostItem(
          'Mountain Adventure',
          'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8MTh8fHxlbnwwfHx8fHw%3D',
        ),
        _buildPostItem(
          'Serene Beach',
          'https://a.cdn-hotels.com/gdcs/production49/d1115/384d7c82-7494-45d7-8eb8-b2d46be78a33.jpg?impolicy=fcrop&w=800&h=533&q=medium',
        ),
      ],
    );
  }

  Widget _buildPostItem(String title, String imageUrl) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.network(
              imageUrl,
              height: 150.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'Copyright © 2024 Iteka Inc.',
          style: TextStyle(
            fontSize: 16.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
