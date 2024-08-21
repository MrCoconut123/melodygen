import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class DisplayGeneratedAudio extends StatefulWidget {
  final String audioUrl;


  DisplayGeneratedAudio({required this.audioUrl});


  @override
  _DisplayGeneratedAudioState createState() => _DisplayGeneratedAudioState();
}


class _DisplayGeneratedAudioState extends State<DisplayGeneratedAudio> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;


  void _togglePlayPause() async {
    if (isPlaying) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      try {
        await audioPlayer.play(UrlSource(widget.audioUrl));
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generated Audio"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your generated audio is ready!",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            IconButton(
              iconSize: 64.0,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
            ),
          ],
        ),
      ),
    );
  }
}



