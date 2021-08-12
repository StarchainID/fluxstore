import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:inspireui/utils/logs.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_components.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final AudioPlayer _player = AudioPlayer();
  AudioProcessingState? _skipState;
  Seeker? _seeker;
  late StreamSubscription<PlaybackEvent> _eventSubscription;

  var queue = <MediaItem>[];
  int? get index => _player.currentIndex;
  MediaItem? get mediaItem => index == null ? null : queue[index!];
  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    //Clear queue beforehand
    // queue.clear();

    // try {
    //   List mediaItems = params['data'];
    //   for (var item in mediaItems) {
    //     var mediaItem = MediaItem.fromJson(item);
    //     queue.add(mediaItem);
    //   }
    // } catch (e) {
    //   // ignore: empty_catches
    // }
    //
    // // Broadcast media item changes.
    // _player.currentIndexStream.listen((index) {
    //   if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
    // });
    // // Propagate all events from the audio player to AudioService clients.
    // _eventSubscription = _player.playbackEventStream.listen((event) {
    //   _broadcastState();
    // });
    // // Special processing for state transitions.
    // _player.processingStateStream.listen((state) {
    //   switch (state) {
    //     case ProcessingState.completed:
    //       // In this example, the service stops when reaching the end.
    //       onStop();
    //       break;
    //     case ProcessingState.ready:
    //       // If we just came from skipping between tracks, clear the skip
    //       // state now that we're ready to play.
    //       _skipState = null;
    //       break;
    //     default:
    //       break;
    //   }
    // });

    // Load and broadcast the queue
    // await AudioServiceBackground.setQueue(queue);
    // try {
    //   await _player.setAudioSource(ConcatenatingAudioSource(
    //     children:
    //         queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
    //   ));
    //Play right away after Start
    // onPlay();
    // } catch (e) {
    //   await onStop();
    // }
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> updatedQueue) async {
    // queue.clear();
    printLog('[audio_service] onUpdateQueue is triggered');
    queue.addAll(updatedQueue);

    // prinLogt('queue update with $queue');
    // await AudioServiceBackground.setQueue(queue);
    // try {
    //   await _player.setAudioSource(ConcatenatingAudioSource(
    //     children:
    //         queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
    //   ));
    // } catch (e) {
    //   print('Error: $e');
    //   await onStop();
    // }
    //Notify clients that queue has been changed.
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    // Load and broadcast the queue
    await AudioServiceBackground.setQueue(queue);
    try {
      await _player.setAudioSource(ConcatenatingAudioSource(
        children:
            queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ));
      return super.onUpdateQueue(queue);
    } catch (e) {
      printLog('[audio_service] Fail to load and broadcast the queue');
    }
    // Loop Audio List by default
    await AudioService.setRepeatMode(AudioServiceRepeatMode.all);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    _skipState = newIndex > index!
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _player.seek(Duration.zero, index: newIndex);
    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    await _player.stop();
    await _eventSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem!.duration!) newPosition = mediaItem!.duration!;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          const Duration(seconds: 1), mediaItem!)
        ..start();
    }
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState!;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception('Invalid state: ${_player.processingState}');
    }
  }
}
