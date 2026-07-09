import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'broadcast_media_pick_result.dart';

class BroadcastVoiceRecordingSession {
  final html.MediaRecorder _mediaRecorder;
  final html.MediaStream _stream;
  final DateTime _startedAt;
  final String _mimeType;
  final List<dynamic> _chunks = [];
  final Completer<PickedBroadcastMedia> _result = Completer();

  BroadcastVoiceRecordingSession._(
    this._mediaRecorder,
    this._stream,
    this._startedAt,
    this._mimeType,
  ) {
    _mediaRecorder.addEventListener(
      'dataavailable',
      (event) {
        final data = (event as dynamic).data;
        if (data != null) {
          _chunks.add(data);
        }
      },
    );

    _mediaRecorder.addEventListener(
      'stop',
      (_) {
        _finish();
      },
    );
  }

  Future<PickedBroadcastMedia> stop() {
    if (_mediaRecorder.state != 'inactive') {
      _mediaRecorder.stop();
    }

    _stopTracks();
    return _result.future;
  }

  void _finish() {
    if (_result.isCompleted) return;

    final blob = html.Blob(_chunks, _mimeType);
    final reader = html.FileReader();

    reader.onError.first.then((_) {
      if (!_result.isCompleted) {
        _result.completeError('Failed to read recorded voice.');
      }
    });

    reader.onLoadEnd.first.then((_) {
      if (_result.isCompleted) return;

      final result = reader.result;
      final durationSeconds = DateTime.now().difference(_startedAt).inSeconds;
      final extension = _mimeType.contains('ogg') ? 'ogg' : 'webm';
      final fileName =
          'voice_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (result is Uint8List) {
        _result.complete(
          PickedBroadcastMedia(
            name: fileName,
            bytes: result,
            contentType: _mimeType,
          ),
        );
        return;
      }

      if (result is ByteBuffer) {
        _result.complete(
          PickedBroadcastMedia(
            name: fileName,
            bytes: result.asUint8List(),
            contentType: _mimeType,
          ),
        );
        return;
      }

      _result.completeError(
        'Recorded voice could not be read. Duration: ${durationSeconds}s',
      );
    });

    reader.readAsArrayBuffer(blob);
  }

  void _stopTracks() {
    final tracks = _stream.getTracks();
    for (final track in tracks) {
      track.stop();
    }
  }
}

Future<BroadcastVoiceRecordingSession> startBroadcastVoiceRecording() async {
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null) {
    throw UnsupportedError('Microphone recording is not supported in this browser.');
  }

  final stream = await mediaDevices.getUserMedia({'audio': true});

  final mimeType = _bestSupportedMimeType();
  final recorder = html.MediaRecorder(
    stream,
    {'mimeType': mimeType},
  );
  final session = BroadcastVoiceRecordingSession._(
    recorder,
    stream,
    DateTime.now(),
    mimeType,
  );

  recorder.start();
  return session;
}

String _bestSupportedMimeType() {
  const preferredTypes = [
    'audio/ogg;codecs=opus',
    'audio/webm;codecs=opus',
    'audio/webm',
  ];

  for (final type in preferredTypes) {
    try {
      if (html.MediaRecorder.isTypeSupported(type)) return type;
    } catch (_) {
      return 'audio/webm';
    }
  }

  return 'audio/webm';
}
