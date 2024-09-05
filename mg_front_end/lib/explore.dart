import 'package:flutter/material.dart';
import 'package:mg_front_end/generate.dart';
import 'package:mg_front_end/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:mg_front_end/display.dart';

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
        {
          'title': 'Beethoven Symphony',
          'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/BeethovenSymphonyExample.mp3?alt=media&token=a0691312-ef60-4467-bc04-8544e8aea90b'
        },
        {
          'title': 'Mozart Piano Concerto',
          'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/MozartPianoConcerto.mp3?alt=media&token=99bb862d-093e-42a9-af4c-c8a58c40703c'
        }
      ]),
    },
    {
      'name': 'Jazz',
      'description': 'Jazz is characterized by swing and blue notes, call and response vocals, and improvisation.',
      'examples': jsonEncode([
        {
          'title': 'Miles Davis',
          'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/MilesDavis.mp3?alt=media&token=89aff186-8df6-4751-9bc2-d5c1e8f991f2'
        },
        {
          'title': 'John Coltrane',
          'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/JohnColtrane.mp3?alt=media&token=4676ef41-a606-4e4c-92a9-024d4a685ae0'
        }
      ]),
    },
    {
      'name': 'Rock',
      'description': 'Rock music features a strong rhythm and often revolves around the electric guitar, with energetic performances and catchy melodies.',
      'examples': jsonEncode([
        {
          'title': 'Led Zeppelin',
          'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/LedZeppelin.mp3?alt=media&token=6b12f6a0-845f-4cd4-9527-b422c81b8ffa'
        },
        {
          'title': 'Queen',
          'url': 'https://firebasestorage.googleapis.com/v0/b/melody-gen-f7d60.appspot.com/o/Queen.mp3?alt=media&token=9d3d22b5-48f2-410f-9621-fe6a34b41ed9'
        }
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
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritedMusic = prefs.getString('favoritedMusic') ?? '{}';
    final Map<String, dynamic> favoritesMap = jsonDecode(favoritedMusic);

    setState(() {
      favoriteMusicList = favoritesMap.values.map((item) {
        return Map<String, String>.from(item as Map); // Convert each item to Map<String, String>
      }).toList();
    });
  }

  void _toggleFavorite(Map<String, String> musicItem, String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritedMusic = prefs.getString('favoritedMusic') ?? '{}';
    final Map<String, dynamic> favoritesMap = jsonDecode(favoritedMusic);

    final timestamp = DateTime.now().toIso8601String();

    if (favoritesMap.values.any((item) => item['url'] == musicItem['url'])) {
      favoritesMap.removeWhere((key, value) => value['url'] == musicItem['url']);
    } else {
      // Add the music item to the favorites along with the prompt
      favoritesMap[timestamp] = {...musicItem, 'prompt': prompt};
    }

    await prefs.setString('favoritedMusic', jsonEncode(favoritesMap));

    setState(() {
      favoriteMusicList = favoritesMap.values.map((item) {
        return Map<String, String>.from(item as Map);
      }).toList();
    });

    Fluttertoast.showToast(
      msg: favoritesMap.values.any((item) => item['url'] == musicItem['url'])
          ? 'Music added to favorites'
          : 'Music removed from favorites',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color1,
      textColor: Colors.white,
    );
  }

  void _playMusic(String url, String prompt) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayGeneratedAudio(audioUrl: url, prompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: color7,
        title: Row(
          children: [
            Icon(Icons.music_note, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Melody Gen",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            final examples = jsonDecode(genre['examples']!) as List<dynamic>;

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
                    final exampleMap = Map<String, String>.from(example as Map);
                    return ListTile(
                      contentPadding: EdgeInsets.all(12.0),
                      title: Text(
                        exampleMap['title']!,
                        style: TextStyle(fontSize: 18, color: color1),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: color1),
                            onPressed: () {
                              // Play music and pass the genre name as the prompt
                              _playMusic(exampleMap['url']!, genre['name']!);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              favoriteMusicList.any((item) => item['url'] == exampleMap['url'])
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: color1,
                            ),
                            onPressed: () {
                              // Toggle favorite and pass the genre name as the prompt
                              _toggleFavorite(exampleMap, genre['name']!);
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


