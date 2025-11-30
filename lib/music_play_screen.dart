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
  final List<Song> _playlist = [
    Song(
      title: 'SoundHelix Song 1',
      artist: 'T. Schürger',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      durationSecond: 255,
    ),
    Song(
      title: 'SoundHelix Song 2',
      artist: 'T. Schürger',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      durationSecond: 255,
    ),
    Song(
      title: 'SoundHelix Song 3',
      artist: 'T. Schürger',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      durationSecond: 255,
    ),
  ]; // List of songs in the playlist
  int _currentIndex = 0; // Index of the currently playing song
  bool _isPlaying = false; // Playback state ,play/pause
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
    await _audioPlayer.play(UrlSource(song.url));
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
      if (_position >= _duration && _duration > Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary
              ? colorScheme.primary
              : colorScheme.primary.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : colorScheme.primary,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Song song =
        _playlist[_currentIndex]; // Get the currently playing song
    final double maxSeconds = _duration.inSeconds > 0
        ? _duration.inSeconds.toDouble()
        : 1;
    final double currentSecond = _position.inSeconds.toDouble().clamp(
      0,
      maxSeconds,
    ); // Clamp current seconds to valid range and Use Clamp for safety
    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff5f7ff), Color(0xfffdfbff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: const Text('Now Playing'),
                          avatar: const Icon(Icons.music_note),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        song.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.skip_previous_rounded,
                            onTap: _previous,
                          ),
                          const SizedBox(width: 16),

                          _buildControlButton(
                            icon: _isPlaying
                                ? Icons.padding_rounded
                                : Icons.play_arrow_rounded,
                            onTap: _togglePlayPause,
                            isPrimary: true,
                          ),
                          const SizedBox(width: 16),

                          _buildControlButton(
                            icon: Icons.skip_next_rounded,
                            onTap: _next,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: _playlist.length,
                    itemBuilder: (_, index) {
                      final Song song = _playlist[index];
                      final bool isCurrent = index == _currentIndex;
                      return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(song.artist),
                        trailing: Icon(
                          isCurrent && _isPlaying
                              ? Icons.equalizer_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        selected: isCurrent,
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        onTap: () {
                          if(isCurrent){
                            _togglePlayPause();
                          }else{
                            _playSong(index);
                          }
                        },

                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
