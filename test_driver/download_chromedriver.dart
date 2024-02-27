import 'dart:convert';
import 'dart:io';

void main() async {
  final platform = chromePlatform();
  print('Platform: $platform');
  final client = HttpClient();
  final version = await client.fetchJson<Map<String, dynamic>>(
      "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json");
  final downloads = version['channels']['Stable']['downloads']['chromedriver']
      as List<dynamic>;
  final downloadUrl =
      downloads.singleWhere((e) => e['platform'] == platform)['url'];
  final filename = Uri.parse(downloadUrl).pathSegments.last;
  print('Downloading "chromedriver" from $downloadUrl to $filename');
  await client.download(downloadUrl, File(filename));
  print('Unzipping $filename');
  final success = unzip_nf(filename);
  print("Unzip ${success ? 'success' : 'failed'}");
}

void shellCheck() {
  final shell = Platform.environment["SHELL"];
  final supportedShells = ['zsh', 'bash'];
  if (!supportedShells.contains(shell?.split("/").last)) {
    print('Shell "$shell" is not supported. Use one of $supportedShells');
    exit(0);
  }
}

String uname_m() {
  return (Process.runSync('uname', ['-m']).stdout as String).trim();
}

unzip_nf(String file) {
  final result = Process.runSync('unzip', ['-nj', file]);
  print(result.stdout);
  print(result.stderr);
  return result.exitCode == 0;
}

String chromePlatform() {
  final os = Platform.operatingSystem;
  return switch (os) {
    'linux' => switch (uname_m()) {
        "x86_64" => "linux64",
        String m => throw "$os $m is not supported",
      },
    'macos' => switch (uname_m()) {
        "x86_64" => "mac-x64",
        "arm64" => "mac-arm64",
        String m => throw "$os $m is not supported",
      },
    'windows' => switch (uname_m()) {
        'x86_64' => 'win64',
        'x86' => 'win32',
        String m => throw "$os $m is not supported",
      },
    _ => throw "$os not supported",
  };
}

extension HttpClientX on HttpClient {
  Future<T> fetchJson<T>(String url) async {
    final req = await getUrl(Uri.parse(url));
    final res = await req.close();
    final json = await res.transform(utf8.decoder).join();
    final data = jsonDecode(json);
    return data as T;
  }

  Future<void> download<T>(String url, File file) async {
    final req = await getUrl(Uri.parse(url));
    final downloadStream = await req.close();
    if (await file.exists()) await file.delete();
    final writer = file.openWrite();
    try {
      await writer.addStream(downloadStream);
      await writer.flush();
    } finally {
      writer.close();
    }
  }
}
