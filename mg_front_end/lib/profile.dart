import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'display.dart';
import 'explore.dart';
import 'generate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> generatedMusic = {};
  Map<String, dynamic> favoritedMusic = {};
  int _selectedIndex = 2;

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
    _loadMusicData();
  }

  void _loadMusicData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String generated = prefs.getString('generatedMusic') ?? '{}';
    String favorites = prefs.getString('favoritedMusic') ?? '{}';

    setState(() {
      generatedMusic = jsonDecode(generated);
      favoritedMusic = jsonDecode(favorites);
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExplorePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Generate()),
        );
        break;
      case 2:
        break;
    }
  }

  void _refreshData() {
    _loadMusicData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile data refreshed')),
    );
  }

  void _addToFavorites(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = prefs.getString('favoritedMusic') ?? '{}';
    final Map<String, dynamic> favoritesMap = jsonDecode(currentFavorites);

    if (!favoritesMap.containsKey(key)) {
      favoritesMap[key] = generatedMusic[key];
      await prefs.setString('favoritedMusic', jsonEncode(favoritesMap));
      setState(() {
        favoritedMusic = favoritesMap;
      });
      Fluttertoast.showToast(
        msg: "Added to favorites!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void _removeFromFavorites(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = prefs.getString('favoritedMusic') ?? '{}';
    final Map<String, dynamic> favoritesMap = jsonDecode(currentFavorites);

    if (favoritesMap.containsKey(key)) {
      favoritesMap.remove(key);
      await prefs.setString('favoritedMusic', jsonEncode(favoritesMap));
      setState(() {
        favoritedMusic = favoritesMap;
      });
      Fluttertoast.showToast(
        msg: "Removed from favorites!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void _shareTrack(String url) {
    Share.share('Check out this track: $url');
    Fluttertoast.showToast(
      msg: "Track link shared!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color1,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Generated Tracks: ${generatedMusic.length}',
              style: TextStyle(
                fontSize: 18,
                color: color2,
              ),
            ),
            Text(
              'Favorited Tracks: ${favoritedMusic.length}',
              style: TextStyle(
                fontSize: 18,
                color: color2,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _viewSampleMusic,
              style: ElevatedButton.styleFrom(
                backgroundColor: color4,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('View Sample Music', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: color1,
                      unselectedLabelColor: color2,
                      indicatorColor: color3,
                      tabs: [
                        Tab(text: "My Music"),
                        Tab(text: "Favorites"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildMusicList(
                            generatedMusic,
                            "No generated music found",
                            _addToFavorites,
                            _removeFromGeneratedMusic,
                            _removeFromFavorites, // Added unfavorite functionality
                          ),
                          _buildMusicList(
                            favoritedMusic,
                            "No favorited music found",
                            null,
                            _removeFromFavorites,
                            _removeFromFavorites, // Added unfavorite functionality
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
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

  void _viewSampleMusic() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExplorePage(),
      ),
    );
  }

  void _removeFromGeneratedMusic(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final currentGenerated = prefs.getString('generatedMusic') ?? '{}';
    final Map<String, dynamic> generatedMap = jsonDecode(currentGenerated);

    if (generatedMap.containsKey(key)) {
      generatedMap.remove(key);
      await prefs.setString('generatedMusic', jsonEncode(generatedMap));
      setState(() {
        generatedMusic = generatedMap;
      });
      Fluttertoast.showToast(
        msg: "Removed from generated music!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildMusicList(
      Map<String, dynamic> musicMap,
      String emptyMessage,
      void Function(String)? onFavoritePressed,
      void Function(String)? onDeletePressed,
      void Function(String)? onUnfavoritePressed, // Added unfavorite callback
      ) {
    if (musicMap.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: color4,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: musicMap.length,
      itemBuilder: (context, index) {
        String date = musicMap.keys.elementAt(index);
        bool isFavorited = favoritedMusic.containsKey(date);

        return Dismissible(
          key: Key(date),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            if (onDeletePressed != null) {
              onDeletePressed(date);
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color5,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                date,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: color1,
                ),
              ),
              subtitle: Text(
                musicMap[date]['prompt'] ?? 'No prompt available',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: color3),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onFavoritePressed != null && !isFavorited)
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: color2,
                      ),
                      onPressed: () => onFavoritePressed(date),
                    ),
                  if (onUnfavoritePressed != null && isFavorited)
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: color2,
                      ),
                      onPressed: () => onUnfavoritePressed(date),
                    ),
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: color2),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayGeneratedAudio(
                            audioUrl: musicMap[date]['url'] ?? '',
                            prompt: musicMap[date]['prompt'],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: color2),
                    onPressed: () {
                      _shareTrack(musicMap[date]['url'] ?? '');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(color: color6),
    );
  }
}
