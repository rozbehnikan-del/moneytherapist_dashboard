import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'broadcast_media_pick_result.dart';

Future<PickedBroadcastMedia?> pickBroadcastMediaFile({
  required List<String> allowedExtensions,
}) {
  final completer = Completer<PickedBroadcastMedia?>();
  final input = html.FileUploadInputElement()
    ..accept = allowedExtensions.map((extension) => '.$extension').join(',')
    ..multiple = false;

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError('Failed to read selected file.');
      }
    });
    reader.onLoadEnd.first.then((_) {
      if (completer.isCompleted) return;

      final result = reader.result;
      if (result is Uint8List) {
        completer.complete(
          PickedBroadcastMedia(
            name: file.name,
            bytes: result,
            contentType: file.type,
          ),
        );
        return;
      }
      if (result is ByteBuffer) {
        completer.complete(
          PickedBroadcastMedia(
            name: file.name,
            bytes: result.asUint8List(),
            contentType: file.type,
          ),
        );
        return;
      }

      completer.completeError('Selected file could not be read as bytes.');
    });
    reader.readAsArrayBuffer(file);
  });

  input.click();

  return completer.future;
}
