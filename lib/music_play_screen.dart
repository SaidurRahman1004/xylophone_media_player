import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class MusicPlayScreen extends StatefulWidget {
  const MusicPlayScreen({super.key});

  @override
  State<MusicPlayScreen> createState() => _MusicPlayScreenState();
}

class _MusicPlayScreenState extends State<MusicPlayScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<SongModel> _playlist = [
    SongModel(
        songName: 'SoundHelix Song 1',
        artistName: 'T. Schürger',
        songUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationSecond: 255
    ),
    SongModel(
        songName: 'SoundHelix Song 2',
        artistName: 'T. Schürger',
        songUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationSecond: 255
    ),
    SongModel(
        songName: 'SoundHelix Song 3',
        artistName: 'T. Schürger',
        songUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationSecond: 255
    ),
  ]; // List of songs in the playlist
  int _currentIndex = 0; // Index of the currently playing song
  bool _isPlaying = false; // Playback state
  Duration _duration = Duration.zero; // Total duration of the song
  Duration _position = Duration.zero; // Current position of the song

  // Listen to audio player state changes
  void listenToPlayerState() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });


    _audioPlayer.onPlayerComplete.listen((_) {
      _next(); // Automatically play next song on completion
    });
  }

  // Play a song from the playlist by index
  Future<void> _playSong(int index) async {
    _currentIndex = index; // Update current index
    final song = _playlist[index]; // Get the song to play

    setState(() {
      _position = Duration.zero; // Reset position
      _duration = Duration(
        seconds: song.durationSecond,
      ); // Set duration of the song to UI
    });
    await _audioPlayer.stop(); // Stop any currently playing song
    await _audioPlayer.play(UrlSource(_playlist[index].songUrl));
  }

  // Play next song in the playlist
  Future<void> _next() async {
    final int next =
        (_currentIndex + 1) % _playlist.length; // Calculate next index
    await _playSong(next); // Play next song
  }

  // Play previous song in the playlist
  Future<void> _previous() async {
    final int previous =
        (_currentIndex - 1 + _playlist.length) %
        _playlist.length; // Calculate next index
    await _playSong(previous); // Play next song
  }

  //play pause toggle
  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  // Format duration to mm:ss string for display
  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes; // Get total minutes
    final int seconds = duration.inSeconds.remainder(
      60,
    ); // Get remaining seconds
    return "$minutes:${seconds.toString().padLeft(2, "0")}"; // Format as mm:ss string and padLeft for single digit seconds
  }

  @override
  void initState() {
    listenToPlayerState();
    _playSong(_currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SongModel song =
        _playlist[_currentIndex]; // Get the currently playing song
    final double maxSeconds = max(
      _duration.inSeconds.toDouble(),
      1,
    ); // Avoid division by zero
    final double currentSecond = _position.inSeconds.toDouble().clamp(
      0,
      maxSeconds,
    ); // Clamp current seconds to valid range and Use Clamp for safety
    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  Text(
                    song.songName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    song.artistName,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Slider(
                    min: 0,
                    max: maxSeconds,
                    value: currentSecond,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(
                        position,
                      ); // Seek to the new position And Use seek for seeking
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _previous,
                        icon: Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      ),

                      IconButton(onPressed: _next, icon: Icon(Icons.skip_next)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _playlist.length,
                itemBuilder: (_, index) {
                  final SongModel song = _playlist[index];
                  final bool isCurrent = index == _currentIndex;
                  return ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Text(song.songName),
                    subtitle: Text(song.artistName),
                    trailing: Icon(
                      isCurrent && _isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onTap: () {
                      _playSong(index);
                    },
                    selected: isCurrent,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

