import 'broadcast_media_pick_result.dart';

class BroadcastVoiceRecordingSession {
  Future<PickedBroadcastMedia> stop() {
    throw UnsupportedError(
      'Voice recording is only available in the web dashboard.',
    );
  }
}

Future<BroadcastVoiceRecordingSession> startBroadcastVoiceRecording() {
  throw UnsupportedError(
    'Voice recording is only available in the web dashboard.',
  );
}
