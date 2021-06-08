part of cl_base.svc.server;

class CacheService {
  static CacheService? _instance;
  final Schedule sched = new Schedule();
  static final Map<String, Map> _local = {};

  factory CacheService() => _instance ??= new CacheService._();

  CacheService._();

  Future set(String key, Map value,
      {DateTime? expire, Duration? expireAfter, bool persist = true}) async {
    expire = expireAfter != null
        ? new DateTime.now().toUtc().add(expireAfter)
        : expire;

    if (!persist) {
      _local[key] = value;
      sched.addEvent(new ScheduleEvent('cache:$key', () {
        remove(key);
      }, execute_at: expire));
      return null;
    }

    return dbWrap<void>((manager) async {
      var obj = await manager.app.cache.find(key);
      if (obj == null) {
        obj = manager.app.cache.createObject()
          ..key = key
          ..value = value;
        manager.addNew(obj);
      } else {
        obj.value = value;
        sched.removeEventsById('cache:$key');
        manager.addDirty(obj);
      }
      if (expire != null) {
        obj.expire = expire;
        sched.addEvent(new ScheduleEvent('cache:$key', () {
          remove(key);
        }, execute_at: expire));
      }
      return manager.commit();
    });
  }

  Future<Map?> get(String key) async {
    if (_local.containsKey(key)) return _local[key];
    return dbWrap<Map?>((manager) async {
      final c = await manager.app.cache.find(key);
      return c?.value;
    });
  }

  Future<bool> remove(String key) async {
    _local.remove(key);
    // TODO if the cache is local don't try to delete from db
    return dbWrap<bool>((manager) => manager.app.cache.deleteById(key));
  }

  Future init() => dbWrap<void>((manager) async {
        final col = await manager.app.cache.findAllWithExpire();
        for (final c in col) {
          if (c.expire.isBefore(new DateTime.now()))
            await manager.app.cache.delete(c);
          else {
            sched.addEvent(new ScheduleEvent('cache:${c.key}', () {
              remove(c.key);
            }, execute_at: c.expire));
          }
        }
      });
}
