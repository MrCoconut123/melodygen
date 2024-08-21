import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'display.dart';


class Generate extends StatefulWidget {
  @override
  _GenerateState createState() => _GenerateState();
}


class _GenerateState extends State<Generate> {
  final TextEditingController _promptController = TextEditingController();
  int? _selectedDuration = 15;
  String? _audioFile;
  String simulatedAudioUrl = "";
  bool isLoading = false;


  // Navigates to upload page
  void _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // ensures only audio files are picked
    );
    if (result != null) {
      setState(() {
        _audioFile = result.files.single.path;
      });
    }
  }


  // Navigates to audio player page
  void _generateContent() async {
    final prompt = _promptController.text; // retrieve prompt string
    if (_audioFile != null && prompt.isNotEmpty) {
      setState(() {
        isLoading = true; // Show loading indicator
      });


      await _backendRequest(prompt, _selectedDuration, _audioFile);


      setState(() {
        isLoading = false; // Hide loading indicator
      });


      // Navigate to the display page with the new generated audio
      if (simulatedAudioUrl.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayGeneratedAudio(audioUrl: simulatedAudioUrl),
          ),
        );
      }
    } else {
      print("Please input prompt and audio file");
    }
  }


  // Backend request
  Future<void> _backendRequest(String prompt, int? duration, String? audioFile) async {
    final url = Uri.parse('http://10.0.2.2:5000/generate_melody');


    try {
      var request = http.MultipartRequest('POST', url);
      // Adding prompt and duration as text fields
      request.fields['prompt'] = prompt;
      request.fields['duration'] = duration.toString();


      // Attach audio file
      if (audioFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'audio',
          audioFile,
          contentType: MediaType('audio', 'mpeg'),
        ));
      }


      // Send request to server
      final streamedResponse = await request.send();


      // Handle response from server
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        // Successful response handling
        final data = jsonDecode(response.body);
        simulatedAudioUrl = data['audio_url'];
        print('Generated audio URL: $simulatedAudioUrl'); // Assuming backend returns a JSON with `audio_url`
      } else {
        // Error handling
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Exception handling
      print('An error occurred: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.music_note),
            SizedBox(width: 10),
            Text("Melody Gen"),
          ],
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading indicator while the request is being processed
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Prompt Input Field
            TextFormField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Enter prompt',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20), // Spacing
            DropdownButtonFormField<int>(
              value: _selectedDuration,
              decoration: InputDecoration(
                labelText: 'Select Duration (seconds)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                DropdownMenuItem<int>(
                  value: 15,
                  child: Text('15'),
                ),
                DropdownMenuItem<int>(
                  value: 30,
                  child: Text('30'),
                ),
                DropdownMenuItem<int>(
                  value: 60,
                  child: Text('60'),
                ),
                DropdownMenuItem<int>(
                  value: 120,
                  child: Text('120'),
                ),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedDuration = newValue;
                });
              },
            ),
            SizedBox(height: 20), // Spacing
            ElevatedButton.icon(
              onPressed: _pickAudioFile,
              icon: Icon(Icons.upload_file),
              label: Text('Upload Audio File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20), // Spacing
            ElevatedButton(
              onPressed: _generateContent,
              child: Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}

