import 'broadcast_media_picker_stub.dart'
    if (dart.library.html) 'broadcast_media_picker_web.dart';
import 'broadcast_media_pick_result.dart';

Future<PickedBroadcastMedia?> pickBroadcastMedia({
  required List<String> allowedExtensions,
}) {
  return pickBroadcastMediaFile(allowedExtensions: allowedExtensions);
}
