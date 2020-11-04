part of chart;

class Chart {
  CLElement container;
  num width = 0;
  num height = 0;
  SvgSvgElement svg;
  GElement graph, legend;
  int graph_count = 0;

  GElement label;
  AnimateTransformElement label_anim;
  AnimateElement label_anim_op;
  RectElement label_rect;
  TextElement label_text;
  String label_current = '0,0';
  num label_padding = 10;
  num label_offset = 10;

  num graphOffsetTop = 15;
  num graphOffsetBottom = 50;
  num graphOffsetLeft = 15;
  num graphOffsetRight = 70;
  num legend_o = 10;

  num crispOffset = 0.5;

  num graphStartX = 0;
  num graphStartY = 0;
  num graphEndX = 0;
  num graphEndY = 0;

  num graphWidth = 0;
  num graphHeight = 0;

  num minOffsetGridY = 60;
  num minOffsetGridX = 60;

  num gridCountY = 0;
  num gridCountX = 0;
  num gridOffsetY = 0;
  num gridOffsetX = 0;

  num highestY = 0;
  num gridRatioY = 1;
  num gridRatioX = 1;

  bool linesOnly = false;
  bool add_points;

  bool intData = true;

  List data = [];

  Chart(this.container) {
    reset();
  }

  void reset() {
    width = container.getWidthInner();
    height = container.getHeightInner();
    highestY = 0;
    graph_count = 0;
    container.removeChilds();
    svg = new SvgSvgElement()
      ..setAttribute('width', '$width')
      ..setAttribute('height', '$height')
      ..setAttribute('class', 'ui-chart-grid');
    container.append(svg);
    data = [];
  }

  void addData(List d, String title, [String clas]) {
    var highest = highestY;
    final set = (d.length == 1)
        ? [
            ['', 0],
            d[0],
            ['', 0]
          ]
        : d;
    for (var i = 0; i < set.length; i++) {
      if (set[i][1] == null) set[i][1] = 0;
      final cur = set[i][1];
      if (cur > highest) {
        highest = cur;
      }
      if (intData) intData = !cur.toString().contains('.');
    }
    data.add({'set': set, 'label': title, 'class': clas});
    highestY = highest;
  }

  void initGraph() {
    const labelY_length = 40;
    graphOffsetLeft = (labelY_length < 50) ? 50 : labelY_length;
    graphStartX = graphOffsetLeft + crispOffset;
    graphStartY = graphOffsetTop + crispOffset;
    graphEndX = width - graphOffsetRight + crispOffset;
    graphEndY = height - graphOffsetBottom + crispOffset;
    graphWidth = graphEndX - graphStartX;
    graphHeight = graphEndY - graphStartY;

    final group_transform = new GElement()
      ..setAttribute('transform', 'translate($graphStartX,$graphEndY)');
    final group_scale = new GElement()
      ..setAttribute('transform', 'scale(1, -1)');
    group_transform.append(group_scale);
    svg.append(group_transform);
    graph = group_scale;
    legend = new GElement()..setAttribute('class', 'legend');
    svg.append(legend);

    _calcGridYCountRatio();

    if (gridCountY > 0) gridOffsetY = graphHeight / gridCountY;
    _calcGridX();
  }

  void renderGrid() {
    final border = new RectElement()
      ..setAttribute('class', 'border')
      ..setAttribute('width', '$graphWidth')
      ..setAttribute('height', '$graphHeight');
    graph.append(border);
    for (var i = 0; i <= gridCountY; i++) {
      final y = (i * gridOffsetY).floor();
      final l = new LineElement()
        ..setAttribute('x1', '0')
        ..setAttribute('y1', '$y')
        ..setAttribute('x2', '$graphWidth')
        ..setAttribute('y2', '$y');
      graph.append(l);
      _createLabelY(i * gridRatioY, graphStartX, graphEndY - y);
    }
    for (var i = 0; i <= gridCountX; i++) {
      final x = (i * gridOffsetX).floor();
      final l = new LineElement()
        ..setAttribute('x1', '$x')
        ..setAttribute('y1', '0')
        ..setAttribute('x2', '$x')
        ..setAttribute('y2', '$graphHeight');
      graph.append(l);
      _createLabelX(
          data.first['set'][i * gridRatioX][0], graphStartX + x, graphEndY);
    }
  }

  void renderGraph() {
    data.forEach((set) {
      final data = set['set'];
      final label = set['label'];
      final clas = set['class'];
      _createLabel();
      graph_count++;
      final classname = clas ?? 'path$graph_count';
      final group = new GElement()..setAttribute('class', classname);

      final path = new PathElement();
      final sb = new StringBuffer();

      if (linesOnly)
        sb.write('M');
      else
        sb.write('M 0,0');

      final sb_anim_from = new StringBuffer();
      final anim = new AnimateElement();

      if (linesOnly)
        sb_anim_from.write('M');
      else
        sb_anim_from.write('M 0,0');

      final points = [];

      add_points ??= data.length * 6 < graphWidth;
      for (var i = 0; i < data.length; i++) {
        final y =
            (gridRatioY == 0) ? 0 : (data[i][1] / gridRatioY) * gridOffsetY;
        final x = i * (gridOffsetX / gridRatioX);
        sb.write(' $x,$y');
        sb_anim_from.write(' $x, 0');
        if (add_points)
          points.add(
              _createPoint('${data[i][0]} - ${data[i][1]}', classname, x, y));
      }
      if (!linesOnly) sb.write(' $graphWidth,0 z');
      path.setAttribute('d', sb.toString());

      if (!linesOnly) sb_anim_from.write(' $graphWidth,0 z');
      anim
        ..setAttribute('id', 'anim')
        ..setAttribute('attributeName', 'd')
        ..setAttribute('from', sb_anim_from.toString())
        ..setAttribute('to', sb.toString())
        ..setAttribute('dur', '0.8s');

      path.append(anim);
      if (linesOnly) path.classes.add('no-fill');

      group.append(path);
      points.forEach((point) => group.append(point as Node));

      _getLegend(label, classname, graphWidth + graphOffsetLeft + legend_o,
          graph_count - 1);

      graph.append(group);
    });
  }

  void redraw() {
    width = container.getWidthInner();
    height = container.getHeightInner();
    graph_count = 0;
    container.removeChilds();
    svg = new SvgSvgElement()
      ..setAttribute('width', '$width')
      ..setAttribute('height', '$height')
      ..setAttribute('class', 'ui-chart-grid');
    container.append(svg);
    if (data.isNotEmpty) {
      initGraph();
      renderGrid();
    }
    renderGraph();
  }

  void _calcGridYCountRatio() {
    if (highestY > 0) {
      gridCountY = (graphHeight / minOffsetGridY).ceil();
      num step = highestY / gridCountY;
      if (intData) step = step.ceil();
      final digits = (log(step) / log(10)).ceil();
      final division = pow(10, digits - 1);
      final roundup =
          ((step / division).ceil() > 0) ? (step / division).ceil() : 0;
      gridRatioY = roundup * division;
    } else {
      gridCountY = 0;
      gridRatioY = 0;
    }
  }

  void _calcGridX() {
    var gridCountX = data.first['set'].length - 1;
    gridCountX = (gridCountX >= 1) ? gridCountX : 1;
    var gridRatioX = 1;
    while ((graphWidth / (gridCountX / gridRatioX)) / minOffsetGridX < 1) {
      gridRatioX += 1;
    }
    this.gridRatioX = gridRatioX;
    this.gridCountX = gridCountX / gridRatioX;
    gridOffsetX = graphWidth / this.gridCountX;
  }

  void _createLabelY(num value, x, y) {
    if (!intData) value = num.tryParse(value.toStringAsFixed(2));
    final label = new TextElement()
      ..setAttribute('x', '${x - 5}')
      ..setAttribute('y', '$y')
      ..setAttribute('text-anchor', 'end')
      ..text = '$value';
    legend.append(label);
  }

  void _createLabelX(value, x, y) {
    final arr = value.split(' ');
    if (arr.length == 2) {
      var label = new TextElement()
        ..setAttribute('x', '$x')
        ..setAttribute('y', '${y + 15}')
        ..text = '${arr[0]}';
      legend.append(label);
      label = new TextElement()
        ..setAttribute('x', '$x')
        ..setAttribute('y', '${y + 28}')
        ..text = '${arr[1]}';
      legend.append(label);
    } else if (arr.length == 3) {
      var label = new TextElement()
        ..setAttribute('x', '$x')
        ..setAttribute('y', '${y + 15}')
        ..text = '${arr[0]} ${arr[1]}';
      legend.append(label);
      label = new TextElement()
        ..setAttribute('x', '$x')
        ..setAttribute('y', '${y + 28}')
        ..text = '${arr[2]}';
      legend.append(label);
    } else {
      final label = new TextElement()
        ..setAttribute('x', '$x')
        ..setAttribute('y', '${y + 15}')
        ..text = '$value';
      legend.append(label);
    }
  }

  void _createLabel() {
    label = new GElement()..setAttribute('transform', 'translate(0,0)');
    label_anim = new AnimateTransformElement()
      ..setAttribute('attributeName', 'transform')
      ..setAttribute('type', 'translate')
      ..setAttribute('dur', '0.2s');
    label_anim_op = new AnimateElement()
      ..setAttribute('attributeName', 'opacity')
      ..setAttribute('dur', '0.5s');
    label.style.visibility = 'hidden';
    label_rect = new RectElement()
      ..setAttribute('rx', '5')
      ..setAttribute('ry', '5');
    label_text = new TextElement()..setAttribute('class', 'label');
    label
      ..append(label_anim)
      ..append(label_anim_op)
      ..append(label_rect)
      ..append(label_text);
    legend.append(label);
  }

  void _labelShow(value, String classname, x, y) {
    label.style.visibility = '';
    label_text.text = '$value';
    final box = label_text.getBBox();
    final rect_width = box.width + label_padding * 2;
    final rect_height = box.height + label_padding * 2;
    label_rect
      ..setAttribute('width', '$rect_width')
      ..setAttribute('height', '$rect_height');
    label_text
      ..setAttribute('x', '$label_padding')
      ..setAttribute('y', '${box.height + label_padding - 3}');

    var offset_x = label_offset;
    if (x + label_offset + rect_width > graphEndX)
      offset_x = (offset_x + rect_width) * -1;
    var offset_y = (rect_height + label_offset) * -1;
    if (y - label_offset - rect_height < graphStartY)
      offset_y = (offset_y + rect_height) * -1;

    label_anim.setAttribute('from', '$label_current');
    label_current = '${x + offset_x},${y + offset_y}';
    label_anim
      ..setAttribute('to', '$label_current')
      ..beginElement();
    label_anim_op
      ..setAttribute('from', '0')
      ..setAttribute('to', '1')
      ..beginElement();
    label
      ..setAttribute('class', classname)
      ..setAttribute('transform', 'translate($label_current)');
  }

  void _labelHide(e) {
    label.style.visibility = 'hidden';
  }

  CircleElement _createPoint(
      dynamic value, String classname, dynamic x, dynamic y) {
    final circle = new CircleElement()
          ..setAttribute('cx', '$x')
          ..setAttribute('cy', '$y')
          ..onMouseOver.listen((e) =>
              _labelShow(value, classname, x + graphStartX, graphEndY - y))
          ..onMouseOut.listen(_labelHide),
        anim1 = new AnimateElement()
          ..setAttribute('attributeName', 'r')
          ..setAttribute('from', '0')
          ..setAttribute('to', '3')
          ..setAttribute('fill', 'freeze')
          ..setAttribute('dur', '0.2s')
          ..setAttribute('begin', 'anim.end'),
        anim2 = new AnimateElement()
          ..setAttribute('attributeName', 'r')
          ..setAttribute('from', '3')
          ..setAttribute('to', '5')
          ..setAttribute('fill', 'freeze')
          ..setAttribute('dur', '0.2s')
          ..setAttribute('begin', 'mouseover'),
        anim3 = new AnimateElement()
          ..setAttribute('attributeName', 'r')
          ..setAttribute('from', '5')
          ..setAttribute('to', '3')
          ..setAttribute('fill', 'freeze')
          ..setAttribute('dur', '0.2s')
          ..setAttribute('begin', 'mouseout');

    circle..append(anim1)..append(anim2)..append(anim3);
    return circle;
  }

  void _getLegend(dynamic value, String classname, x, num n) {
    final group = new GElement()..setAttribute('class', 'legend $classname'),
        rect = new RectElement(),
        text = new TextElement();

    group
      ..append(rect)
      ..append(text)
      ..setAttribute('transform', 'translate($x, ${n * 30 + graphOffsetTop})');
    //..onMouseOver.listen((e) =>_animateSegment(num, '1', '0.2'))
    //..onMouseOut.listen((e) => _animateSegment(num, '0.2', '1'));

    rect..setAttribute('width', '20')..setAttribute('height', '20');

    text
      ..setAttribute('x', '25')
      ..setAttribute('y', '14')
      ..text = value;

    svg.append(group);
  }
}
