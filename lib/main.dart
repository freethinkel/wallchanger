import 'dart:async';
import 'dart:io';

import 'package:Wallchanger/config.dart';
import 'package:Wallchanger/services/directory.service.dart';
import 'package:Wallchanger/services/storage.service.dart';
import 'package:Wallchanger/services/unsplash.service.dart';
import 'package:Wallchanger/services/wallpaper.service.dart';
import 'package:args/args.dart';

void main(List<String> args) async {
  var parser = ArgParser();
  var isSetTime = false;
  int? time = null;
  String? unsplashCategory = null;
  String? selectedDir = null;

  parser.addFlag('help', abbr: 'h', negatable: false, callback: (used) {
    if (used) {
      print(parser.usage);
    }
  });

  parser.addOption('unsplash',
      abbr: 'u',
      help: 'Use unsplash random photo from category', callback: (category) {
    unsplashCategory = category;
  });
  parser.addOption('time',
      abbr: 't',
      help: 'Interval minutes for reset wallpaper', callback: (data) {
    if (data != null) {
      isSetTime = true;
      time = int.tryParse((data));
    }
  });
  parser.addOption(
    'directory',
    abbr: 'd',
    help: 'Directory photos',
    callback: (data) {
      selectedDir = data;
    },
  );

  parser.parse(args);

  if (unsplashCategory != null) {
    if (isSetTime) {
      Timer.periodic(Duration(minutes: time ?? 10), (timer) async {
        await setUnsplashWallpaper(unsplashCategory);
      });
    } else {
      await setUnsplashWallpaper(unsplashCategory);
    }
    return;
  }

  if (selectedDir != null) {
    var fullPath = (selectedDir ?? '').indexOf('~') == 0
        ? (selectedDir ?? '').replaceFirst('~', HOME_DIR)
        : selectedDir ?? '';
    var dir = Directory(fullPath);
    if (isSetTime) {
      Timer.periodic(Duration(minutes: time ?? 10), (timer) async {
        await setDirectoryWallpaper(dir);
      });
    } else {
      await setDirectoryWallpaper(dir);
    }
    return;
  }
}

setDirectoryWallpaper(Directory dir) async {
  await DirectoryService().setRandomImageFromDir(dir);
}

setUnsplashWallpaper(category) async {
  await StorageService().clearTempDir();
  var unsplash = UnsplashService(tempDir: await StorageService().getTempPath());
  var file = await (category == 'random'
      ? unsplash.setRandomPhoto()
      : unsplash.setPhotoFromCategory(category ?? ""));
}
