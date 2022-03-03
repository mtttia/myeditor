import 'dart:io';
//import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

abstract class BaseFile {
  String path;
  String _name;
  FileManager? father;
  set name(String value) {
    if (value.contains('/') || value.contains('\\')) {
      throw Exception('file name not valid');
    }
    _name = value;
  }

  String get name {
    return _name;
  }

  FileSystemEntity? ref;

  BaseFile(this.path, this._name, this.ref, this.father) {
    name = _name;
  }

  Future<void> export(String url);
  Future<void> save();
}

class TextFile extends BaseFile {
  String content;
  TextFile(String path, String name, FileSystemEntity? ref, FileManager? father,
      this.content)
      : super(path, name, ref, father);
  TextFile.create(String currentPath, String name, FileManager? father)
      : content = "",
        super('$currentPath/$name', name, null, father);
  static fromFile(String currentPath, String url, FileManager? father) async {
    try {
      File file = File(url);
      bool exist = await file.exists();
      if (!exist) {
        throw Exception("File not exist");
      }

      String name = basename(file.path);
      // String name = file.path;
      String content = await file.readAsString();
      return TextFile('$currentPath/$name', name, file, father, content);
    } catch (ex) {
      rethrow;
    }
  }

  @override
  String toString() {
    return name;
  }

  @override
  Future<void> export(String url) async {
    if (ref != null) {
      save();
    } else {
      File file = File('$url/$name');
      await file.create();
      ref = file;
      save();
    }
  }

  @override
  Future<void> save() async {
    if (ref != null && ref is File && ref!.existsSync()) {
      File cf = ref as File;
      await cf.writeAsString(content);
    } else {
      throw Exception('cannot save the document');
    }
  }
}

class FileManager extends BaseFile {
  int id;
  List<TextFile> files;
  List<FileManager> folders;
  FileManager(String path, String name, FileSystemEntity? ref,
      FileManager father, this.files, this.folders)
      : id=DateTime.now().millisecondsSinceEpoch,
      super(path, name, ref, father);
  FileManager.create(String path, String name, FileManager father)
      : files = [],
        folders = [],
        id=DateTime.now().millisecondsSinceEpoch,
        super(path, name, null, father);

  static Future<FileManager> fromFolder(
      String currentPath, String url, FileManager father) async {
    try {
      Directory dir = Directory(url);
      bool exist = await dir.exists();
      if (!exist) {
        throw Exception('Directory not exist');
      }
      String name = basename(dir.path);
      String path = '$currentPath/$name';
      var file = await dir.list().toList();
      FileManager temp = FileManager.create(path, name, father);
      for (var f in file) {
        if (f is File) {
          temp.importFile(f.path);
        }
        if (f is Directory) {
          temp.importFolder(f.path);
        }
      }
      return temp;
    } catch (ex) {
      rethrow;
    }
  }

  bool nameOk(String name) {
    for (var f in files) {
      if (f.name == name) return false;
    }
    for (var f in folders) {
      if (f.name == name) return false;
    }
    return true;
  }

  void createFile(String fileName) {
    if (nameOk(fileName)) {
      files.add(TextFile.create(path, fileName, this));
    } else {
      throw Exception('name already used');
    }
  }

  void importFile(String url) async {
    TextFile ts = await TextFile.fromFile(path, url, this);
    if (nameOk(ts.name)) {
      files.add(ts);
    } else {
      throw Exception('name already used');
    }
  }

  void createFolder(String folderName) {
    if (nameOk(folderName)) {
      folders.add(FileManager.create(path, folderName, this));
    } else {
      throw Exception('name already used');
    }
  }

  void importFolder(String url) async {
    FileManager fm = await FileManager.fromFolder(path, url, this);
    if (nameOk(fm.name)) {
      folders.add(fm);
    } else {
      throw Exception('name already used');
    }
  }

  void generateTree(){
    
  }

  @override
  Future<void> export(String url) async {
    if (ref != null) {
      save();
    } else {
      Directory d = Directory('$url/$name');
      await d.create();
      ref = d;
      save();
    }
  }

  @override
  Future<void> save() async {
    try {
      if (ref != null && ref is Directory && ref!.existsSync()) {
        for (TextFile f in files) {
          await f.export(ref!.path);
        }
        for (FileManager f in folders) {
          await f.export(ref!.path);
        }
      }
    } catch (ex) {
      rethrow;
    }
  }
}
