import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'display.dart';
import 'explore.dart';
import 'profile.dart';

class Generate extends StatefulWidget {
  @override
  _GenerateState createState() => _GenerateState();
}

class _GenerateState extends State<Generate> {
  final TextEditingController _promptController = TextEditingController();
  int? _selectedDuration = 15;
  String? _audioFile;
  String? _audioFileName; // New variable for storing the file name
  String simulatedAudioUrl = "";
  bool isLoading = false;
  int _selectedIndex = 1; // Default index for the Generate button

  double _currentPosition = 0.0; // For the slider
  Duration _audioDuration = Duration.zero;

  final Color color1 = Color(0xFF7A9098);
  final Color color2 = Color(0xFF667A6B);
  final Color color3 = Color(0xFF5E6F6B);
  final Color color4 = Color(0xFF4F4E59);
  final Color color5 = Color(0xFF3E3D45);
  final Color color6 = Color(0xFF2F2E37);
  final Color color7 = Color(0xFF1F1E27);

  void _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        _audioFile = result.files.single.path;
        _audioFileName = result.files.single.name; // Store the file name
      });
    }
  }

  void _generateContent() async {
    final prompt = _promptController.text;
    if (_audioFile != null && prompt.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await _backendRequest(prompt, _selectedDuration, _audioFile);

      setState(() {
        isLoading = false;
      });

      if (simulatedAudioUrl.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayGeneratedAudio(audioUrl: simulatedAudioUrl, prompt: prompt),
          ),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please input prompt and select an audio file',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: color4,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _backendRequest(String prompt, int? duration, String? audioFile) async {
    final url = Uri.parse('http://10.0.2.2:5000/generate_melody');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['prompt'] = prompt;
      request.fields['duration'] = duration.toString();

      if (audioFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'audio',
          audioFile,
          contentType: MediaType('audio', 'mpeg'),
        ));
      }

      print('Starting Generation Process');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Received Response: ${response.body}');

        // Directly use the response body as the audio URL
        simulatedAudioUrl = response.body;

        // Simulate audio duration
        _audioDuration = Duration(seconds: duration ?? 0);

        // Save generated audio to shared preferences
        await _saveGeneratedAudio(prompt, simulatedAudioUrl);
        print('Saved Audio');

        Fluttertoast.showToast(
          msg: 'Music generated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: color1,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Error: ${response.reasonPhrase}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: color4,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: color4,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _saveGeneratedAudio(String prompt, String audioUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final generatedMusic = prefs.getString('generatedMusic') ?? '{}';
    final Map<String, dynamic> generatedMap = jsonDecode(generatedMusic);

    final timestamp = DateTime.now().toIso8601String();
    generatedMap[timestamp] = {
      'prompt': prompt,
      'url': audioUrl,
    };

    await prefs.setString('generatedMusic', jsonEncode(generatedMap));
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
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  void _clearFields() {
    setState(() {
      _promptController.clear();
      _audioFile = null;
      _audioFileName = null; // Clear the file name
      _currentPosition = 0.0;
      _audioDuration = Duration.zero;
    });
  }

  void _saveToFavorites() async {
    if (simulatedAudioUrl.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final favoritedMusic = prefs.getString('favoritedMusic') ?? '{}';
      final Map<String, dynamic> favoritesMap = jsonDecode(favoritedMusic);

      final timestamp = DateTime.now().toIso8601String();
      favoritesMap[timestamp] = {
        'prompt': _promptController.text,
        'url': simulatedAudioUrl,
      };

      await prefs.setString('favoritedMusic', jsonEncode(favoritesMap));

      Fluttertoast.showToast(
        msg: 'Music saved to favorites',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: color1,
        textColor: Colors.white,
      );
    }
  }

  void _downloadMusic() async {
    // Implement the download functionality
    Fluttertoast.showToast(
      msg: 'Downloading music...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color1,
      textColor: Colors.white,
    );
  }

  void _shareMusic() async {
    // Implement the share functionality
    Fluttertoast.showToast(
      msg: 'Sharing music...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color1,
      textColor: Colors.white,
    );
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentPosition = value;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _promptController,
                style: TextStyle(color: color1), // Set text color to match the color scheme
                decoration: InputDecoration(
                  labelText: 'Enter prompt',
                  labelStyle: TextStyle(color: color2), // Set label color to match the color scheme
                  border: OutlineInputBorder(),
                  filled: false, // Make the field background transparent
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedDuration,
                decoration: InputDecoration(
                  labelText: 'Select Duration (seconds)',
                  labelStyle: TextStyle(color: color2), // Set label color to match the color scheme
                  border: OutlineInputBorder(),
                  filled: false, // Make the field background transparent
                ),
                items: [15, 30, 45, 60].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value', style: TextStyle(color: color1)), // Set text color to match the color scheme
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedDuration = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickAudioFile,
                icon: Icon(Icons.attach_file),
                label: Text('Select Audio File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color5,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_audioFileName != null) // Display the file name if selected
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Selected File: $_audioFileName',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateContent,
                icon: Icon(Icons.audiotrack),
                label: Text('Generate Music'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color3,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Visibility(
                visible: simulatedAudioUrl.isNotEmpty,
                child: Column(
                  children: [
                    Text(
                      'Generated Music',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Slider(
                      value: _currentPosition,
                      min: 0.0,
                      max: _audioDuration.inSeconds.toDouble(),
                      onChanged: _onSliderChanged,
                      activeColor: color2,
                      inactiveColor: color1,
                    ),
                    Text(
                      _formatDuration(
                          Duration(seconds: _currentPosition.toInt())),
                      style: TextStyle(color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveToFavorites,
                          icon: Icon(Icons.favorite),
                          label: Text('Favorite'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color4,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _downloadMusic,
                          icon: Icon(Icons.download),
                          label: Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color3,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _shareMusic,
                          icon: Icon(Icons.share),
                          label: Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color2,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
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
        selectedItemColor: Colors.white,
        unselectedItemColor: color4,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
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
