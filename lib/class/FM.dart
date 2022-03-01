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

  FileManager? getDir(String name) {
    for (var f in folders) {
      if (f.name == name) return f;
    }
    return null;
  }

  void pushFile(TextFile f) {
    files.add(f);
  }

  String toString() {
    return absolutePath ?? name;
  }
}

class TextFile {
  String name;
  String? content;
  File? file;
  String? absolutePath;

  TextFile(this.name, this.content, this.file, {this.absolutePath}) {
    absolutePath = absolutePath ?? name;
  }
  TextFile.empty(this.name) {
    content = "cane";
    file = null;
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
    file = File(url);
    await file.create(recursive: true);
  }

  String toString() {
    return absolutePath ?? name;
  }
}
