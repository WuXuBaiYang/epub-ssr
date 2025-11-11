import 'package:archive/archive.dart';
import 'package:epub_ssr/epub.dart';
import 'entities/ref/byte_content_file.dart';
import 'entities/ref/content.dart';
import 'entities/ref/content_file.dart';
import 'entities/ref/text_content_file.dart';
import 'readers/content_reader.dart';
import 'readers/schema_reader.dart';

class EpubReader {
  /// Opens the book asynchronously without reading its content. Holds the handle to the EPUB file.
  static EpubBookRef openBook(List<int> bytes) {
    final epubArchive = ZipDecoder().decodeBytes(bytes);
    final schema = SchemaReader.readSchema(epubArchive);
    final authorList = schema.package.metadata.creators
        .map((e) => e.creator)
        .toList();
    final bookRef = EpubBookRef(epubArchive)
      ..schema = schema
      ..title = schema.package.metadata.titles.firstOrNull ?? ''
      ..authorList = authorList
      ..author = authorList.join(',');
    return bookRef..content = ContentReader.parseContentMap(bookRef);
  }

  /// Opens the book asynchronously and reads all of its content into the memory. Does not hold the handle to the EPUB file.
  static EpubBook readBook(List<int> bytes) {
    final epubBookRef = openBook(bytes);
    return EpubBook()
      ..schema = epubBookRef.schema
      ..title = epubBookRef.title
      ..authorList = epubBookRef.authorList
      ..author = epubBookRef.author
      ..content = readContent(epubBookRef.content)
      ..coverImage = epubBookRef.readCover()
      ..chapters = readChapters(epubBookRef.chapters);
  }

  static EpubContent readContent(EpubContentRef ref) {
    final result = EpubContent()
      ..html = readTextContentFiles(ref.html)
      ..css = readTextContentFiles(ref.css)
      ..images = readByteContentFiles(ref.images)
      ..fonts = readByteContentFiles(ref.fonts);
    result.html.forEach((k, v) => result.allFiles[k] = v);
    result.css.forEach((k, v) => result.allFiles[k] = v);
    result.images.forEach((k, v) => result.allFiles[k] = v);
    result.fonts.forEach((k, v) => result.allFiles[k] = v);
    ref.allFiles.forEach((k, v) {
      if (result.allFiles.containsKey(k)) return;
      result.allFiles[k] = readByteContentFile(v);
    });
    return result;
  }

  static Map<String, EpubTextContentFile> readTextContentFiles(
    Map<String, EpubTextContentFileRef> refs,
  ) {
    return refs.map((k, v) {
      return MapEntry(
        k,
        EpubTextContentFile()
          ..fileName = v.fileName
          ..contentType = v.contentType
          ..contentMimeType = v.contentMimeType
          ..content = v.readContentAsText(),
      );
    });
  }

  static Map<String, EpubByteContentFile> readByteContentFiles(
    Map<String, EpubByteContentFileRef> refs,
  ) {
    return refs.map((k, v) => MapEntry(k, readByteContentFile(v)));
  }

  static EpubByteContentFile readByteContentFile(EpubContentFileRef ref) {
    return EpubByteContentFile()
      ..fileName = ref.fileName
      ..contentType = ref.contentType
      ..contentMimeType = ref.contentMimeType
      ..content = ref.readContentAsBytes();
  }

  static List<EpubChapter> readChapters(List<EpubChapterRef> refs) {
    return refs.map((e) {
      return EpubChapter()
        ..title = e.title
        ..contentFileName = e.contentFileName
        ..anchor = e.anchor
        ..htmlContent = e.readHtmlContent()
        ..subChapters = readChapters(e.subChapters);
    }).toList();
  }
}
