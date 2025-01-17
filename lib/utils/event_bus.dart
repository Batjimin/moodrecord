import 'dart:async';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _colorUpdateController = StreamController<void>.broadcast();
  Stream<void> get onColorUpdate => _colorUpdateController.stream;

  final _galleryUpdateController = StreamController<void>.broadcast();
  Stream<void> get onGalleryUpdate => _galleryUpdateController.stream;

  void notifyColorUpdate() {
    _colorUpdateController.add(null);
  }

  void notifyGalleryUpdate() {
    _galleryUpdateController.add(null);
  }

  void dispose() {
    _colorUpdateController.close();
    _galleryUpdateController.close();
  }
}
