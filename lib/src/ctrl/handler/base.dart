part of cl_base.ctrl;

class Base {
  dynamic req;

  Base(this.req);

  void page404() => response(
      '', {'type': 'error', 'message': 'Not Found'}, HttpStatus.notFound);

  /// Error handler method. Forms detailed Map of the Error.
  void error(dynamic e, [StackTrace? s]) {
    final action = req is HttpRequest ? req.requestedUri : req.controller;
    final session = 'Session: ${req?.session?.id}';
    if (e is MapperException) {
      if (e is! PostgreConstraintException)
        log.severe('Exception\n$action\n$session', e,
            new StackTrace.fromString(e.details));
      final eo = {
        'type': 'work_exception',
        'message': '$e',
        'details': devmode ? e.details : null
      };
      response(null, eo);
    } else if (e is WorkflowException) {
      final settings = req.session[sessionKey]['settings'] ?? {};
      final locale = settings['language'];
      final eo = {
        'type': 'work_exception',
        'message': Intl.withLocale(locale, e._message!)
      };
      response(null, eo);
    } else if (e is ResourceNotFoundException) {
      page404();
    } else if (e is Exception) {
      log.severe('Exception\n$action\n$session', e, s);
      final eo = {
        'type': 'exception',
        'message': '$e',
        'details': devmode
            ? (s == null ? null : '${Trace.format(s, terse: true)}')
            : null
      };
      response(null, eo);
    } else {
      log.shout('Error\n$action\n$session', e, s);
      final eo = {
        'type': 'error',
        'message': '$e',
        'details': devmode
            ? (s == null ? null : '${Trace.format(s, terse: true)}')
            : null
      };
      response(null, eo, HttpStatus.internalServerError);
    }
  }

  void response(dynamic data, [dynamic status, int? code]) =>
      responseJson({'status': status, 'data': data}, code);

  /// JSON response
  void responseJson(dynamic data, [int? code]) {
    if (req is HttpRequest) {
      req.response.headers.contentType = ContentType.json;
      if (code != null) req.response.statusCode = code;
      req.response.headers.add('X-Powered-By', version);
      req.response.write(json.encode(data));
      req.response.close();
    } else {
      req.write(data);
    }
  }

  /// HTML response
  void responseHtml(dynamic data, [int? code]) {
    req.response.headers.contentType = ContentType.html;
    if (code != null) req.response.statusCode = code;
    req.response.headers.add('X-Powered-By', version);
    req.response.write(data);
    req.response.close();
  }

  /// Response write file using its path and filename.
  Future<void> responseFile(String path, [String? name]) {
    name ??= basename(path);
    req.response.headers.contentType = ContentType.binary;
    req.response.headers
        .add('Content-Disposition', 'attachment; filename=$name');
    return new File(path).openRead().pipe(req.response);
  }

  /// Response write file using [List] data and filename.
  void responseFileBytes(List<int> data, [String? name]) {
    req.response.headers.contentType = ContentType.binary;
    req.response.headers
        .add('Content-Disposition', 'attachment; filename=$name');
    req.response.add(data);
    req.response.close();
  }

  /// Response write file using [List] data as PDF content.
  void responseFileBytesAsPDF(List<int> data) {
    req.response.headers.contentType = ContentType.binary;
    req.response.headers.add('Content-type', 'application/pdf');
    req.response.add(data);
    req.response.close();
  }

  /// Response write file using [Stream] data and filename.
  Future responseStream(Stream<List<int>> stream, [String? name]) {
    req.response.headers.contentType = ContentType.binary;
    req.response.headers
        .add('Content-Disposition', 'attachment; filename=$name');
    return stream.pipe(req.response);
  }

  /// Parsing post request data.
  Future<Map<String, dynamic>> getData() async {
    if (req is HttpRequest) {
      if (req.method == 'POST')
        return HttpBodyHandler.processRequest(req)
            .then((body) => body.body as Map<String, dynamic>)
            .catchError(error);
      else
        return <String, dynamic>{};
    }
    return req.message;
  }

  Future<String> loadResource(String packageFile) async {
    final file = new File('$path/web/packages/$packageFile');
    return file.existsSync()
        ? await file.readAsString()
        : await new ResourceLoader('package:$packageFile').readAsString();
  }

  /// Helper for executing function with scope/group permission.
  Future<void> _run(
      Manager? manager,
      String? group,
      String? scope,
      String? access,
      Future Function()? f,
      Future Function(Manager m)? fm) async {
    if (permissionCheck(req.session, group, scope, access)) {
      try {
        final watch = Stopwatch()..start();
        final history = new History(req.session.id,
            req is WSRequest ? req.controller : req.requestedUri.path);
        notificator.addHistory(history);
        if (manager != null)
          await fm!(manager);
        else
          await f!();
        watch.stop();
        notificator.addHistory(history..execTime = watch.elapsedMilliseconds);
      } catch (e, s) {
        error(e, s);
      }
    } else {
      response(null, {
        'type': 'permission',
        'message': permissionMessage(group, scope, access)
      });
    }
    await manager?.close();
  }

  /// Helper for executing function with scope/group permission and manager.
  Future<void> run(
          String? group, String? scope, String? access, Future Function() f) =>
      _run(null, group, scope, access, f, null);

  /// Helper for executing function with scope/group permission and manager.
  Future<void> runDb(String? group, String? scope, String? access,
      Future Function(Manager) f) async {
    final manager = await new Database().init();
    return _run(manager, group, scope, access, null, f);
  }
}
