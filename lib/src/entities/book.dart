import 'dart:typed_data';

import 'chapter.dart';
import 'content.dart';
import 'schema.dart';

class EpubBook {
  String title = '';
  String author = '';
  List<String> authorList = [];
  EpubSchema schema = EpubSchema();
  EpubContent content = EpubContent();
  Uint8List? coverImage;
  List<EpubChapter> chapters = [];
}
