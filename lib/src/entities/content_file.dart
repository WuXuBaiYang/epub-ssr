import 'package:epub_ssr/epub.dart';

abstract class EpubContentFile {
  String fileName = '';
  EpubContentType contentType = EpubContentType.OTHER;
  String contentMimeType = '';
}
