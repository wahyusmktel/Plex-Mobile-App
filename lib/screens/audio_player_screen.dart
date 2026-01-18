import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String? coverUrl;
  final String? author;

  const AudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.title,
    this.coverUrl,
    this.author,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      if (mounted) {
        _player.play();
      }
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cover Art
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.coverUrl != null
                          ? Image.network(widget.coverUrl!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.deepPurple,
                              child: const Icon(
                                Icons.headphones_rounded,
                                size: 100,
                                color: Colors.white24,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Titles
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.author ?? 'Unknown Author',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Progress Bar
                StreamBuilder<Duration?>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return ProgressBar(
                      progress: position,
                      total: _player.duration ?? Duration.zero,
                      buffered: _player.bufferedPosition,
                      onSeek: (duration) {
                        _player.seek(duration);
                      },
                      barHeight: 4,
                      baseBarColor: Colors.white24,
                      progressBarColor: Colors.white,
                      bufferedBarColor: Colors.white12,
                      thumbColor: Colors.white,
                      timeLabelTextStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.repeat_rounded),
                      color: Colors.white70,
                      onPressed: () {},
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: Colors.white,
                      onPressed: () {},
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 64.0,
                            height: 64.0,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else if (playing != true) {
                          return IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded),
                            iconSize: 80.0,
                            color: Colors.white,
                            onPressed: _player.play,
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return IconButton(
                            icon: const Icon(Icons.pause_circle_filled_rounded),
                            iconSize: 80.0,
                            color: Colors.white,
                            onPressed: _player.pause,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(
                              Icons.replay_circle_filled_rounded,
                            ),
                            iconSize: 80.0,
                            color: Colors.white,
                            onPressed: () => _player.seek(Duration.zero),
                          );
                        }
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_next_rounded),
                      color: Colors.white,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle_rounded),
                      color: Colors.white70,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
