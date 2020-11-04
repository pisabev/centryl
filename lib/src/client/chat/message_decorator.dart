part of chat;

class MessageDecoratorManager {
  Map<int, List<MessageDecoratorBase>> decorators = {};

  static MessageDecoratorManager instance;

  factory MessageDecoratorManager() =>
      instance ??= new MessageDecoratorManager._();

  MessageDecoratorManager._();

  void registerDecorator(int type, MessageDecoratorBase decorator) {
    if (decorators[type] == null) decorators[type] = [];
    decorators[type].add(decorator);
  }

  void removeDecorator(int type, MessageDecoratorBase decorator) =>
      decorators[type].remove(decorator);

  dynamic decorate(int type, String message) {
    if (type == null) return message;
    dynamic res = message;
    for (final d in decorators[type]) {
      if (d.check(message)) {
        res = d.decorate(res);
        if (d.single) break;
      }
    }
    return res;
  }
}

abstract class MessageDecoratorBase {
  final bool single;

  MessageDecoratorBase({this.single = false});

  bool check(String message);

  dynamic decorate(String message);
}

abstract class MessageDecoratorFile extends MessageDecoratorBase {
  String fileName;
  String source;
  int width = 265;
  int height = 265;

  MessageDecoratorFile() : super(single: true);

  bool check(String message);

  void setUrlParts(String message) {
    final parts = message.split('/');
    fileName = parts.removeLast();
    source =
        '${Chat.baseurl}${parts.join('/')}/${Uri.encodeComponent(fileName)}';
  }

  dynamic decorate(String message);
}

class MessageDecoratorLink extends MessageDecoratorBase {
  final pattern = new RegExp(
      r'(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}'
      r'\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))');

  MessageDecoratorLink();

  bool check(String message) => message.contains(pattern);

  String decorate(String message) {
    final matches = pattern.allMatches(message);
    if (matches.isNotEmpty) {
      matches.forEach((m) {
        final l = m.group(1);
        message = message.replaceAll(l, '<a href="$l" target="_blank">$l</a>');
      });
    }
    return message;
  }
}

class MessageDecoratorEmoticons extends MessageDecoratorBase {
  static final Map _m = {
    ':)': 'chat_smiling',
    ':(': 'chat_sad',
    ':p': 'chat_tongue',
    ':|': 'chat_secret',
    ';)': 'chat_wink',
    ';(': 'chat_unhappy',
    ':D': 'chat_happy',
    ':@': 'chat_angry',
    '(bored)': 'chat_bored',
    '(confused)': 'chat_confused',
    '(crying)': 'chat_crying',
    '(embarrassed)': 'chat_embarrassed',
    '(emoticons)': 'chat_emoticons',
    '(ill)': 'chat_ill',
    '(kissing)': 'chat_kissing',
    '(love)': 'chat_love',
    '(mad)': 'chat_mad',
    '(nerd)': 'chat_nerd',
    '(ninja)': 'chat_ninja',
    '(quiet)': 'chat_quiet',
    '(smart)': 'chat_smart',
    '(smile)': 'chat_smile',
    '(surprised)': 'chat_surprised',
    '(suspicious)': 'chat_suspicious',
  };

  MessageDecoratorEmoticons();

  bool check(String message) => true;

  String createSource(String id) =>
      '<svg class="$id" style="width:20px;height:20px;">'
      '<use href="${Icon.BASEURL}${Icon.spr}#$id"/></svg>';

  String decorate(String message) {
    _m.forEach(
        (key, value) => message = message.replaceAll(key, createSource(value)));
    return message;
  }
}

class MessageDecoratorFileImage extends MessageDecoratorFile {
  MessageDecoratorFileImage();

  bool check(String message) =>
      message.toLowerCase().endsWith('.jpg') ||
      message.toLowerCase().endsWith('.jpeg') ||
      message.toLowerCase().endsWith('.png') ||
      message.toLowerCase().endsWith('.svg') ||
      message.toLowerCase().endsWith('.gif');

  bool hasResize(String message) =>
      message.toLowerCase().endsWith('.jpg') ||
      message.toLowerCase().endsWith('.jpeg') ||
      message.toLowerCase().endsWith('.png');

  AnchorElement decorate(String message) {
    setUrlParts(message);
    return new AnchorElement()
      ..target = '_blank'
      ..href = source
      ..title = fileName
      ..append(new ImageElement()
        ..src = hasResize(fileName)
            ? source.replaceAll('media', 'media/image${width}x$height')
            : source);
  }
}

class MessageDecoratorFileDoc extends MessageDecoratorFile {
  MessageDecoratorFileDoc();

  bool check(String message) =>
      message.toLowerCase().endsWith('.doc') ||
      message.toLowerCase().endsWith('.docx');

  AnchorElement decorate(String message) {
    setUrlParts(message);
    return new AnchorElement()
      ..target = '_blank'
      ..href = source
      ..title = fileName
      ..append(new Icon(Icon.file_word).dom);
  }
}

class MessageDecoratorFileXls extends MessageDecoratorFile {
  MessageDecoratorFileXls();

  bool check(String message) =>
      message.toLowerCase().endsWith('.xls') ||
      message.toLowerCase().endsWith('.xlsx');

  AnchorElement decorate(String message) {
    setUrlParts(message);
    return new AnchorElement()
      ..target = '_blank'
      ..href = source
      ..title = fileName
      ..append(new Icon(Icon.file_excel).dom);
  }
}

class MessageDecoratorFilePdf extends MessageDecoratorFile {
  MessageDecoratorFilePdf();

  bool check(String message) => message.toLowerCase().endsWith('.pdf');

  AnchorElement decorate(String message) {
    setUrlParts(message);
    final link = new AnchorElement()
      ..target = '_blank'
      ..href = source
      ..title = fileName;

    final CanvasElement canvas = document.createElement('canvas');
    final ctx = canvas.getContext('2d');
    canvas
      ..width = width
      ..height = height;

    new Future(() async {
      final doc = pdfjsLib.getDocument(source);
      final d = await FutureWrap<PDFDocument>(doc.promise);
      final page = await FutureWrap<Page>(d.getPage(1));
      final v = page.getViewport(new Arguments(
          scale:
              canvas.width / page.getViewport(new Arguments(scale: 1)).width));
      final task =
          page.render(new RenderParameters(viewport: v, canvasContext: ctx));
      await FutureWrap(task.promise);
    });
    return link..append(canvas);
  }
}

class MessageDecoratorFileVideo extends MessageDecoratorFile {
  MessageDecoratorFileVideo();

  bool check(String message) =>
      message.toLowerCase().endsWith('.mkv') ||
      message.toLowerCase().endsWith('.mp4') ||
      message.toLowerCase().endsWith('.webm') ||
      message.toLowerCase().endsWith('.ogg');

  VideoElement decorate(String message) {
    setUrlParts(message);
    return new VideoElement()
      ..controls = true
      ..append(new SourceElement()..src = source);
  }
}

class MessageDecoratorFileGeneric extends MessageDecoratorFile {
  MessageDecoratorFileGeneric();

  bool check(String message) => true;

  AnchorElement decorate(String message) {
    setUrlParts(message);
    return new AnchorElement()
      ..target = '_blank'
      ..href = source
      ..title = fileName
      ..append(new Icon(Icon.file_unknown).dom);
  }
}
