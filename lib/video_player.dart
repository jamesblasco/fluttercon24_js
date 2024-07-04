import 'dart:js_interop';
import 'package:web/web.dart' hide Text;
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  Plyr? plyr;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'custom-video-player',
      onElementCreated: (element) async {
        final child = HTMLVideoElement()
          ..controls = true
          ..id = 'player'
          ..append(HTMLSourceElement()
            ..src = 'videos/demo.mp4'
            ..type = "video/mp4");

        (element as HTMLElement).append(child);
        plyr = Plyr.fromElement(
          child,
          PlyrOptions(
            title: 'View From A Blue Moon',
            previewThumbnails: PreviewThumbnailsOptions(
              enabled: true,
              captions: CaptionsOptions(
                active: true,
              ),
              src: [
                'https://cdn.plyr.io/static/demo/thumbs/100p.vtt',
                'https://cdn.plyr.io/static/demo/thumbs/240p.vtt'
              ],
            ),
          ),
        );
        widget.controller._plyr = plyr;
        plyr?.onReady(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Ready')));
        });

        plyr?.onPause(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Paused')));
          widget.controller._updateIsPlaying(false);
        });

        plyr?.onPlay(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Playing')));
          widget.controller._updateIsPlaying(true);
        });
      },
    );
  }
}

extension type Plyr._(JSObject _) implements JSObject {
  @JS('')
  external Plyr.fromElement(
    HTMLElement element, [
    PlyrOptions? options,
  ]);

  @JS('')
  external Plyr.fromSelector(String element);

  external void play();

  external void pause();

  @JS('on')
  external void _jsOn(String event, JSExportedDartFunction callback);

  void _on(String event, VoidCallback callback) =>
      _jsOn(event, ((JSAny? event) => callback()).toJS);

  void onReady(VoidCallback callback) => _on('ready', callback);
  void onPlay(VoidCallback callback) => _on('play', callback);
  void onPause(VoidCallback callback) => _on('pause', callback);
}

extension type PlyrOptions._(JSObject _) implements JSObject {
  external PlyrOptions({
    String? title,
    PreviewThumbnailsOptions? previewThumbnails,
  });
}
extension type PreviewThumbnailsOptions._(JSObject _) implements JSObject {
  @JS('')
  external PreviewThumbnailsOptions._js({
    bool? enabled,
    CaptionsOptions? captions,
    JSArray<JSString>? src,
    String? title,
  });

  factory PreviewThumbnailsOptions({
    bool? enabled,
    CaptionsOptions? captions,
    List<String>? src,
    String? title,
  }) {
    return PreviewThumbnailsOptions._js(
      enabled: enabled,
      captions: captions,
      src: src?.map((e) => e.toJS).toList().toJS,
      title: title,
    );
  }
}

extension type CaptionsOptions._(JSObject _) implements JSObject {
  external CaptionsOptions({bool? active});
}

class VideoPlayerController extends ChangeNotifier {
  Plyr? _plyr;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  void play() {
    if (!_isPlaying) {
      _plyr?.play();
    }
  }

  void pause() {
    if (_isPlaying) {
      _plyr?.pause();
    }
  }

  void _updateIsPlaying(bool isPlaying) {
    if (_isPlaying == isPlaying) return;
    _isPlaying = isPlaying;
    notifyListeners();
  }
}
