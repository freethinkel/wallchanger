import 'dart:io';
import "package:path/path.dart" as path;
import 'package:Wallchanger/config.dart';

class StorageService {
  Future<Directory> getAppDir() async {
    var dir = Directory(path.normalize(
        '$HOME_DIR/Library/Application\ Support/ru.freethinkel.wallchanger/'));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  Future<void> clearTempDir() async {
    var tmp = await getTempPath();
    await tmp.delete(recursive: true);
  }

  Future<Directory> getTempPath() async {
    var appDir = await getAppDir();

    var tmpDir = Directory('${appDir.path}/.walls/');

    if (!await tmpDir.exists()) {
      await tmpDir.create(recursive: true);
    }

    return tmpDir;
  }
}
