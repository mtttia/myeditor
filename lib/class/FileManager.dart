import 'dart:io';
//import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

abstract class BaseFile{
  String path;
  String _name;
  set name(String value){
    if(value.contains('/') || value.contains('\\')){
      throw Exception('file name not valid');
    }
    _name = value;
  }
  String get name{
    return _name;
  }
  FileSystemEntity? ref;

  BaseFile(this.path, this._name, this.ref){
    name = _name;
  }

  Future<void> export(String url);
  Future<void> save();
}

class TextFile extends BaseFile{
  String content;
  TextFile(String path, String name, FileSystemEntity? ref, this.content) : super(path, name, ref);
  TextFile.create(String currentPath, String name) : content="", super('$currentPath/$name', name, null);
  static fromFile(String currentPath, String url) async{
    try {
      File file = File(url);
      bool exist = await file.exists();
      if (!exist) {
        throw Exception("File not exist");
      }
      
      String name = basename(file.path);
      // String name = file.path;
      String content = await file.readAsString();
      return TextFile('$currentPath/$name', name, file, content);
    } catch (ex) {
      rethrow;
    }
  }


  @override
  String toString(){
    return name;
  }

  @override
  Future<void> export(String url) async{
    if(ref != null){
      save();
    }
    else{
      File file = File('$url/$name');
      await file.create();
      ref = file;
      save();
    }
  }

  @override
  Future<void> save() async {
    if(ref != null && ref is File && ref!.existsSync()){
      File cf = ref as File;
      await cf.writeAsString(content);       
    }
    else{
      throw Exception('cannot save the document');
    }
  }
}

class FileManager extends BaseFile{
  List<TextFile> files;
  List<FileManager> folders;
  FileManager(String path, String name, FileSystemEntity? ref, this.files, this.folders) : super(path, name, ref);
  FileManager.create(String path, String name, FileSystemEntity? ref) : files=[], folders=[], super(path, name, ref);


  static Future<FileManager> fromFolder(String currentPath, String url) async {
    try {
      Directory dir = Directory(url);
      bool exist = await dir.exists();
      if (!exist) {
        throw Exception('Directory not exist');
      }
      String name = basename(dir.path);
      String path = '$currentPath/$name';
      var file = await dir.list().toList();
      List<TextFile> files = [];
      List<FileManager> folders = [];
      for (var f in file) {
        // print('${f.path} is ${f is File ? 'file' : f is Directory ? 'directory' : 'unknown'}');
        if (f is File) {
          files.add(await TextFile.fromFile(path, f.path));
        }
        if (f is Directory) {
          FileManager temp = await FileManager.fromFolder(path, f.path);
          folders.add(temp);
        }
      }
      return FileManager(path, name, dir, files, folders);
      
    } catch (ex) {
      rethrow;
    }
  }

  @override
  Future<void> export(String url) async{
    if(ref != null){
      save();
    }
    else{
      Directory d = Directory('$url/$name');
      await d.create();
      ref = d;
      save();
    }
  }

  @override
  Future<void> save() async {
    try {
      if(ref != null && ref is Directory && ref!.existsSync()){
        for(TextFile f in files){
          await f.export(ref!.path);
        }
        for(FileManager f in folders){
          await f.export(ref!.path);
        }
      }
    } catch (ex) {
      rethrow;
    }
  }

}