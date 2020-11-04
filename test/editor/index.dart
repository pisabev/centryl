library test;

import 'package:centryl/develop.dart';
import 'package:centryl/forms.dart';

void main() {
  final app = initApp();
  final win = app.winmanager.loadWindow(title: 'Test')..render(800, 800);
  final area = new Editor(app)
    ..setStyle({'width': '100%'})
    ..setValue('<div>test</div>');
  win.getContent()
    ..append(area)
    ..setStyle({'padding': '10px'});
}
