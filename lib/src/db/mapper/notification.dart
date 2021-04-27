part of cl_base.mapper;

class NotificationMapper extends Mapper<Notification, NotificationCollection> {
  String table = entity.Notification.$table;
  dynamic pkey = entity.$Notification.notification_id;

  Future<List<String>> findKeys([String? sug]) async {
    final q = Builder()
      ..select(entity.$Notification.key)
      ..from(entity.Notification.$table)
      ..groupBy(entity.$Notification.key);

    if (sug != null && sug.isNotEmpty)
      q
        ..andWhere('${entity.$Notification.key} ilike @sug')
        ..setParameter('sug', '%$sug%');

    final res = await manager.execute(q);
    return res
        .map((el) => el[entity.$Notification.key])
        .toList()
        .cast<String>();
  }

  NotificationMapper(m) : super(m);
}

class Notification extends entity.Notification with Entity {}

class NotificationCollection
    extends entity.NotificationCollection<Notification> {}
