part of test.cl.layout;

class Ap1 extends cl_app.Item {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Layout win 1'
    ..icon = Icon.assignment
    ..width = 1000
    ..height = 800;

  Ap1(this.ap) {
    wapi = new cl_app.WinApp(ap)..load(meta, this);

    final c = new layout.LayoutContainer1();
    final menu = new cl_action.Menu(c.contMenu);

    final form = new cl_form.Form();

    menu
      ..add(new cl_action.Button()
        ..setTitle('Save')
        ..addClass('important')
        ..addAction((e) {
          print(form.getValue());
        }))
      ..add(new cl_action.Button()..setTitle('Print'))
      ..add(new cl_action.Button()
        ..setTitle('Delete')
        ..addClass('warning'));

    // Create the forms
    final f1 = new cl_form.Form()..setName('f1');
    final f2 = new cl_form.Form()..setName('f2');
    form..add(f1)..add(f2);
    final f1el = getForm(f1);
//    var f2el = getForm(f2);

    // Append to layout
    final t1 = c.contBottom.createTab(null)..append(f1el, scrollable: true);
    //var t2 = c.contBottom.createTab('Second');
    //t2.append(f2, scrollable: true);

    c.contBottom.activeTab(t1);

    final Map m = {
      'f1': {'key1': 'Value1', 'key2': 'Value2', 'key3': 'Value3'},
      'f2': {'key1': null, 'key2': null, 'key3': null},
    };

    form.setValue(m);

    wapi!.win.getContent().append(c, scrollable: true);
    wapi!.render();
    wapi!.win.addKeyAction(new util.KeyAction(util.KeyAction.ALT_S, () {
      print('Laytout 1 ALT+S');
    }));
  }
}

class Ap2 extends cl_app.Item {
  cl_app.Application ap;

  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Layout 1'
    ..icon = Icon.assignment
    ..width = 1000
    ..height = 800;

  Ap2(this.ap) {
    wapi = new cl_app.WinApp(ap)..load(meta, this);

    final c = new layout.LayoutContainer2();
    final menu = new cl_action.Menu(c.contMenu);

    final form = new cl_form.Form();

    menu
      ..add(new cl_action.Button()
        ..setTitle('Save')
        ..addClass('important')
        ..addAction((e) {
          print(form.getValue());
        }))
      ..add(new cl_action.Button()..setTitle('Print'))
      ..add(new cl_action.Button()
        ..setTitle('Delete')
        ..addClass('warning'));

    // Create the forms
    final f1 = new cl_form.Form()..setName('f1');
    final f2 = new cl_form.Form()..setName('f2');
    final f3 = new cl_form.Form()..setName('f3');
    final grd = getGrid()..setName('grd');
    form..add(f1)..add(f2)..add(f3)..add(grd);

    final f1el = getForm(f1);
    final f2el = getForm(f2);
    final f3el = getForm2(f3);

    // Append to layout
    c..contTopLeft.append(f1el)..contTopRight.append(f2el);

    final t1 = c.contBottom.createTab('First');
    final t2 = c.contBottom.createTab('Second');
    c.contBottom.activeTab(t2);
    t1.append(f3el, scrollable: true);
    t2.append(grd, scrollable: true);

    final m = <String, dynamic>{
      'f1': <String, dynamic>{
        'key1': 'Value1',
        'key2': 'Value2',
        'key3': 'Value3'
      },
      'f2': <String, dynamic>{'key1': null, 'key2': null, 'key3': null},
      'f3': <String, dynamic>{
        'key1': 'vvv2',
        'key2': null,
        'key3': null,
        'key4': null,
        'lbl1': null,
        'lbl2': null
      },
      'grd': [
        <String, dynamic>{'key1': 'dddd'}
      ]
    };

    for (int i = 0; i < 100; i++) {
      m['grd'].add(<String, dynamic>{'key1': 'dd$i'});
    }

    form.setValue(m);

    wapi!.win.getContent().append(c, scrollable: true);
    wapi!.render();
  }
}

class Ap3 extends cl_app.Item {
  cl_app.Application ap;

  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Layout 1'
    ..icon = Icon.assignment
    ..width = 1000
    ..height = 800;

  Ap3(this.ap) {
    wapi = new cl_app.WinApp(ap)..load(meta, this);

    final c = new layout.LayoutContainer3();
    new cl_action.Menu(c.contMenu).add(new cl_action.Button()..setTitle('Add'));

    final gridList = getGridList();
    // Create Container
    final gridListContainer =
        new cl_form.GridListContainer(gridList, auto: true);
    // Append the container to other container with auto setup
    c.contMiddle.addRow(gridListContainer..auto = true);

    final List<Map> l = [];
    for (int i = 0; i < 50; i++) {
      if (i < 30)
        l.add(<String, dynamic>{
          'key1': 'dd$i',
          'key2': 'Sadasdsad sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa'
              ' dsadsadsad dasdads adksad kjsandkjsan dkjnsa dkjnsa  sadsadsadsa '
              'dsadsadsad das dads adksad kjsandkjsan dkjnsa dkjnsa jdnsakdn kjsa'
              'ndkjsand kjsand kjsandsa',
          'key3': null,
          'key4': 'asd'
        });
      else
        l.add(<String, dynamic>{
          'key1': 'dd$i',
          'key2': 'Sdas dads adksad',
          'key3': null,
          'key4': 'asd'
        });
    }

    gridList.renderIt(l);
    new cl_action.Menu(c.contBottom).add(new cl_form.Paginator());

    wapi!.win.getContent().append(c, scrollable: true);
    wapi!.render();
  }
}

class Ap4 extends cl_app.Item {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Layout 1'
    ..icon = Icon.assignment
    ..width = 1000
    ..height = 800;

  Ap4(this.ap) {
    wapi = new cl_app.WinApp(ap)..load(meta, this);

    final c = new layout.LayoutContainer4();

    final cl_gui.TreeBuilder tree = getTree();
    final List<Map> d = [];
    for (int i = 0; i < 100; i++) {
      final l = i == 2;
      d.add({
        'parentId': 'item',
        'id': '$i',
        'value': 'Sub $i',
        'type': 'product',
        'hasChilds': l
      });
    }

    d
      ..add({
        'parentId': '2',
        'id': '2sss',
        'value': 'Sub Sub 2 asdsadsadsad sadsad',
        'type': 'product',
        'hasChilds': false
      })
      ..add({
        'parentId': '2sss',
        'id': '2sssf',
        'value': 'Sub Sub 24sdasdasdsa',
        'type': 'product',
        'hasChilds': false
      })
      ..add({
        'parentId': '2',
        'id': '2sdsdsd',
        'value': 'Sub Sub 24sdasdasdsa',
        'type': 'product',
        'hasChilds': false
      });

    c.contLeft.append(tree, scrollable: true);
    tree.renderTree(tree.main!, d);

    wapi!.win.getContent().append(c, scrollable: true);
    wapi!.render();
  }
}
