import 'dart:async';

import 'package:build/build.dart';

Builder dbEmptyBuilder(BuilderOptions options) => new DbEmptyBuilder();

PostProcessBuilder dbCleanup(BuilderOptions options) =>
    const FileDeletingBuilder(['.sql', '.sql_'], isEnabled: true);

class DbEmptyBuilder implements Builder {
  final String extension = '.sql_';

  @override
  Future build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final copy = inputId.changeExtension(extension);
    await buildStep.writeAsString(copy, '');
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.sql': [extension],
      };
}
