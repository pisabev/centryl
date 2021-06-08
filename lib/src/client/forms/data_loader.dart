part of forms;

mixin DataLoader<T> {
  final StreamController _contrLoadStart = new StreamController.broadcast();
  final StreamController _contrLoadEnd = new StreamController.broadcast();
  final StreamController _contrLoadEndInner = new StreamController.broadcast();

  Stream get onLoadStart => _contrLoadStart.stream;

  Stream get onLoadEnd => _contrLoadEnd.stream;

  Stream get _onLoadEndInner => _contrLoadEndInner.stream;

  Future<T?> Function()? execute;
  StreamSubscription? _executing;
  bool _isLoading = false;
  bool allowNullDeps = false;
  DataElement? self;
  T? data;
  List<Data> dependencies = [];
  final Map<String, StreamSubscription> _listeners = {};
  CLElementBase? loader;

  bool get isLoading => _isLoading;

  void initDataLoader(DataElement el) {
    self = el;
    onLoadStart.listen((_) {
      self!.addClass('loading');
      loader = new LoadElement(self!);
    });
    onLoadEnd.listen((_) {
      self!.removeClass('loading');
      loader?.remove();
    });
  }

  Future? _cancel() => _executing?.cancel().then((_) => _executing = null);

  void load() {
    if (!allowNullDeps && dependencies.any((el) => !el.hasValue())) return;
    if (_executing != null) {
      _cancel()?.then((_) => load());
    } else {
      data = null;
      loadStart();
      _executing = execute!().asStream().listen(_loadEnd, onError: (e, s) {
        logging.severe(runtimeType.toString(), e, s);
      });
    }
  }

  void _loadEnd(d) {
    data = d;
    _contrLoadEndInner.add(this);
  }

  void loadStart() {
    if (_isLoading) return;
    _contrLoadStart.add(this);
    _isLoading = true;
  }

  void loadEnd() {
    if (!_isLoading) return;
    _executing = null;
    _isLoading = false;
    _contrLoadEnd.add(this);
  }

  void dependOn(Data object) {
    dependencies.add(object);
    _listeners[object.runtimeType.toString()] =
        object.onValueChanged.listen((_) => load());
  }

  void removeDependency(Data object) {
    dependencies.remove(object);
    _listeners.remove(object.runtimeType.toString())?.cancel();
  }

  Map<String, dynamic> getDependencyData() {
    final Map<String, dynamic> m = {};
    dependencies.forEach((d) {
      m[d.getName().toString()] = d.getValue();
    });
    return m;
  }
}
