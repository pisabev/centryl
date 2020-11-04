part of chart;

class Bar {
  CLElement container;
  num width = 0;
  num height = 0;
  SvgSvgElement svg;
  GElement graph, legend;

  num bar_height = 0;
  num bar_offset = 0;
  num graphOffsetTop = 10;
  num graphOffsetBottom = 20;
  num graphOffsetLeft = 10;
  num graphOffsetRight = 70;

  num crispOffset = 0.5;

  num graphStartX = 0;
  num graphStartY = 0;
  num graphEndX = 0;
  num graphEndY = 0;

  num graphWidth = 0;
  num graphHeight = 0;

  int minOffsetGridY = 60;
  int minOffsetGridX = 60;

  num gridCountX = 0;
  num gridOffsetX = 0;

  num letter_height = 15;
  num letter_width = 10;
  num longestLabel = 0;
  num highestX = 0;
  num gridRatioX = 1;

  List data = [];
  Map label_map = {};

  Bar(this.container) {
    reset();
  }

  void reset() {
    width = container.getWidthInner();
    height = container.getHeightInner();
    highestX = 0;
    container.removeChilds();
    svg = new SvgSvgElement()
      ..setAttribute('width', '$width')
      ..setAttribute('height', '$height')
      ..setAttribute('class', 'ui-chart-bar');
    container.append(svg);
    data = [];
  }

  void setData(List d) {
    data = d;
  }

  void initGraph() {
    graphEndY = height - graphOffsetBottom + crispOffset;
    graphEndX = width - graphOffsetRight + crispOffset;
    graphStartY = graphOffsetTop + crispOffset;
    graphHeight = graphEndY - graphStartY;

    final r = graphHeight / data.length;
    bar_height = r * 2 / 3;
    bar_offset = r * 1 / 3;

    var highest = highestX;
    var longest = longestLabel;
    for (var i = 0; i < data.length; i++) {
      if (data[i][1] == null) data[i][1] = 0;
      final cur = data[i][1];
      if (cur > highest) highest = cur;

      _calcTextParts(data[i][0]).forEach((part) {
        if (part.length > longest) longest = part.length;
      });
    }
    highestX = highest;
    longestLabel = longest;

    graphOffsetLeft = longestLabel * letter_width;
    graphStartX = graphOffsetLeft + crispOffset;
    graphWidth = graphEndX - graphStartX;

    final group_transform = new GElement()
      ..setAttribute('transform', 'translate($graphStartX,$graphStartY)');
    svg.append(group_transform);
    graph = group_transform;
    legend = new GElement()..setAttribute('class', 'legend');
    svg.append(legend);

    _calcGridXCountRatio();

    if (gridCountX > 0) gridOffsetX = graphWidth / gridCountX;
  }

  List<String> _calcTextParts(String label) {
    List<String> text_parts =
        (label != null && label.isNotEmpty) ? label.split(' ') : [];
    final text_parts_orig = new List.from(text_parts);

    var text_rows = (bar_height / letter_height).floor();
    text_rows = text_rows < 1 ? 1 : text_rows;

    var p = 2;
    while (text_parts.length > text_rows) {
      final temp = <String>[];
      for (var i = 0; i < text_parts_orig.length; i += p)
        temp.add(text_parts_orig
            .sublist(i, math.min(i + p, text_parts_orig.length))
            .join(' '));
      p++;
      text_parts = temp;
    }
    label_map[label] = text_parts;
    return text_parts;
  }

  void renderGrid() {
    for (var i = 0; i < data.length; i++) {
      final y = i * (bar_height + bar_offset);
      _createLabelY(data[i][0], graphStartX, graphStartY + y + 10);
    }
    for (var i = 0; i <= gridCountX; i++) {
      final x = (i * gridOffsetX).floor();
      final l = new LineElement()
        ..setAttribute('x1', '$x')
        ..setAttribute('y1', '0')
        ..setAttribute('x2', '$x')
        ..setAttribute('y2', '$graphHeight');
      graph.append(l);
      _createLabelX(i * gridRatioX, graphStartX + x, graphEndY);
    }
  }

  void renderGraph() {
    final group = new GElement();
    for (var i = 0; i < data.length; i++) {
      final width = (data[i][1] / gridRatioX) * gridOffsetX;
      final rect = new RectElement()
        ..setAttribute('class', 'rect${i + 1}')
        ..setAttribute('y', '${i * (bar_height + bar_offset)}')
        ..setAttribute('x', '0')
        ..setAttribute('width', '$width')
        ..setAttribute('height', '$bar_height');
      final anim = new AnimateElement()
        ..setAttribute('id', 'anim')
        ..setAttribute('attributeName', 'width')
        ..setAttribute('from', '0')
        ..setAttribute('to', '$width')
        ..setAttribute('dur', '0.2s');
      rect.append(anim);
      group.append(rect);
    }
    graph.append(group);
  }

  void redraw() {
    width = container.getWidthInner();
    height = container.getHeightInner();
    container.removeChilds();
    svg = new SvgSvgElement()
      ..setAttribute('width', '$width')
      ..setAttribute('height', '$height')
      ..setAttribute('class', 'ui-chart-bar');
    container.append(svg);
    if (data.isNotEmpty) {
      initGraph();
      renderGrid();
      renderGraph();
    }
  }

  void _calcGridXCountRatio() {
    if (highestX > 0) {
      gridCountX = (graphWidth / minOffsetGridX).ceil();
      num step = highestX / gridCountX;
      if (highestX >= 1 && step < 1) {
        step = 1;
        gridCountX = highestX;
      }
      final digits = (log(step) / log(10)).ceil();
      final division = pow(10, digits - 1);
      final roundup =
          ((step / division).ceil() > 0) ? (step / division).ceil() : 0;
      gridRatioX = roundup * division;
    } else {
      gridCountX = 0;
      gridRatioX = 0;
    }
  }

  void _createLabelY(value, x, y) {
    var i = 0;
    label_map[value].forEach((part) {
      final label = new TextElement()
        ..setAttribute('x', '${x - 5}')
        ..setAttribute('y', '${y + letter_height * i++}')
        ..setAttribute('text-anchor', 'end')
        ..text = '$part';
      legend.append(label);
    });
  }

  void _createLabelX(value, x, y) {
    final label = new TextElement()
      ..setAttribute('x', '$x')
      ..setAttribute('y', '${y + letter_height}')
      ..text = '${value.toInt()}';
    legend.append(label);
  }
}
