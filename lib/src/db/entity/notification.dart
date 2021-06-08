part of cl_base.entity;

@MSerializable()
class Notification {
  static const String $notification = 'base_notification';

  static String get $table => $notification;

  int? notification_id;
  String? key;
  String? value;
  DateTime? date;

  Notification();

  void init(Map data) => _$NotificationFromMap(this, data);

  Map<String, dynamic> toMap() => _$NotificationToMap(this);

  Map<String, dynamic> toJson() => _$NotificationToMap(this, true);
}

class NotificationCollection<E extends Notification> extends Collection<E> {}
