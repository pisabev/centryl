part of forms;

class MyUriPolicy implements html.UriPolicy {
  bool allowsUri(String uri) => true;
}

class EditorOption {
  final String? icon;
  final String title;
  final dynamic action;

  const EditorOption(this.icon, this.title, this.action);
}

class EditorOptions {
  EditorOption undo = const EditorOption(Icon.undo, 'Undo', 'undo');
  EditorOption redo = const EditorOption(Icon.redo, 'Redo', 'redo');
  EditorOption bold = const EditorOption(Icon.format_bold, 'Bold', 'bold');
  EditorOption italic =
      const EditorOption(Icon.format_italic, 'Italic', 'italic');
  EditorOption underline =
      const EditorOption(Icon.format_underlined, 'Underline', 'underline');
  EditorOption strikethrough = const EditorOption(
      Icon.format_strikethrough, 'Strikethrough', 'strikethrough');
  EditorOption listNumbered = const EditorOption(
      Icon.format_list_numbered, 'Insert Ordered List', 'insertorderedlist');
  EditorOption listBulleted = const EditorOption(Icon.format_list_bulleted,
      'Insert Unordered List', 'insertunorderedlist');
  EditorOption formatblock = const EditorOption(null, 'Format Block', [
    'formatblock',
    ['Paragraph', '<div>'],
    ['Header 1', '<h1>'],
    ['Header 2', '<h2>'],
    ['Header 3', '<h3>']
  ]);
  EditorOption indentDecrease =
      const EditorOption(Icon.format_indent_decrease, 'Outdent', 'outdent');
  EditorOption indentIncrease =
      const EditorOption(Icon.format_indent_increase, 'Indent', 'indent');
  EditorOption alignLeft =
      const EditorOption(Icon.format_align_left, 'Left Align', 'justifyleft');
  EditorOption alignCenter = const EditorOption(
      Icon.format_align_center, 'Center Align', 'justifycenter');
  EditorOption alignRight = const EditorOption(
      Icon.format_align_right, 'Right Align', 'justifyright');
  EditorOption alignJustify = const EditorOption(
      Icon.format_align_justify, 'Block Justify', 'justifyfull');
  EditorOption clearFormat = const EditorOption(
      Icon.format_clear, 'Remove Formatting', 'removeformat');
  EditorOption fullscreen =
      const EditorOption(Icon.fullscreen, 'Full Screen', 'fullScreen');
  EditorOption image =
      const EditorOption(Icon.image, 'Insert Image', 'insertimage');
}

class Editor extends FieldBase<String, html.DivElement> {
  late app.Application ap;
  late CLElement<html.DivElement> frame;
  late Container fieldContainer;
  late codemirror.CodeMirror fieldMirror;
  late CLElement head, body, footer, path;
  late action.Menu menu;
  late List<EditorOption> options;
  final bool showFooter;
  action.Button? sourceBtn;

  late CLElement _parentDom;
  late num _bHeight;
  bool _fullscreen = false;

  late utils.CLscroll _scroll;

  final html.NodeValidatorBuilder _htmlValidator =
      new html.NodeValidatorBuilder()
        ..allowNavigation(new MyUriPolicy())
        ..allowImages(new MyUriPolicy())
        ..allowHtml5(uriPolicy: new MyUriPolicy())
        ..allowElement('style')
        ..allowTemplating()
        ..allowInlineStyles()
        ..allowSvg();

  Editor(this.ap, {List<EditorOption>? options, this.showFooter = true})
      : super() {
    dom = new html.DivElement();
    setClass('ui-editor');
    _createHTML();
    this.options = options ?? fullOptions();
    _createMenu();
  }

  Future<void> _createEditor() async {
    await Future.wait([
      new utils.Preloader().loadJSSeq([
        '${ap.baseurl}packages/codemirror/codemirror.js',
        '${ap.baseurl}packages/codemirror/addon/scroll/simplescrollbars.js'
      ]),
      new utils.Preloader().loadCSSSeq([
        '${ap.baseurl}packages/codemirror/codemirror.css',
        '${ap.baseurl}packages/codemirror/addon/scroll/simplescrollbars.css'
      ])
    ]);
    final options = {
      'theme': app.getCodeMirrorTheme(ap),
      'mode': 'htmlmixed',
      'scrollbarStyle': 'overlay',
      'lineNumbers': true,
      'autoCloseTags': true,
      'autoCloseBrackets': true
    };
    fieldContainer.removeChilds();
    fieldMirror = new codemirror.CodeMirror.fromElement(fieldContainer.dom,
        options: options);
  }

  static List<EditorOption> lightOptions() => [
        EditorOptions().bold,
        EditorOptions().italic,
        EditorOptions().underline,
        EditorOptions().strikethrough,
        EditorOptions().listNumbered,
        EditorOptions().listBulleted
      ];

  static List<EditorOption> fullOptions() => [
        EditorOptions().undo,
        EditorOptions().redo,
        EditorOptions().bold,
        EditorOptions().italic,
        EditorOptions().underline,
        EditorOptions().strikethrough,
        EditorOptions().listNumbered,
        EditorOptions().listBulleted,
        EditorOptions().formatblock,
        EditorOptions().indentDecrease,
        EditorOptions().indentIncrease,
        EditorOptions().alignLeft,
        EditorOptions().alignCenter,
        EditorOptions().alignRight,
        EditorOptions().alignJustify,
        EditorOptions().image,
        EditorOptions().clearFormat,
        EditorOptions().fullscreen
      ];

  void _createHTML() {
    head = new CLElement(new html.DivElement())
      ..setClass('ui-editor-header')
      ..appendTo(this);
    body = new CLElement(new html.DivElement())
      ..setClass('ui-editor-body')
      ..appendTo(this);
    final d = html.DivElement()..classes.add('wrap');
    body.append(d);
    frame = new CLElement(new html.DivElement())
      ..setClass('iframe')
      ..appendTo(d)
      ..addAction((e) => super.setValue(frame.dom.innerHtml), 'blur');
    frame.dom.contentEditable = 'true';
    if (showFooter) {
      footer = new CLElement(new html.DivElement())
        ..setClass('ui-editor-footer')
        ..appendTo(this);
      path = new CLElement(new html.SpanElement())
        ..setClass('ui-editor-path')
        ..appendTo(footer);
      frame.addAction(_getPath, 'mousedown');
    }
    _scroll = new utils.CLscroll(body.dom);
    _scroll.containerEl.style.width = '110%';
    frame.addAction(_onPaste, 'paste');
    fieldContainer = new Container()
      ..addClass('editor')
      ..appendTo(body)
      ..hide();
    try {
      //_exec('styleWithCSS', 'true');
      _exec('defaultParagraphSeparator', 'div');
    } catch (e) {}
  }

  void _createMenu() {
    menu = new action.Menu(head);
    options.forEach((option) {
      if (option.action is List) {
        final a = new Select();
        option.action.skip(1).forEach((o) {
          final t = o[0];
          final v = (o.length == 2) ? o[1] : o[0];
          a.addOption(v, t);
        });
        a.onValueChanged
            .listen((e) => _exec(option.action.first, e.getValue()));
        menu.add(a);
      } else {
        final a = new action.Button()
          ..setIcon(option.icon)
          ..addClass('light');
        if (option.action == 'insertimage')
          a.addAction<html.Event>((e) => insertImage(e, option.action));
        else if (option.action == 'fullScreen')
          a.addAction(fullScreen);
        else
          a.addAction((e) => _exec(option.action));
        a.inner.dom.setAttribute('unselectable', 'on');
        menu.add(a);
      }
    });
    if (showFooter)
      sourceBtn = new action.Button()
        ..setIcon(Icon.code)
        ..addClass('light')
        ..addAction(_toggleSource)
        ..appendTo(footer);
  }

  void _onPaste(html.ClipboardEvent e) {
    String clipb = e.clipboardData!
        .getData('text/html')
        .replaceAll(new RegExp(r'\s{2,}'), ' ')
        .replaceAll('\n', '');
    if (clipb.isEmpty) clipb = e.clipboardData!.getData('text/plain');
    final node = new html.DivElement()..innerHtml = clipb;
    final selection = html.window.getSelection();
    selection!.getRangeAt(0)
      ..deleteContents()
      ..insertNode(node);
    e.preventDefault();
  }

  void setStyleString(String style) {
    body.dom.children.removeWhere((element) => element.localName == 'style');
    body.prepend(new html.Element.tag('style')..text = style);
  }

  void setValue(String? value) {
    super.setValue(value);
    setValueDynamic(value);
  }

  void fullScreen(_) {
    if (_fullscreen) {
      removeClass('fullscreen');
      body.setHeight(new Dimension.px(_bHeight));
      _parentDom.append(this);
      _fullscreen = false;
    } else {
      setHeight(new Dimension.percent(100));
      _parentDom = new CLElement(dom.parentNode);
      addClass('fullscreen');
      new CLElement(html.document.body).append(dom);
      _fullscreen = true;
    }
  }

  void insertImage(html.Event e, String cmd) {
    frame.dom.focus();
    final range = html.window.getSelection()!.getRangeAt(0);
    new gui.FileManager(ap, 'media/upload').onDblClick.listen((thumb) {
      html.window.getSelection()!
        ..removeAllRanges()
        ..addRange(range);
      _exec(cmd, 'media/${thumb.file}');
    });
  }

  void insertUrl(html.Event e, String cmd) {
    frame.dom.focus();
    final range = html.window.getSelection()!.getRangeAt(0);
    final input = new Input();
    final cont = new Container()
      ..addClass('center')
      ..append(input);
    new app.Confirmer(ap, cont)
      ..title = 'URL'
      ..onOk = () {
        html.window.getSelection()!
          ..removeAllRanges()
          ..addRange(range);
        _exec(cmd, input.getValue());
      }
      ..render(width: 200, height: 200);
    input.focus();
  }

  void _exec(cmd, [value]) {
    frame.dom.ownerDocument!.execCommand(cmd, false, value);
    super.setValue(frame.dom.innerHtml);
  }

  void _getPath(e) {
    if (frame.dom.contentEditable == 'false') return;
    var cur = e.target;
    final arr = [];
    while (cur.contentEditable != 'true') {
      arr.add(cur.nodeName);
      cur = cur.parentNode;
    }
    path.dom.text = arr.reversed.join(' ');
  }

  void setValueDynamic(dynamic value) =>
      frame.dom.setInnerHtml(value == null ? '' : value.toString(),
          validator: _htmlValidator);

  void _resizeEditor() {
    fieldMirror
      ..setSize(0, 0) //Reset container size
      ..setSize(fieldContainer.getWidth(), fieldContainer.getHeight());
  }

  void _toggleSource(e) {
    if (frame.getStyle('display') == 'none') {
      new CLElement(frame.dom.parent).show();
      frame.show();
      setValueDynamic(getValue());
      fieldContainer.hide();
      path.show();
      menu.indexOfElements.forEach((b) => b.setState(true));
    } else {
      _createEditor().then((e) {
        fieldMirror.getDoc()?.setValue(getValue()!);
        new CLElement(frame.dom.parent).hide();
        frame.hide();
        fieldContainer.show();
        _resizeEditor();
        fieldMirror
          ..refresh()
          ..focus();
        path.hide();
        menu.initButtons([]);
        fieldMirror.onChange
            .listen((_) => setValue(fieldMirror.getDoc()?.getValue()));
      });
    }
  }

  void setPlaceHolder(String value) {}

  void focus() {
    frame.dom.focus();
  }

  void blur() {}

  void select() {}

  void disable() {
    state = false;
    addClass('disabled');
    frame.dom.contentEditable = 'false';
    menu.disable();
    sourceBtn?.disable();
  }

  void enable() {
    state = true;
    removeClass('disabled');
    frame.dom.contentEditable = 'true';
    menu.enable();
    sourceBtn?.enable();
  }
}
