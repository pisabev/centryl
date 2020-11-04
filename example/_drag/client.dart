library application;

import 'dart:html';
import 'package:centryl/base.dart';
import 'package:centryl/utils.dart' as utils;

void main() {
  //simple();
  //context();
  bound();
}

/*
 * Simple dragging
 */

void simple() {
  final element = new CLElement(new DivElement())
    ..addClass('element')
    ..appendTo(document.body);

  utils.Drag drag;
  drag = new utils.Drag(element)
    ..on((e) {
      element.setRectangle(drag.rect);
    });
}

/*
 * Dragging object by applying dragged context;
 */
void context() {
  final context = new CLElement(new DivElement())
    ..addClass('context')
    ..appendTo(document.body);
  final element = new CLElement(new DivElement())
    ..addClass('element')
    ..appendTo(context);

  utils.Drag drag;
  drag = new utils.Drag(element)
    ..context = context
    ..on((e) {
      context.setRectangle(drag.rect);
    });
}

/*
 * Dragging object inside bounding box;
 */

void bound() {
  final bound = new CLElement(new DivElement())
    ..addClass('bound')
    ..appendTo(document.body);
  final element = new CLElement(new DivElement())
    ..addClass('element')
    ..appendTo(bound);
  utils.Drag drag;
  drag = new utils.Drag(element)
    ..bound = bound
    ..on((e) {
      element.setRectangle(drag.rect);
    });
}
