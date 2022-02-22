import 'dart:convert';

import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pp;

class FM {
  List<dynamic> files;

  FM(this.files);

  FM.fromJson(Map<String, dynamic> json) : files = json['files'];

  static Future<FM> load() async {
    if (kIsWeb) {
      return FM([]);
    }

    final fs = LocalFileSystem();
    final dir = await pp.getApplicationSupportDirectory();
    final file = fs.directory(dir.path).childFile('files.json');
    if (await file.exists()) {
      final json = await file.readAsString();
      final data = jsonDecode(json) as Map<String, dynamic>;
      return FM.fromJson(data);
    }
    return FM([]);
  }
}
