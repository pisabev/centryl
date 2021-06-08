// GENERATED CODE - DO NOT MODIFY BY HAND

part of cl_base.entity;

// **************************************************************************
// EntitySerializableGenerator
// **************************************************************************

abstract class $APILocal {
  static const String api_local_id = 'api_local_id',
      name = 'name',
      key = 'key',
      limit = 'limit',
      active = 'active';
}

void _$APILocalFromMap(APILocal obj, Map data) => obj
  ..api_local_id = data[$APILocal.api_local_id]
  ..name = data[$APILocal.name]
  ..key = data[$APILocal.key]
  ..limit = data[$APILocal.limit]
  ..active = data[$APILocal.active];

Map<String, dynamic> _$APILocalToMap(APILocal obj, [asJson = false]) =>
    <String, dynamic>{
      $APILocal.api_local_id: obj.api_local_id,
      $APILocal.name: obj.name,
      $APILocal.key: obj.key,
      $APILocal.limit: obj.limit,
      $APILocal.active: obj.active
    };

abstract class $APIRemote {
  static const String api_remote_id = 'api_remote_id',
      name = 'name',
      key = 'key',
      host = 'host';
}

void _$APIRemoteFromMap(APIRemote obj, Map data) => obj
  ..api_remote_id = data[$APIRemote.api_remote_id]
  ..name = data[$APIRemote.name]
  ..key = data[$APIRemote.key]
  ..host = data[$APIRemote.host];

Map<String, dynamic> _$APIRemoteToMap(APIRemote obj, [asJson = false]) =>
    <String, dynamic>{
      $APIRemote.api_remote_id: obj.api_remote_id,
      $APIRemote.name: obj.name,
      $APIRemote.key: obj.key,
      $APIRemote.host: obj.host
    };

abstract class $Cache {
  static const String key = 'key', value = 'value', expire = 'expire';
}

void _$CacheFromMap(Cache obj, Map data) => obj
  ..key = data[$Cache.key]
  ..value = data[$Cache.value]
  ..expire = DateTime.parse(data[$Cache.expire]);

Map<String, dynamic> _$CacheToMap(Cache obj, [asJson = false]) =>
    <String, dynamic>{
      $Cache.key: obj.key,
      $Cache.value: obj.value,
      $Cache.expire: asJson ? obj.expire.toIso8601String() : obj.expire
    };

abstract class $Notification {
  static const String notification_id = 'notification_id',
      key = 'key',
      value = 'value',
      date = 'date';
}

void _$NotificationFromMap(Notification obj, Map data) => obj
  ..notification_id = data[$Notification.notification_id]
  ..key = data[$Notification.key]
  ..value = data[$Notification.value]
  ..date = data[$Notification.date] is String
      ? DateTime.parse(data[$Notification.date])
      : data[$Notification.date];

Map<String, dynamic> _$NotificationToMap(Notification obj, [asJson = false]) =>
    <String, dynamic>{
      $Notification.notification_id: obj.notification_id,
      $Notification.key: obj.key,
      $Notification.value: obj.value,
      $Notification.date: asJson ? obj.date?.toIso8601String() : obj.date
    };
