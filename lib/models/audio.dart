import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';

class AudioModel extends ChangeNotifier {
  List<MediaItem> audioList = [];
  bool isStickyAudioWidgetActive = false;

  void onChangeStickyAudioStatus(bool value) {
    isStickyAudioWidgetActive = value;
    notifyListeners();
  }

  void addItemToMediaList({required MediaItem item}) {
    audioList.add(item);
    notifyListeners();
  }

  void addItemsToMediaList({required List<MediaItem> itemList}) {
    audioList = List.from(audioList)..addAll(itemList);
    notifyListeners();
  }
}
