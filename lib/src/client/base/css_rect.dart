part of base;

const _height = ['top', 'bottom'];
const _width = ['right', 'left'];
const _content = 'content';
const _padding = 'padding';
const _margin = 'margin';

class Dimension {
  late num _value;
  late String _unit;

  /// Set this CSS Dimension to a percentage `value`.
  Dimension.percent(this._value) : _unit = '%';

  /// Set this CSS Dimension to a pixel `value`.
  Dimension.px(this._value) : _unit = 'px';

  /// Set this CSS Dimension to a pica `value`.
  Dimension.pc(this._value) : _unit = 'pc';

  /// Set this CSS Dimension to a point `value`.
  Dimension.pt(this._value) : _unit = 'pt';

  /// Set this CSS Dimension to an inch `value`.
  Dimension.inch(this._value) : _unit = 'in';

  /// Set this CSS Dimension to a centimeter `value`.
  Dimension.cm(this._value) : _unit = 'cm';

  /// Set this CSS Dimension to a millimeter `value`.
  Dimension.mm(this._value) : _unit = 'mm';

  /// Set this CSS Dimension to the specified number of ems.
  ///
  /// 1em is equal to the current font size. (So 2ems is equal to num the
  /// font size). This is useful for producing website layouts that scale
  /// nicely with the user's desired font size.
  Dimension.em(this._value) : _unit = 'em';

  Dimension.rem(this._value) : _unit = 'rem';

  /// Set this CSS Dimension to the specified number of x-heights.
  ///
  /// One ex is equal to the x-height of a font's baseline to its mean line,
  /// generally the height of the letter "x" in the font, which is usually about
  /// half the font-size.
  Dimension.ex(this._value) : _unit = 'ex';

  /// Construct a Dimension object from the valid, simple CSS string `cssValue`
  /// that represents a distance measurement.
  ///
  /// This constructor is intended as a convenience method for working with
  /// simplistic CSS length measurements. Non-numeric values such as `auto` or
  /// `inherit` or invalid CSS will cause this constructor to throw a
  /// FormatError.
  Dimension.css(String cssValue) {
    if (cssValue == '') cssValue = '0px';
    if (cssValue.endsWith('%')) {
      _unit = '%';
    } else {
      _unit = cssValue.substring(cssValue.length - 2);
    }
    if (cssValue.contains('.')) {
      _value =
          double.parse(cssValue.substring(0, cssValue.length - _unit.length));
    } else {
      _value = int.parse(cssValue.substring(0, cssValue.length - _unit.length));
    }
  }

  /// Print out the CSS String representation of this value.
  String toString() => '$_value$_unit';

  /// Return a unitless, numerical value of this CSS value.
  num get value => _value;
}

abstract class CssRectExt extends CssRect {
  final Element _element;

  CssRectExt(this._element) : super(_element);

  num _addOrSubtractToBoxModel(
      List<String> dimensions, String augmentingMeasurement) {
    // getComputedStyle always returns pixel values (hence, computed), so we're
    // always dealing with pixels in this method.
    final styles = _element.getComputedStyle();

    num val = 0;

    for (final measurement in dimensions) {
      // The border-box and default box model both exclude margin in the regular
      // height/width calculation, so add it if we want it for this measurement.
      if (augmentingMeasurement == _margin) {
        val += new Dimension.css(
                styles.getPropertyValue('$augmentingMeasurement-$measurement'))
            .value;
      }

      // The border-box includes padding and border, so remove it if we want
      // just the content itself.
      if (augmentingMeasurement == _content) {
        val -=
            new Dimension.css(styles.getPropertyValue('$_padding-$measurement'))
                .value;
      }

      // At this point, we don't wan't to augment with border or margin,
      // so remove border.
      if (augmentingMeasurement != _margin) {
        val -= new Dimension.css(
                styles.getPropertyValue('border-$measurement-width'))
            .value;
      }
    }
    return val;
  }
}

class _ContentCssRect extends CssRectExt {
  _ContentCssRect(Element element) : super(element);

  num get height =>
      _element.getBoundingClientRect().height +
      _addOrSubtractToBoxModel(_height, _content);

  num get width =>
      _element.getBoundingClientRect().width +
      _addOrSubtractToBoxModel(_width, _content);

  /// Set the height to `newHeight`.
  ///
  /// newHeight can be either a [num] representing the height in pixels or a
  /// [Dimension] object. Values of newHeight that are less than zero are
  /// converted to effectively setting the height to 0. This is equivalent to
  /// the `height` function in jQuery and the calculated `height` CSS value,
  /// converted to a num in pixels.
  ///
  set height(dynamic newHeight) {
    if (newHeight is Dimension) {
      if (newHeight.value < 0) newHeight = new Dimension.px(0);
      _element.style.height = newHeight.toString();
    } else if (newHeight is num) {
      if (newHeight < 0) newHeight = 0;
      _element.style.height = '${newHeight}px';
    } else {
      throw new ArgumentError('newHeight is not a Dimension or num');
    }
  }

  /// Set the current computed width in pixels of this element.
  ///
  /// newWidth can be either a [num] representing the width in pixels or a
  /// [Dimension] object. This is equivalent to the `width` function in jQuery
  /// and the calculated
  /// `width` CSS value, converted to a dimensionless num in pixels.

  set width(dynamic newWidth) {
    if (newWidth is Dimension) {
      if (newWidth.value < 0) newWidth = new Dimension.px(0);
      _element.style.width = newWidth.toString();
    } else if (newWidth is num) {
      if (newWidth < 0) newWidth = 0;
      _element.style.width = '${newWidth}px';
    } else {
      throw new ArgumentError('newWidth is not a Dimension or num');
    }
  }

  num get left =>
      _element.getBoundingClientRect().left -
      _addOrSubtractToBoxModel(['left'], _content);

  num get top =>
      _element.getBoundingClientRect().top -
      _addOrSubtractToBoxModel(['top'], _content);
}

class _PaddingCssRect extends CssRectExt {
  _PaddingCssRect(element) : super(element);

  num get height =>
      _element.getBoundingClientRect().height +
      _addOrSubtractToBoxModel(_height, _padding);

  num get width =>
      _element.getBoundingClientRect().width +
      _addOrSubtractToBoxModel(_width, _padding);

  num get left =>
      _element.getBoundingClientRect().left -
      _addOrSubtractToBoxModel(['left'], _padding);

  num get top =>
      _element.getBoundingClientRect().top -
      _addOrSubtractToBoxModel(['top'], _padding);
}

class _BorderCssRect extends CssRectExt {
  _BorderCssRect(element) : super(element);

  num get height => _element.getBoundingClientRect().height;

  num get width => _element.getBoundingClientRect().width;

  num get left => _element.getBoundingClientRect().left;

  num get top => _element.getBoundingClientRect().top;
}

class _MarginCssRect extends CssRectExt {
  _MarginCssRect(_element) : super(_element);

  num get height =>
      _element.getBoundingClientRect().height +
      _addOrSubtractToBoxModel(_height, _margin);

  num get width =>
      _element.getBoundingClientRect().width +
      _addOrSubtractToBoxModel(_width, _margin);

  num get left =>
      _element.getBoundingClientRect().left -
      _addOrSubtractToBoxModel(['left'], _margin);

  num get top =>
      _element.getBoundingClientRect().top -
      _addOrSubtractToBoxModel(['top'], _margin);
}
