import 'package:communicator/server.dart';
import 'package:logging/logging.dart';

import 'src/ctrl.dart';
import 'src/server.dart';

export 'src/ctrl.dart';
export 'src/mapper.dart';
export 'src/server.dart';

Future<void> init() async {
  hierarchicalLoggingEnabled = true;
  new Logger('mailer_sender').level = Level.OFF;
  new Logger('Connection').level = Level.OFF;
  await loadMeta();
  await new CacheService().init();
  routes.add((router) {
    if (anonymousLogin) routesAnonymous(router);
    routesInit(router);
    routesFile(router);
    routesSync(router);
    router.defaultStream.listen((req) {
      if (req is WSRequest)
        new Base(req).page404();
      else
        new Index(req).index();
    });
  });
}
