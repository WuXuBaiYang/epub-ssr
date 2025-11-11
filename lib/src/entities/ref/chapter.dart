import 'text_content_file.dart';

class EpubChapterRef {
  String title = '';
  String anchor = '';
  String contentFileName = '';
  List<EpubChapterRef> subChapters = [];
  EpubTextContentFileRef epubTextContentFileRef;

  EpubChapterRef(this.epubTextContentFileRef);

  String readHtmlContent() => epubTextContentFileRef.readContentAsText();
}
