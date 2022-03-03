import './FileManager.dart';

void main() async{
  try{
    TextFile file = TextFile.create('/', 'name.txt');
    file.content = "sono il cavallo pazzo Rabiot";
    await file.save();
  }catch(ex){
    print("impossible to save error");
  }
  try{
    TextFile file = TextFile.create('/', 'anather/.txt');
  }catch(ex){
    print("name error");
  }
  TextFile anatherFile = TextFile.create('/', 'anather.txt');
  anatherFile.content = "che bel content shis";
  await anatherFile.export('./');
  TextFile reader = await TextFile.fromFile('/', './anather.txt');
  print('${reader.content} == ${anatherFile.content} -> ${reader.content == anatherFile.content}');
}