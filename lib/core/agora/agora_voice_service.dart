import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraVoiceService {
  static final AgoraVoiceService _instance = AgoraVoiceService._internal();
  factory AgoraVoiceService() => _instance;

  late final RtcEngine _engine;
  bool _isJoined = false;

  AgoraVoiceService._internal();

  Future<void> init() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
        RtcEngineContext(appId: '5c61f42e947b4b22a65dc1c66deb0664'));
    await _engine.enableAudio();
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    int uid = 0,
    Function(int uid)? onUserJoined,
    Function(int uid)? onUserOffline,
  }) async {
    if (_isJoined) return;

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (conn, elapsed) => print('Joined channel'),
        onUserJoined: (conn, remoteUid, elapsed) =>
            onUserJoined?.call(remoteUid),
        onUserOffline: (conn, remoteUid, reason) =>
            onUserOffline?.call(remoteUid),
      ),
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );

    _isJoined = true;
  }

  Future<void> leaveChannel() async {
    if (!_isJoined) return;
    await _engine.leaveChannel();
    _isJoined = false;
  }

  void mute(bool isMuted) {
    _engine.muteLocalAudioStream(isMuted);
  }

  bool get isJoined => _isJoined;
}
