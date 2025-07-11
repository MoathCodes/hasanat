import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../utils/preferences/preferences.dart';
import '../utils/preferences/preferences_utils.dart';

class QuranRepository {
  ///Quran pages number
  static const hafsPagesNumber = 604;

  int? getLastPage() => PreferencesUtils().getInt(Preferences().lastPage);

  Future<List<dynamic>> getQuran() async {
    String content = await rootBundle
        .loadString('packages/flutter_quran/lib/assets/jsons/quran_hafs.json');
    return await jsonDecode(content);
  }

  Future<bool> saveLastPage(int lastPage) async =>
      PreferencesUtils().setInt(Preferences().lastPage, lastPage);

  // Future<bool> saveBookmarks(List<Bookmark> bookmarks) =>
  //     PreferencesUtils().setStringList(Preferences().bookmarks,
  //         bookmarks.map((bookmark) => json.encode(bookmark.toJson())).toList());

  // List<Bookmark> getBookmarks() =>
  //     (PreferencesUtils().getStringList(Preferences().bookmarks) ?? [])
  //         .map((bookmark) => Bookmark.fromJson(json.decode(bookmark)))
  //         .toList();
}
