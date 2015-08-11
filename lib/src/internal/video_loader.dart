library stagexl.internal.video_loader;

import 'dart:async';
import 'dart:html';

class VideoLoader {

  static final List<String> supportedTypes = _getSupportedTypes();

  final VideoElement video = new VideoElement();
  final Completer<VideoElement> _completer = new Completer<VideoElement>();

  List<String> _urls = new List<String>();
  bool _loadData = false;

  StreamSubscription _onCanPlaySubscription;
  StreamSubscription _onErrorSubscription;
  Timer _accessReadyStateTimer;

  VideoLoader(List<String> urls, bool loadData, bool corsEnabled) {

    if (corsEnabled) video.crossOrigin = 'anonymous';

    _onCanPlaySubscription = video.onCanPlayThrough.listen((e) => _loadDone());
    _onErrorSubscription = video.onError.listen((e) {
      print('[StageXL] Video error: $e');
      _loadFailed();
    });

    _urls.addAll(urls);
    _loadData = loadData;
    _loadNextUrl();

    // There is a realy weird bug with IE11. Sometimes, the onCanPlay event
    // doesn't fire. Just accessing the readyState of the video seems to
    // bypass the bug
    _accessReadyStateTimer = new Timer.periodic(const Duration(seconds: 1), (_) {
      video.readyState; // just access the property seems enough
    });
  }

  Future<VideoElement> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _loadNextUrl() {
    if (_urls.length == 0) {
      _loadFailed();
    } else if (_loadData) {
      _loadVideoData(_urls.removeAt(0));
    } else {
      _loadVideoSource(_urls.removeAt(0));
    }
  }

  void _loadFailed() {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _accessReadyStateTimer.cancel();
    _completer.completeError(new StateError("Failed to load video."));
  }

  void _loadDone() {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _accessReadyStateTimer.cancel();
    _completer.complete(video);
  }

  void _loadVideoData(String url) {
    HttpRequest.request(url, responseType: 'blob').then((request) {
      var reader = new FileReader();
      reader.readAsDataUrl(request.response);
      reader.onLoadEnd.first.then((e) {
        if(reader.readyState == FileReader.DONE) {
          _loadVideoSource(reader.result);
        } else {
          _loadFailed();
        }
      });
    }).catchError((error) {
      print('[StageXL] Error while requesting video: $error');
      _loadFailed();
    });
  }

  void _loadVideoSource(String url) {
    video.preload = "auto";
    video.src = url;
    video.load();
  }

  //---------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {

    var supportedTypes = new List<String>();
    var video = new VideoElement();
    var valid = ["maybe", "probably"];

    if (valid.indexOf(video.canPlayType("video/webm")) != -1) supportedTypes.add("webm");
    if (valid.indexOf(video.canPlayType("video/mp4")) != -1) supportedTypes.add("mp4");
    if (valid.indexOf(video.canPlayType("video/ogg")) != -1) supportedTypes.add("ogg");

    print("StageXL video types   : $supportedTypes");

    return supportedTypes.toList(growable: false);
  }

}
