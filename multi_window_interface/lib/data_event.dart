enum EventType {
  System,
  User,
}

class DataEvent {
  final String key;

  final dynamic data;

  final EventType type;

  DataEvent._(this.key, this.type, this.data);

  String toString() {
    return 'DataEvent { key: $key, type: $type, data: $data }';
  }

  static DataEvent from(dynamic data) {
    return DataEvent._(
      data['key'],
      data['type'] != null && data['type'] == 'user'
          ? EventType.User
          : EventType.System,
      data['data'],
    );
  }
}
