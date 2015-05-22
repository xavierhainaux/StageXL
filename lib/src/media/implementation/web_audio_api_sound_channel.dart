part of stagexl.media;

class WebAudioApiSoundChannel extends SoundChannel {
  SoundTransform _soundTransform;
  final bool _loop;

  AudioBufferSourceNode _sourceNode;
  WebAudioApiSound _webAudioApiSound;
  WebAudioApiMixer _webAudioApiMixer;

  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound,
      num startTime, num duration, bool loop, SoundTransform soundTransform) :

      _webAudioApiSound = webAudioApiSound,
      _loop = loop,
      _soundTransform = soundTransform != null ? soundTransform : new SoundTransform() {

    _webAudioApiMixer = webAudioApiSound._mixer;
    _webAudioApiMixer.applySoundTransform(_soundTransform);

    _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
    _sourceNode.buffer = _webAudioApiSound._audioBuffer;
    _sourceNode.loop = _loop;
    _sourceNode.loopStart = startTime;
    _sourceNode.loopEnd = startTime + duration;
    _sourceNode.connectNode(_webAudioApiMixer.inputNode);

    //TODO(xha): pas besoin de condition quand le bug de chrome sera corrigé:
    //https://code.google.com/p/chromium/issues/detail?id=457099
    if (loop) {
      _sourceNode.start(0);
    } else {
      _sourceNode.start(0, startTime, duration);
    }
  }

  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value) {
    _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform();
    _webAudioApiMixer.applySoundTransform(value);
  }

  void stop() {
    _sourceNode.stop(0);
  }
}
