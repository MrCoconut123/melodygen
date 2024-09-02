import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'generate.dart';
import 'explore.dart';
import 'profile.dart';

class DisplayGeneratedAudio extends StatefulWidget {
  final String audioUrl;
  final String prompt; // New prompt parameter

  DisplayGeneratedAudio({required this.audioUrl, required this.prompt}); // Update constructor

  @override
  _DisplayGeneratedAudioState createState() => _DisplayGeneratedAudioState();
}

class _DisplayGeneratedAudioState extends State<DisplayGeneratedAudio> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _selectedIndex = 1;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Colors based on the provided dark aesthetic palette
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
    _audioPlayer.setSourceUrl(widget.audioUrl);
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      try {
        await _audioPlayer.play(UrlSource(widget.audioUrl));
        setState(() {
          _isPlaying = true;
        });
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  Future<void> _downloadAudio() async {
    print('asking for permission');
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    print('permission granted');
    if (status.isGranted) {
      try {
        Directory? downloadsDirectory = Directory('/sdcard/Download');

        // Ensure the directory exists
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        // Use the prompt as the file name
        final sanitizedPrompt = widget.prompt.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'); // Sanitize the prompt for file name
        final filePath = '${downloadsDirectory.path}/$sanitizedPrompt.mp3';

        final response = await HttpClient().getUrl(Uri.parse(widget.audioUrl));
        final file = File(filePath);
        final httpResponse = await response.close();
        final fileSink = file.openWrite();
        await httpResponse.pipe(fileSink);
        await fileSink.close();

        print(file);
        Fluttertoast.showToast(
          msg: 'Music downloaded successfully as $sanitizedPrompt.mp3',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: color1,
          textColor: Colors.white,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error downloading music: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: color4,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Storage permission denied',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: color4,
        textColor: Colors.white,
      );
    }
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.music_note, color: Colors.white),
            SizedBox(width: 10),
            Text("Generated Audio", style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: color7,
      ),
      body: Container(
        color: color6,
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your generated audio is ready!",
                style: TextStyle(fontSize: 18, color: color1),
              ),
              SizedBox(height: 20),
              IconButton(
                iconSize: 64.0,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: color2,
                onPressed: _togglePlayPause,
              ),
              SizedBox(height: 20),
              Text(
                _isPlaying ? "Playing..." : "Paused",
                style: TextStyle(fontSize: 16, color: color3),
              ),
              SizedBox(height: 20),
              Slider(
                value: _position.inSeconds.toDouble(),
                min: 0.0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 14, color: color4),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _downloadAudio,
                child: Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color1,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50), // Full width button
                ),
              ),
            ],
          ),
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
}



