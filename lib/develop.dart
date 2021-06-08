import 'dart:math';

import 'package:centryl/app.dart';

Application<C> initApp<C extends Client>([C? client]) =>
    new Application<C>(settings: new AppSettings()..menuDefaultOpen = false)
      ..setClient(client ??
          new Client({
            'client': {'name': 'test'}
          }))
      ..done();

abstract class RandomBase<T> {
  RandomBase();

  T? generate();
}

class RandomWord implements RandomBase<String> {
  final List<String> list;

  RandomWord(this.list);

  String generate() {
    final r = new Random();
    return list[r.nextInt(list.length)];
  }
}

class RandomUniqueWord implements RandomBase<String> {
  final _set = <String>{};
  final List<String> list;

  RandomUniqueWord(this.list);

  String? generate() {
    final r = new Random();
    final w = list[r.nextInt(list.length)];
    if (!_set.contains(w)) {
      _set.add(w);
      return w;
    } else {
      if (_set.length == list.length) return null;
      return generate();
    }
  }
}

class RandomText implements RandomBase<String> {
  final String text;

  RandomText(this.text);

  String generate() {
    final parts = text.split(' ');
    final r = new Random();
    return parts.sublist(0, r.nextInt(parts.length)).join(' ');
  }
}

class RandomDateTime implements RandomBase<String> {
  String generate() {
    final r = new Random();
    final second = r.nextInt(60 * 60 * 24);
    final d = new DateTime.now();
    return new DateTime(d.year, d.month, d.day, 0, second).toIso8601String();
  }
}

class RandomInteger implements RandomBase<int> {
  final int max;

  RandomInteger(this.max);

  int generate() => new Random().nextInt(max);
}

class RandomUniqueInteger implements RandomBase<int> {
  late Set _set;
  late final int max;

  RandomUniqueInteger(this.max, {Set? exclude}) {
    _set = exclude ?? {};
  }

  int generate() {
    final n = new Random().nextInt(max);
    if (!_set.contains(n)) {
      _set.add(n);
      return n;
    } else {
      if (_set.length == max) return 0;
      return generate();
    }
  }
}

class RandomListMap implements RandomBase<List<Map<String, dynamic>>> {
  final int count;
  Map<String, dynamic> map;

  RandomListMap(this.count, this.map);

  List<Map<String, dynamic>> generate() {
    final List<Map<String, dynamic>> l = [];
    for (var i = 0; i < count; i++) {
      final m = <String, dynamic>{};
      map.forEach((k, v) => m[k] = (v is RandomBase) ? v.generate() : v);
      l.add(m);
    }
    return l;
  }
}

class RandomMap implements RandomBase<Map<String, dynamic>> {
  Map<String, dynamic> map;

  RandomMap(this.map);

  Map<String, dynamic> generate() {
    final m = <String, dynamic>{};
    map.forEach((k, v) => m[k] = (v is RandomBase) ? v.generate() : v);
    return m;
  }
}
