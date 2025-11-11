import 'package:epub_ssr/src/entities/ref/book.dart';
import 'package:epub_ssr/src/entities/ref/chapter.dart';
import 'package:epub_ssr/src/schema/navigation/point.dart';

class ChapterReader {
  static List<EpubChapterRef> getChapters(EpubBookRef bookRef) {
    return getChaptersImpl(bookRef, bookRef.schema.navigation.navMap.points);
  }

  static List<EpubChapterRef> getChaptersImpl(EpubBookRef bookRef,
      List<EpubNavigationPoint> navigationPoints,) {
    return navigationPoints.map<EpubChapterRef>((e) {
      final index = e.content.source.indexOf('#');
      final contentFileName = Uri.decodeFull(
        index > 0 ? e.content.source.substring(0, index) : e.content.source
            .replaceAll('../', ''),
      );
      final anchor = index > 0 ? e.content.source.substring(index + 1) : '';
      final contentFileRef = bookRef.content.html[contentFileName];
      if (!bookRef.content.html.containsKey(contentFileName) ||
          contentFileRef == null) {
        throw Exception(
          'Incorrect EPUB manifest: item with href = "$contentFileName" is missing.',
        );
      }
      return EpubChapterRef(contentFileRef)
        ..anchor = anchor
        ..contentFileName = contentFileName
        ..title = e.navigationLabels.first.text
        ..subChapters = getChaptersImpl(bookRef, e.childNavigationPoints);
    }).toList();
  }
}
