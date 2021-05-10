class DataEvent {
  final String key;

  DataEvent(this.key);

  static DataEvent from(dynamic data) {
    return DataEvent(data['key']);
  }
}
