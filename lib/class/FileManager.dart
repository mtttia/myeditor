import 'dart:io';
//import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

// Future<FileSystemEntity> readDir(String url){

// }

class FileManager {
  List<TextFile> files;
  List<FileManager> folders;
  Directory? dir;
  String name;
  String? absolutePath;

  FileManager(this.name, this.files, this.folders, this.dir,
      {this.absolutePath}) {
    absolutePath = absolutePath ?? name;
  }

  FileManager.empty(this.name)
      : files = [],
        folders = [],
        absolutePath = name;

  static Future<FileManager> fromDirectory(String url) async {
    try {
      Directory dir = Directory(url);
      bool exist = await dir.exists();
      if (!exist) {
        throw Exception('Directory not exist');
      }
      String absolutePath = dir.path;
      String name = basename(dir.path);
      var file = await dir.list().toList();
      List<TextFile> files = [];
      List<FileManager> direcotories = [];
      for (var f in file) {
        // print('${f.path} is ${f is File ? 'file' : f is Directory ? 'directory' : 'unknown'}');
        if (f is File) {
          files.add(await TextFile.fromFile(f.path));
        }
        if (f is Directory) {
          FileManager temp = await FileManager.fromDirectory(f.path);
          direcotories.add(temp);
        }
      }
      return FileManager(name, files, direcotories, dir,
          absolutePath: absolutePath);
    } catch (ex) {
      rethrow;
    }
  }

  List<String> get directories {
    List<String> temp = [];
    for (var f in folders) {
      temp.add(f.name);
    }
    return temp;
  }

  bool checkFileNewName(String name) {
    for (var f in files) {
      if (f.name == name) return false;
    }
    return true;
  }

  bool checkFolderNewName(String name) {
    for (var f in folders) {
      if (f.name == name) return false;
    }
    return true;
  }

  void newFile(String name) {
    if (checkFileNewName(name)) {
      files.add(TextFile.empty(name));
    } else {
      throw Exception('cannot create two file with the same name');
    }
  }

  void newFolder(String name) {
    if (checkFolderNewName(name)) {
      folders.add(FileManager.empty(name));
    } else {
      throw Exception('cannot create two folder with the same name');
    }
  }

  int? getFileIndex(String name) {
    for (int i = 0; i < files.length; i++) {
      if (files[i].name == name) return i;
    }
    for (int i = 0; i < files.length; i++) {
      if (files[i].absolutePath == name) return i;
    }
    return null;
  }

  int? getFolderIndex(String name) {
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].name == name) return i;
    }
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].absolutePath == name) return i;
    }
    return null;
  }

  void renameFile(String name, String newName) {
    if (name == newName) return;
    if (!checkFileNewName(newName)) throw Exception();
    for (int i = 0; i < files.length; i++) {
      if (files[i].name == newName) files[i]._rename(newName);
    }
  }

  void renameFolder(String name, String newName) {
    if (name == newName) return;
    if (!checkFolderNewName(newName)) throw Exception();
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].name == newName) folders[i].name = newName;
    }
  }

  void doAction(String name, Function callback) {
    int? i = getFolderIndex(name);
    if (i == null) throw Exception('folder not exists');
    folders[i] = callback(folders[i]);
  }

  //export

  void export(String url) async {
    try {
      dir = Directory(url + '\\' + absolutePath!);
      await dir?.create(recursive: true);
      for (var f in files) {
        f.export(dir!.path);
      }
      for (var d in folders) {
        d.export(dir!.path);
      }
    } catch (ex) {
      rethrow;
    }
  }

  String toString() {
    return absolutePath ?? name;
  }
}

class TextFile {
  String _name;
  String get name {
    return _name;
  }

  String? content;
  File? file;
  String? absolutePath;

  TextFile(this._name, this.content, this.file, {this.absolutePath}) {
    absolutePath = absolutePath ?? name;
  }
  TextFile.empty(this._name) {
    content = "";
    file = null;
    absolutePath = name;
  }

  static Future<TextFile> fromFile(String url) async {
    try {
      File file = File(url);
      bool exist = await file.exists();
      if (!exist) {
        throw Exception("File not exist");
      }
      String absolutePath = file.path;
      String name = basename(file.path);
      String content = await file.readAsString();
      return TextFile(name, content, file, absolutePath: absolutePath);
    } catch (ex) {
      rethrow;
    }
  }

  void export(String url) async {
    try {
      file = File(url + '\\' + absolutePath!);
      await file?.create(recursive: true);
      file?.writeAsString(content!);
    } catch (ex) {
      rethrow;
    }
  }

  void _rename(String newName) {
    _name = newName;
  }

  String toString() {
    return absolutePath ?? name;
  }
}
