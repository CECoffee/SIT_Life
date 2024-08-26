import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:mimir/r.dart';
import 'package:universal_platform/universal_platform.dart';

class Files {
  const Files._();

  static Future<void> init({
    required Directory temp,
    required Directory cache,
    required Directory internal,
    required Directory user,
  }) async {
    Files._temp = temp;
    Files.cache = cache;
    Files.internal = internal;
    Files.user = user;
    debugPrint("Cache dir: $cache");
    debugPrint("Temp dir: $temp");
    debugPrint("Internal dir: $internal");
    debugPrint("User dir: $user");
    Files.temp = TempDir._();
    await timetable.init();
  }

  static late final Directory _temp;

  static late final TempDir temp;
  static late final Directory cache;
  static late final Directory internal;
  static late final Directory user;

  static Directory get screenshot => temp.subDir("screenshot");

  static Directory get artifact => temp.subDir("artifact");

  static const timetable = TimetableFiles._();
  static const oaAnnounce = OaAnnounceFiles._();
}

extension DirectoryX on Directory {
  File subFile(String p1, [String? p2, String? p3, String? p4]) => File(join(path, p1, p2, p3, p4));

  Directory subDir(String p1, [String? p2, String? p3, String? p4]) => Directory(join(path, p1, p2, p3, p4));
}

class TimetableFiles {
  const TimetableFiles._();

  File get backgroundFile => Files.user.subFile("timetable", "background");

  // on MIUI, OpenFile can't open file under `Files.user`
  Directory get calendarDir => (UniversalPlatform.isAndroid ? Files.cache : Files.user).subDir("timetable", "calendar");

  Future<void> init() async {
    await calendarDir.create(recursive: true);
    await Files.user.subDir("timetable").create(recursive: true);
  }
}

class OaAnnounceFiles {
  const OaAnnounceFiles._();

  Directory attachmentDir(String uuid) => Files.internal.subDir("attachment", uuid);

  Future<void> init() async {}
}

class TempDir {
  TempDir._();

  Directory? _realDir = UniversalPlatform.isWindows ? null : Files._temp;

  Directory dir() {
    // lazy create temp dir
    return _realDir ??= Files._temp.createTempSync(R.appId);
  }

  File subFile(String p1, [String? p2, String? p3, String? p4]) => dir().subFile(p1, p2, p3, p4);

  Directory subDir(String p1, [String? p2, String? p3, String? p4]) => dir().subDir(p1, p2, p3, p4);
}
