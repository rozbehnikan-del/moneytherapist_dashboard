class PickedBroadcastMedia {
  final String name;
  final List<int> bytes;
  final String? contentType;

  const PickedBroadcastMedia({
    required this.name,
    required this.bytes,
    this.contentType,
  });
}
