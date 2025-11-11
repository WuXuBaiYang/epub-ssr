import 'package:image/image.dart';
import 'chapter.dart';
import 'content.dart';
import 'schema.dart';

class EpubBook {
  String title = '';
  String author = '';
  List<String> authorList = [];
  EpubSchema schema = EpubSchema();
  EpubContent content = EpubContent();
  Image? coverImage;
  List<EpubChapter> chapters = [];
}
