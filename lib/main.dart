import 'dart:async';
import 'dart:io';

import 'package:Wallchanger/config.dart';
import 'package:Wallchanger/services/console.service.dart';
import 'package:Wallchanger/services/directory.service.dart';
import 'package:Wallchanger/services/storage.service.dart';
import 'package:Wallchanger/services/unsplash.service.dart';
import 'package:args/args.dart';

var isDebugMode = false;

void main(List<String> args) async {
  var parser = ArgParser();
  var isSetTime = false;
  int time = null;
  String unsplashCategory = null;
  String selectedDir = null;

  parser.addFlag('help', abbr: 'h', negatable: false, callback: (used) {
    if (used) {
      print(parser.usage);
      exit(0);
    }
  });

  parser.addFlag('verbose', abbr: 'v', help: 'Verbose mode', negatable: false,
      callback: (verbose) {
    isDebugMode = verbose;
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

  if (isDebugMode) {
    print('===DEBUG MODE===');
    if (isSetTime) {
      print('Run change wallperper every ${time} minutes');
    }
  }

  if (unsplashCategory != null) {
    if (isSetTime) {
      await setUnsplashWallpaper(unsplashCategory);
      if (isDebugMode) {
        showDebugCountDown(time ?? 0);
      }
      Timer.periodic(Duration(minutes: time ?? 10), (timer) async {
        if (isDebugMode) {
          showDebugCountDown(time ?? 0);
        }
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
      await setDirectoryWallpaper(dir);
      if (isDebugMode) {
        showDebugCountDown(time ?? 0);
      }
      Timer.periodic(Duration(minutes: time ?? 10), (timer) async {
        if (isDebugMode) {
          showDebugCountDown(time ?? 0);
        }
        await setDirectoryWallpaper(dir);
      });
    } else {
      await setDirectoryWallpaper(dir);
    }
    return;
  }
}

setDirectoryWallpaper(Directory dir) async {
  if (isDebugMode) {
    print('Settings directory photo as wallpaper...');
  }
  await DirectoryService().setRandomImageFromDir(dir);
}

setUnsplashWallpaper(category) async {
  if (isDebugMode) {
    print('Settings unsplash wallpaper...');
  }
  await StorageService().clearTempDir();
  var unsplash = UnsplashService(tempDir: await StorageService().getTempPath());
  await (category == 'random'
      ? unsplash.setRandomPhoto()
      : unsplash.setPhotoFromCategory(category ?? ""));
}

showDebugCountDown(int time) {
  Timer.periodic(Duration(minutes: time), (timer) {
    Console.write('${time - timer.tick} ');
    if (time - timer.tick == 0) {
      timer.cancel();
    }
  });
}
