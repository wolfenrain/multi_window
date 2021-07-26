/// To determine if it is a user or system event.
enum DataEventType {
  system,
  user,
}

/// Basic event structure for events between windows.
class DataEvent {
  /// To which window it was send.
  final String to;

  /// From which window it was sent.
  ///
  /// Will be equal to [to] when [type] is [DataEventType.system].
  final String from;

  /// The data emitted.
  final dynamic data;

  /// The type of event, either system or user.
  final DataEventType type;

  DataEvent._(this.to, this.from, this.type, this.data);

  String toString() {
    return 'DataEvent { to: $to, from: $from, type: $type, data: $data }';
  }

  /// Construct a new DataEvent.
  ///
  /// Should only be used internally.
  static DataEvent fromMap(dynamic data) {
    return DataEvent._(
      data['to'],
      data['from'],
      data['type'] != null && data['type'] == 'user'
          ? DataEventType.user
          : DataEventType.system,
      data['data'],
    );
  }
}
