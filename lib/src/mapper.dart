library cl_base.mapper;

import 'dart:async';

import 'package:centryl/path.dart';
import 'package:mapper/mapper.dart';

import 'entity.dart' as entity;

part 'db/mapper/api_local.dart';
part 'db/mapper/api_remote.dart';
part 'db/mapper/audit.dart';
part 'db/mapper/cache.dart';
part 'db/mapper/notification.dart';

extension AppExt on App {
  APILocalMapper get api_local => new APILocalMapper(m)
    ..entity = (() => new APILocal())
    ..collection = () => new APILocalCollection();

  APIRemoteMapper get api_remote => new APIRemoteMapper(m)
    ..entity = (() => new APIRemote())
    ..collection = () => new APIRemoteCollection();

  AuditMapper get audit => new AuditMapper(m)
    ..entity = (() => new Audit())
    ..collection = () => new AuditCollection();

  CacheMapper get cache => new CacheMapper(m)
    ..entity = (() => new Cache())
    ..collection = () => new CacheCollection();

  NotificationMapper get notification => new NotificationMapper(m)
    ..entity = (() => new Notification())
    ..collection = () => new NotificationCollection();
}
