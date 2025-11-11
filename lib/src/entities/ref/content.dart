import 'byte_content_file.dart';
import 'content_file.dart';
import 'text_content_file.dart';

class EpubContentRef {
  Map<String, EpubTextContentFileRef> html = {};
  Map<String, EpubTextContentFileRef> css = {};
  Map<String, EpubByteContentFileRef> images = {};
  Map<String, EpubByteContentFileRef> fonts = {};
  Map<String, EpubContentFileRef> allFiles = {};
}
