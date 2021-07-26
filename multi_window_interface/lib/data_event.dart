enum EventType {
  system,
  user,
}

class DataEvent {
  final String key;

  final String from;

  final dynamic data;

  final EventType type;

  DataEvent._(this.key, this.from, this.type, this.data);

  String toString() {
    return 'DataEvent { key: $key, from: $from, type: $type, data: $data }';
  }

  static DataEvent fromMap(dynamic data) {
    return DataEvent._(
      data['key'],
      data['from'],
      data['type'] != null && data['type'] == 'user'
          ? EventType.user
          : EventType.system,
      data['data'],
    );
  }
}
