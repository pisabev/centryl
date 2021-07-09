part of cl_base.ctrl;

const String sessionKey = 'client';

void routesInit(Router router) =>
    router
        .serve(Routes.init, method: 'POST')
        .listen((req) => new Index(req).init());

void routesAnonymous(Router router) {
  router.filter(new UrlPattern(r'(.*)'), (req) async {
    req.session[sessionKey] = {'name': 'Anonymous'};
    return new Future.value(true);
  });
}

void routesSync(Router router) {
  router
      .serve(Routes.sync, method: 'POST')
      .listen((req) => new CSync(req).index());
}

void routesAudit(Router router) {
  router
      .serve(Routes.audit, method: 'POST')
      .listen((req) => new CAudit(req).getByScope());
}

void routesFile(Router router) =>
    router
      ..serve(Routes.dirList, method: 'POST')
          .listen((req) => new FileManager(req).getDirs())
      ..serve(Routes.dirListAll, method: 'POST')
          .listen((req) => new FileManager(req).getDirsAll())
      ..serve(Routes.dirAdd, method: 'POST')
          .listen((req) => new FileManager(req).dirAdd())
      ..serve(Routes.dirMove, method: 'POST')
          .listen((req) => new FileManager(req).dirMove())
      ..serve(Routes.dirRename, method: 'POST')
          .listen((req) => new FileManager(req).dirRen())
      ..serve(Routes.dirDelete, method: 'POST')
          .listen((req) => new FileManager(req).dirDel())
      ..serve(Routes.fileList, method: 'POST')
          .listen((req) => new FileManager(req).getFiles())
      ..serve(Routes.fileMove, method: 'POST')
          .listen((req) => new FileManager(req).fileMove())
      ..serve(Routes.fileRename, method: 'POST')
          .listen((req) => new FileManager(req).fileRen())
      ..serve(Routes.fileDelete, method: 'POST')
          .listen((req) => new FileManager(req).fileDel())
      ..serve(Routes.fileRead, method: 'POST')
          .listen((req) => new FileManager(req).fileRead())
      ..serve(Routes.fileCreate, method: 'POST')
          .listen((req) => new FileManager(req).fileCreate())
      ..serve(Routes.fileWrite, method: 'POST')
          .listen((req) => new FileManager(req).fileWrite())
      ..serve(Routes.fileUpload, method: 'POST')
          .listen((req) => new FileManager(req).fileUpload());
