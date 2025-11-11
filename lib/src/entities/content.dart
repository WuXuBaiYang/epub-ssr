import 'byte_content_file.dart';
import 'content_file.dart';
import 'text_content_file.dart';

class EpubContent {
  Map<String, EpubTextContentFile> html = {};
  Map<String, EpubTextContentFile> css = {};
  Map<String, EpubByteContentFile> images = {};
  Map<String, EpubByteContentFile> fonts = {};
  Map<String, EpubContentFile> allFiles = {};
}

enum EpubContentType {
  XHTML_1_1,
  DTBOOK,
  DTBOOK_NCX,
  OEB1_DOCUMENT,
  XML,
  CSS,
  OEB1_CSS,
  IMAGE_GIF,
  IMAGE_JPEG,
  IMAGE_PNG,
  IMAGE_SVG,
  FONT_TRUETYPE,
  FONT_OPENTYPE,
  OTHER,
}
