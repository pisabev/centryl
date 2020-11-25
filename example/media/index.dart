library test.cl.video;

import 'dart:html';

import 'package:centryl/base.dart';
import 'package:centryl/chat.dart';
import 'package:centryl/develop.dart';
import 'package:centryl/forms.dart';
import 'package:centryl/gui.dart';

Future<void> main() async {
  final app = initApp();
  final form = new FormElement()
    ..addClass('top')
    ..setStyle({'max-width': '400px'});
  app.gadgetsContainer.append(form);

  final media = new Media(app);
  final cameras = await media.getDevices(type: DeviceKind.videoinput);
  final video = new CLElement<VideoElement>(new VideoElement());
  MediaStream stream;
  final select = new Select()
    ..onValueChanged.listen((e) async {
      stream?.getTracks()?.forEach((t) => t.stop());
      media.videoId = e.getValue();
      stream = await media.getUserMedia(video: true);
      video.dom
        ..autoplay = true
        ..srcObject = stream;
    });
  cameras.forEach((c) => select.addOption(c.deviceId, c.label));
  form.addRow(null, [select, video]);
}
