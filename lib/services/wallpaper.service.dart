import 'dart:io';
import 'package:Wallchanger/config.dart';

class WallpaperService {
  Future<void> setWallpaper(File image) async {
    await _wallsDbExec('insert into data values("${image.path}");');
    final newEntry =
        (await _wallsDbExec('select max(rowid) from data;')).trim();
    final pictures = (await _wallsDbExec('select rowid from pictures;'))
        .split('\n')
        .toList();
    var sql = 'delete from preferences; ';

    pictures.forEach((pic) {
      if (pic.isNotEmpty) {
        sql += 'insert into preferences (key, data_id, picture_id)';
        sql += 'values(1, ${newEntry}, ${pic}); ';
      }
    });
    await _wallsDbExec(sql);
    await Process.run('killall', ['Dock']);
  }

  Future<String> _wallsDbExec(String query) async {
    var dbFile =
        '${HOME_DIR}/Library/Application Support/Dock/desktoppicture.db';
    var result = await Process.run('sqlite3', [dbFile, query]);

    return result.stdout.toString();
  }
}
