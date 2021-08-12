import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/utils/logs.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/tools/image_tools.dart';
import '../../models/audio.dart';
import '../../screens/base_screen.dart';
import 'audio_components.dart';
import 'audio_seek_bar.dart';
import 'audio_service.dart';

void _audioPlayerTaskEntrypoint() async {
  await AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioWidget extends StatefulWidget {
  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends BaseScreen<AudioWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Service',
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
    );
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioModel>(builder: (context, model, child) {
      try {
        AudioService.updateQueue(model.audioList);
      } catch (e) {
        printLog('[audio_player] Error on updateQueue');
      }
      return StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            // Don't show anything until we've ascertained whether or not the
            // service is running, since we want to show a different UI in
            // each case.
            return const SizedBox();
          }
          final running = snapshot.data ?? false;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!running) ...[
                //   // UI to show when we're not running, i.e. a menu.
                //   // audioPlayerButton(),
                const Text('Loading ...'),
              ] else ...[
                // UI to show when we're running, i.e. player state/controls.
                // Queue display/controls.
                StreamBuilder<QueueState>(
                  stream: _queueStateStream,
                  builder: (context, snapshot) {
                    final queueState = snapshot.data;
                    final queue = queueState?.queue ?? [];
                    final mediaItem = queueState?.mediaItem;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: ClipRect(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      if (mediaItem?.artUri != null)
                                        Container(
                                          child: ImageTools.image(
                                            url: mediaItem!.artUri.toString(),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      if (mediaItem?.title != null)
                                        Flexible(
                                          child: Text(
                                            mediaItem!.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 5,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (queue.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.skip_previous),
                                        iconSize: 20.0,
                                        onPressed: mediaItem == queue.first
                                            ? null
                                            : AudioService.skipToPrevious,
                                        padding: const EdgeInsets.all(10.0),
                                        constraints: const BoxConstraints(),
                                      ),
                                    // Play/pause/stop buttons.
                                    StreamBuilder<bool>(
                                      stream: AudioService.playbackStateStream
                                          .map((state) => state.playing)
                                          .distinct(),
                                      builder: (context, snapshot) {
                                        final playing = snapshot.data ?? false;
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (playing)
                                              pauseButton()
                                            else
                                              playButton(),
                                            // Hide this for now
                                            // Disposing widget containing AudioPlayer would call AudioPlayer.stop
                                            // stopButton(),
                                            replayButton(),
                                          ],
                                        );
                                      },
                                    ),
                                    if (queue.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.skip_next),
                                        iconSize: 20.0,
                                        onPressed: mediaItem == queue.last
                                            ? null
                                            : AudioService.skipToNext,
                                        padding: const EdgeInsets.all(10.0),
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
                                )),
                          ],
                        ),
                        /* Seek Bar */
                        StreamBuilder<MediaState>(
                          stream: _mediaStateStream,
                          builder: (context, snapshot) {
                            final mediaState = snapshot.data;
                            return SeekBar(
                              duration: mediaState?.mediaItem?.duration ??
                                  Duration.zero,
                              position: mediaState?.position ?? Duration.zero,
                              onChangeEnd: AudioService.seekTo,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          );
        },
      );
    });
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => MediaState(mediaItem, position));

  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>?, MediaItem?, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));

  RawMaterialButton startButton(VoidCallback onPressed) => RawMaterialButton(
        elevation: 2.0,
        fillColor: Theme.of(context).primaryColor,
        onPressed: onPressed,
        padding: const EdgeInsets.all(15.0),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.queue_music,
          size: 35.0,
        ),
      );

  IconButton playButton() => const IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 20.0,
        onPressed: AudioService.play,
        padding: EdgeInsets.all(10.0),
        constraints: BoxConstraints(),
      );

  IconButton pauseButton() => const IconButton(
        icon: Icon(Icons.pause),
        iconSize: 20.0,
        onPressed: AudioService.pause,
        padding: EdgeInsets.all(10.0),
        constraints: BoxConstraints(),
      );

  IconButton stopButton() => const IconButton(
        icon: Icon(Icons.stop),
        iconSize: 20.0,
        onPressed: AudioService.stop,
        padding: EdgeInsets.all(10.0),
        constraints: BoxConstraints(),
      );

  IconButton replayButton() => IconButton(
        icon: const Icon(Icons.replay),
        iconSize: 20.0,
        onPressed: () => AudioService.seekTo(Duration.zero),
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );
}
