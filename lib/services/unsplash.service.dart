import 'dart:io';

class UnsplashService {
  var _url = 'https://source.unsplash.com';
  Directory tempDir;

  UnsplashService({required this.tempDir});

  Future<String> _getRedirectedUrl(String url) async {
    var httpClient = HttpClient();
    var req = await httpClient.getUrl(Uri.parse(url));
    req.followRedirects = false;
    var res = await req.close();
    httpClient.close(force: true);
    var targetUrl = res.headers['location']?.first.toString() ?? '';
    targetUrl = targetUrl.isNotEmpty ? targetUrl : url;
    return targetUrl;
  }

  Future<Uri> getFullImageUrl(String url) async {
    var parsed = Uri.parse(Uri.decodeComponent(await _getRedirectedUrl(url)));
    var newUrl = Uri(
        scheme: parsed.scheme,
        userInfo: parsed.userInfo,
        host: parsed.host,
        port: parsed.port,
        path: parsed.path,
        queryParameters: {...parsed.queryParameters, 'force': 'true'}
          ..remove('w'),
        fragment: parsed.fragment);
    return newUrl;
  }

  Future<File> downloadImage(Uri url) async {
    var wallName =
        'pic_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
    final wallFile = File('${tempDir.path}${wallName}');
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(url);
    final response = await request.close();

    var fileStream = wallFile.openWrite();
    await response.pipe(fileStream);
    await fileStream.close();
    httpClient.close(force: true);

    return wallFile;
  }

  Future<File> getRandomPhoto() async {
    return downloadImage(await getFullImageUrl('${_url}/random'));
  }

  Future getPhotoFromCategory(String category) async {
    return downloadImage(await getFullImageUrl('${_url}/random?${category}'));
  }
}
