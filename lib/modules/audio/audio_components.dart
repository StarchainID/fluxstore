import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/audio.dart';
import '../../models/entities/blog.dart';

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  void start() async {
    _running = true;
    while (_running) {
      var newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration!) newPosition = mediaItem.duration!;
      await player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  void stop() {
    _running = false;
  }
}

class Sleeper {
  Completer? _blockingCompleter;

  /// Sleep for a duration. If sleep is interrupted, a
  /// [SleeperInterruptedException] will be thrown.
  Future<void> sleep([Duration? duration]) async {
    _blockingCompleter = Completer();
    if (duration != null) {
      await Future.any([Future.delayed(duration), _blockingCompleter!.future]);
    } else {
      await _blockingCompleter!.future;
    }
    final interrupted = _blockingCompleter!.isCompleted;
    _blockingCompleter = null;
    if (interrupted) {
      throw SleeperInterruptedException();
    }
  }

  /// Interrupt any sleep that's underway.
  void interrupt() {
    if (_blockingCompleter?.isCompleted == false) {
      _blockingCompleter!.complete();
    }
  }
}

/// Interrupt any sleep that's underway.

class SleeperInterruptedException {}

class QueueState {
  final List<MediaItem>? queue;
  final MediaItem? mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

Future<Duration?> getDuration(String url) async {
  var player = AudioPlayer();
  return await player.setUrl(url);
}

Future<void> handleMediaItem(Blog blog, BuildContext context) async {
  var audioUrls = blog.getAudioLinks();

  if (audioUrls != null) {
    try {
      var mediaList = <MediaItem>[];
      for (var item in audioUrls) {
        var duration = await getDuration(item!);
        var mediaItem = MediaItem(
          id: item,
          album: '',
          title: blog.title!,
          artUri: Uri.parse(blog.imageFeature!),
          duration: duration,
        );
        mediaList.add(mediaItem);
      }
      Provider.of<AudioModel>(context, listen: false)
          .addItemsToMediaList(itemList: mediaList);
    } catch (e) {
      printLog('[audio_components] Fail to load audio');
    }
  }
}

class AudioDialog extends StatelessWidget {
  final Blog blog;

  const AudioDialog(this.blog);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            height: 45.0,
            child: Text(
              S.of(context).audioDetected,
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: () async {
                  //Notify sticky audio widget status
                  Provider.of<AudioModel>(context, listen: false)
                      .onChangeStickyAudioStatus(true);
                  //Add item into Audio Player
                  await handleMediaItem(blog, context);
                  Navigator.of(context).pop();
                },
                child: Text(
                  S.of(context).yes,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              TextButton(
                onPressed: () {
                  //Notify sticky audio widget status
                  Provider.of<AudioModel>(context, listen: false)
                      .onChangeStickyAudioStatus(false);
                  AudioService.stop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  S.of(context).no,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
