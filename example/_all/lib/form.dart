part of test.cl.layout;

cl_gui.FormElement getForm(cl_form.Form f) =>
  new cl_gui.FormElement(f)
    ..addRow('Row1', [new cl_form.Input()..setName('key1')])
    ..addRow('Row2', [new cl_form.Input()..setName('key2')])
    ..addRow('Row3', [new cl_form.Input()..setName('key3')]);

cl_gui.FormElement getForm2(cl_form.Form f) =>
  new cl_gui.FormElement(f)
    ..addRow('Row1', [new cl_form.Input()..setName('key1')])
    ..addRow('Row2', [new cl_form.Input()..setName('key2')])
    ..addRow('Row3 Lorem ipsum long title very very long', [
    'some', new cl_form.Check(), new cl_form.Input()
      ..setName('key3'), 'some', new cl_form.Input()..setName('key4')])
    ..addRow('Row4', [new cl_gui.LabelField('label 1', [new cl_form.Input()
      ..setName('lbl1')]),
      new cl_gui.LabelField('label 2', [new cl_form.Input()..setSuffix('suffix')
        ..setName('lbl2')
        ..addClass('max')])]);

cl_form.GridData getGrid() => new cl_form.GridData()
    ..initGridHeader([
      new cl_form.GridColumn('key1')
        ..title = 'First',
      new cl_form.GridColumn('key2')
        ..title = 'Second #',
      new cl_form.GridColumn('key3')
        ..title = 'Third',
      new cl_form.GridColumn('key4')
        ..title = 'Fourth',
      new cl_form.GridColumn('del')
        ..title = ''
        ..send = false])
    ..addHookRow((tr, obj) {
      obj['key1'] = new cl_form.Input()..setValue(obj['key1']);
      obj['key2'] = new cl_form.Input()..setValue(obj['key2']);
      obj['key3'] = new cl_form.Input()..setValue(obj['key3']);
    })
    ..show();

cl_form.GridList getGridList() => new cl_form.GridList()
    ..initGridHeader([
      new cl_form.GridColumn('key1')
        ..title = 'First'
        ..filter = new cl_form.Input(),
      new cl_form.GridColumn('key2')
        ..title = 'Second sdsds sadadsa dsad sadsadsa dsadsadsadsa dsadsadsad#'
        ..sortable = true
        ..width = '400px'
        ..filter = (new cl_form.Select()
          ..addOption(0, 'First')
          ..addOption(1, 'Second')
          ..addOption(2, 'Third')
          ..addOption(3, 'Forth')),
      new cl_form.GridColumn('key3')
        ..title = 'Third'
        ..filter = new cl_form.InputDateRange()
        ..width = '400px',
      new cl_form.GridColumn('key4')
        ..title = 'Fourth row'
        ..filter = new cl_form.InputLoader(),
      new cl_form.GridColumn('del')
        ..title = ''
        ..send = false])
    ..addHookRow((row, obj) {
      obj['key4'] = new cl_form.Input()..setValue(obj['key4']);
      obj['del'] = new cl_action.Button()..setIcon('delete');
    });

cl_gui.TreeBuilder getTree() {
  final tree = new cl_gui.TreeBuilder(
      node: new cl_gui.TreeNode(value: '[ Tree ]', id: 'item'),
      icons: {
        'product': 'folder'
      });
  return tree;
}
