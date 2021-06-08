part of utils;

class Preloader {
  static Preloader? instance;

  late List<String> _cache;
  late List<Completer> _pool;

  factory Preloader() => instance ??= new Preloader._();

  Preloader._() {
    _cache = [];
    _pool = [];
  }

  Future loadJS(List scripts) {
    final futures = <Future>[];
    scripts.forEach((scr) {
      if (_cache.contains(scr)) {
        futures.addAll(_pool
            .where((compl) => !futures.contains(compl.future))
            .map((compl) => compl.future));
        return;
      }
      _cache.add(scr);
      final script = new ScriptElement();
      final completer = new Completer();
      script.onLoad.listen((e) {
        completer.complete();
        _pool.remove(completer);
      });
      script
          ..defer = true
          ..src = scr;
      document.head!.append(script);
      _pool.add(completer);
      futures.add(completer.future);
    });
    return Future.wait(futures);
  }

  Future loadCSS(List links) {
    final futures = <Future>[];
    links.forEach((scr) {
      if (_cache.contains(scr)) {
        futures.addAll(_pool
            .where((compl) => !futures.contains(compl.future))
            .map((compl) => compl.future));
        return;
      }
      _cache.add(scr);
      final link = new LinkElement();
      final completer = new Completer();
      link.onLoad.listen((e) {
        completer.complete();
        _pool.remove(completer);
      });
      link
        ..href = scr
        ..rel = 'stylesheet';
      document.head!.append(link);
      _pool.add(completer);
      futures.add(completer.future);
    });
    return Future.wait(futures);
  }

  Future loadJSSeq(List scripts) =>
      Future.forEach(scripts, (script) => loadJS([script]));

  Future loadCSSSeq(List scripts) =>
      Future.forEach(scripts, (script) => loadCSS([script]));
}
