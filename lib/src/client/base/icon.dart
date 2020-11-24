part of base;

class Icon {
  static const String spr = 'packages/centryl/images/icons-sprite.svg';

  static const String error = '$spr#error';
  static const String arrow_drop_down = '$spr#arrow_drop_down';
  static const String arrow_drop_up = '$spr#arrow_drop_up';
  static const String warning = '$spr#warning';
  static const String today = '$spr#today';
  static const String search = '$spr#search';
  static const String send = '$spr#send';
  static const String assignment = '$spr#assignment';
  static const String priority_high = '$spr#priority_high';
  static const String receipt = '$spr#receipt';
  static const String attach_file = '$spr#attach_file';
  static const String barcode = '$spr#barcode';
  static const String block = '$spr#block';
  static const String call = '$spr#call';
  static const String call_end = '$spr#call_end';
  static const String date_range = '$spr#date_range';
  static const String keyboard_arrow_down = '$spr#keyboard_arrow_down';
  static const String first_page = '$spr#first_page';
  static const String last_page = '$spr#last_page';
  static const String lock = '$spr#lock';
  static const String lock_open = '$spr#lock_open';
  static const String lock_outline = '$spr#lock_outline';
  static const String folder = '$spr#folder';
  static const String check = '$spr#check';
  static const String chevron_right = '$spr#chevron_right';
  static const String chevron_left = '$spr#chevron_left';
  static const String exit_to_app = '$spr#exit_to_app';
  static const String file_download = '$spr#file_download';
  static const String file_upload = '$spr#file_upload';
  static const String file_archive = '$spr#file_archive';
  static const String file_excel = '$spr#file_excel';
  static const String file_image = '$spr#file_image';
  static const String file_pdf = '$spr#file_pdf';
  static const String file_unknown = '$spr#file_unknown';
  static const String file_word = '$spr#file_word';
  static const String schedule = '$spr#schedule';
  static const String settings = '$spr#settings';
  static const String person = '$spr#person';
  static const String notifications = '$spr#notifications';
  static const String fullscreen = '$spr#fullscreen';
  static const String group = '$spr#group';
  static const String undo = '$spr#undo';
  static const String redo = '$spr#redo';
  static const String format_bold = '$spr#format_bold';
  static const String format_italic = '$spr#format_italic';
  static const String format_underlined = '$spr#format_underlined';
  static const String format_strikethrough = '$spr#format_strikethrough';
  static const String format_list_numbered = '$spr#format_list_numbered';
  static const String format_list_bulleted = '$spr#format_list_bulleted';
  static const String format_indent_decrease = '$spr#format_indent_decrease';
  static const String format_indent_increase = '$spr#format_indent_increase';
  static const String format_align_left = '$spr#format_align_left';
  static const String format_align_center = '$spr#format_align_center';
  static const String format_align_right = '$spr#format_align_right';
  static const String format_align_justify = '$spr#format_align_justify';
  static const String image = '$spr#image';
  static const String info_outline = '$spr#info_outline';
  static const String insert_link = '$spr#insert_link';
  static const String format_clear = '$spr#format_clear';
  static const String print = '$spr#print';
  static const String code = '$spr#code';
  static const String content_copy = '$spr#content_copy';
  static const String save = '$spr#save';
  static const String delete = '$spr#delete';
  static const String developer_board = '$spr#developer_board';
  static const String device_hub = '$spr#device_hub';
  static const String edit = '$spr#edit';
  static const String emoticon = '$spr#emoticon';
  static const String filter_list = '$spr#filter_list';
  static const String clear = '$spr#clear';
  static const String sync = '$spr#sync';
  static const String add = '$spr#add';
  static const String mail = '$spr#mail';
  static const String menu = '$spr#menu';
  static const String videocam = '$spr#videocam';
  static const String videocam_off = '$spr#videocam_off';
  static const String message = '$spr#message';
  static const String mic = '$spr#mic';
  static const String mic_off = '$spr#mic_off';
  static const String visibility = '$spr#visibility';
  static const String mode_comment = '$spr#mode_comment';
  static const String more_horiz = '$spr#more_horiz';
  static const String more_vert = '$spr#more_vert';
  static const String zoom_in = '$spr#zoom_in';
  static const String zoom_out = '$spr#zoom_out';

  static String BASEURL;
  static String ICON_FLAG_PATH;

  String id;
  Element dom;

  Icon(this.id) {
    createDom();
  }

  void createDom() {
    dom = new Element.tag('i')..classes.add('icon');
    final s = new svg.SvgSvgElement();
    if (id.isNotEmpty) s.classes.add(id.split('#').last);
    final use = new svg.UseElement()
      ..setAttributeNS('http://www.w3.org/1999/xlink', 'href', '$BASEURL$id');
    s.append(use);
    dom.append(s);
  }
}
