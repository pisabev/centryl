@TestOn('vm')
library test;

import 'dart:async';

import 'package:centryl/server.dart';
import 'package:mailer/smtp_server.dart';
import 'package:test/test.dart';

Future main() async {
  test('SMTP', () async {
    final m = new Mail(new SmtpServer('ns1.centryl.net',
        port: 25,
        name: 'medicframe',
        username: 'centryl',
        password: 'hidden',
        ignoreBadCertificate: true,
        ssl: false))
      ..from('no-reply@centryl.com')
      ..to('pisabev@gmail.com')
      ..setText('test');
    await m.send();
  });
}
