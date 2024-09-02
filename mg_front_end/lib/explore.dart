import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mg_front_end/generate.dart';
import 'package:mg_front_end/profile.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening links

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Map<String, String>> genres = [
    {
      'name': 'Classical',
      'description': 'Classical music is known for its complex structures and compositions, typically involving orchestras and a variety of instruments.',
      'examples': jsonEncode([
        {'title': 'Beethoven Symphony', 'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/BeethovenSymphonyExample.mp3?alt=media&token=a0691312-ef60-4467-bc04-8544e8aea90b'},
        {'title': 'Mozart Piano Concerto', 'url': 'https://example.com/classical/mozart.mp3'}
      ]),
    },
    {
      'name': 'Jazz',
      'description': 'Jazz is characterized by swing and blue notes, call and response vocals, and improvisation.',
      'examples': jsonEncode([
        {'title': 'Miles Davis', 'url': 'https://example.com/jazz/miles.mp3'},
        {'title': 'John Coltrane', 'url': 'https://example.com/jazz/coltrane.mp3'}
      ]),
    },
    {
      'name': 'Rock',
      'description': 'Rock music features a strong rhythm and often revolves around the electric guitar, with energetic performances and catchy melodies.',
      'examples': jsonEncode([
        {'title': 'Led Zeppelin', 'url': 'https://example.com/rock/zeppelin.mp3'},
        {'title': 'Queen', 'url': 'https://example.com/rock/queen.mp3'}
      ]),
    },
  ];

  List<Map<String, String>> favoriteMusicList = [];

  final Color color1 = Color(0xFF7A9098);
  final Color color2 = Color(0xFF667A6B);
  final Color color3 = Color(0xFF5E6F6B);
  final Color color4 = Color(0xFF4F4E59);
  final Color color5 = Color(0xFF3E3D45);
  final Color color6 = Color(0xFF2F2E37);
  final Color color7 = Color(0xFF1F1E27);

  @override
  void initState() {
    super.initState();
  }

  void _toggleFavorite(Map<String, String> musicItem) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritedMusic = prefs.getString('favoritedMusic') ?? '{}';
    final Map<String, dynamic> favoritesMap = jsonDecode(favoritedMusic);

    final timestamp = DateTime.now().toIso8601String();
    if (favoritesMap.containsKey(timestamp)) {
      favoritesMap.remove(timestamp);
    } else {
      favoritesMap[timestamp] = musicItem;
    }

    await prefs.setString('favoritedMusic', jsonEncode(favoritesMap));
    setState(() {
      favoriteMusicList = favoritesMap.values.toList().cast<Map<String, String>>();
    });

    Fluttertoast.showToast(
      msg: favoritesMap.containsKey(timestamp) ? 'Music added to favorites' : 'Music removed from favorites',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color1,
      textColor: Colors.white,
    );
  }

  void _downloadMusic(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: 'Could not download the music',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: color4,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color7,
        title: Row(
          children: [
            Icon(Icons.music_note, color: Colors.white),
            SizedBox(width: 10),
            Text("Melody Gen", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color7, color6],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            final examples = jsonDecode(genre['examples']!) as List;

            return Card(
              color: color5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      genre['name']!,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color1),
                    ),
                    subtitle: Text(
                      genre['description']!,
                      style: TextStyle(fontSize: 16, color: color3),
                    ),
                  ),
                  ...examples.map((example) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(12.0),
                      title: Text(
                        example['title']!,
                        style: TextStyle(fontSize: 18, color: color1),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.download, color: color1),
                            onPressed: () {
                              _downloadMusic(example['url']!);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              favoriteMusicList.any((item) => item['url'] == example['url'])
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: color1,
                            ),
                            onPressed: () {
                              _toggleFavorite({
                                'title': example['title']!,
                                'url': example['url']!,
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
            // Already on ExplorePage
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Generate()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        backgroundColor: color7,
        selectedItemColor: color1,
        unselectedItemColor: color2,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Generate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
