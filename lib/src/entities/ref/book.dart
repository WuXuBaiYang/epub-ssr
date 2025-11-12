import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:epub_ssr/src/entities/schema.dart';
import 'package:epub_ssr/src/readers/book_cover_reader.dart';
import 'package:epub_ssr/src/readers/chapter_reader.dart';
import 'chapter.dart';
import 'content.dart';

class EpubBookRef {
  Archive epubArchive;
  String title = '';
  String author = '';
  List<String> authorList = [];
  EpubSchema schema = EpubSchema();
  EpubContentRef content = EpubContentRef();

  EpubBookRef(this.epubArchive);

  List<EpubChapterRef> get chapters => ChapterReader.getChapters(this);

  Uint8List? readCover() => BookCoverReader.readBookCover(this);
}
