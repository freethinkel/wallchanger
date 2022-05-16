import 'dart:io';
import 'dart:math';

import 'package:Wallchanger/services/storage.service.dart';
import 'package:path/path.dart';

class DirectoryService {
  final allowedExtensions = ['png', 'jpg', 'jpeg'];

  Future<File?> getRandomImageFromDir(Directory dir) async {
    var files = await dir.list().toList();

    var images = (await Future.wait(files.map((entity) async {
      return Entity(entity: entity, stat: await entity.stat());
    }).toList()))
        .where((entity) {
          return entity.stat.type == FileSystemEntityType.file &&
              allowedExtensions.indexOf(
                      entity.entity.path.split('.').last.toLowerCase()) >=
                  0;
        })
        .map((entity) => File(entity.entity.path))
        .toList();
    if (images.length > 0) {
      await StorageService().clearTempDir();
      var random = Random().nextInt(images.length);
      var photo = images[random];
      print('$random:::${images.length}::${photo.path}');
      var newPath =
          (await StorageService().getTempPath()).path + basename(photo.path);
      var newFile = await photo.copy(newPath);
      return newFile;
    }
    return null;
  }
}

class Entity {
  FileSystemEntity entity;
  FileStat stat;

  Entity({required this.entity, required this.stat});
}
