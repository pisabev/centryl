import 'dart:async';
import 'dart:io';
//import 'dart:convert';

Future main() async {
  const pathToFolder = '/home/user/Downloads/material/'
      'material-design-icons-master';
  final dirs = new Directory(pathToFolder).listSync();
  for(final d in dirs) {
    if(d is Directory) {
      final dir = new Directory('${d.path}/svg/production');
      if(!dir.existsSync()) continue;
      final files = new Directory('${d.path}/svg/production').listSync();
      for(final f in files) {
        if(f is File && f.path.endsWith('24px.svg')) {
          print(f.path);
          f.copySync('tool/icons/${f.path.split('/')
              .last.replaceFirst('ic_', '').replaceFirst('_24px', '')}');
        }
      }
    }
  }
}