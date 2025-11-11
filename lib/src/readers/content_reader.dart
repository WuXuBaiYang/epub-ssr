import 'package:epub_ssr/epub.dart';
import 'package:epub_ssr/src/entities/ref/byte_content_file.dart';
import 'package:epub_ssr/src/entities/ref/content.dart';
import 'package:epub_ssr/src/entities/ref/text_content_file.dart';

class ContentReader {
  static EpubContentRef parseContentMap(EpubBookRef bookRef) {
    final result = EpubContentRef();
    for (final e in bookRef.schema.package.manifest.items) {
      final fileName = e.href;
      final contentMimeType = e.mediaType;
      final contentType = getContentTypeByContentMimeType(contentMimeType);
      switch (contentType) {
        case EpubContentType.XHTML_1_1:
        case EpubContentType.CSS:
        case EpubContentType.OEB1_DOCUMENT:
        case EpubContentType.OEB1_CSS:
        case EpubContentType.XML:
        case EpubContentType.DTBOOK:
        case EpubContentType.DTBOOK_NCX:
          final epubTextContentFile = EpubTextContentFileRef(bookRef)
            ..fileName = Uri.decodeFull(fileName)
            ..contentType = contentType
            ..contentMimeType = contentMimeType;
          switch (contentType) {
            case EpubContentType.XHTML_1_1:
              result.html[fileName] = epubTextContentFile;
              break;
            case EpubContentType.CSS:
              result.css[fileName] = epubTextContentFile;
              break;
            case EpubContentType.DTBOOK:
            case EpubContentType.DTBOOK_NCX:
            case EpubContentType.OEB1_DOCUMENT:
            case EpubContentType.XML:
            case EpubContentType.OEB1_CSS:
            case EpubContentType.IMAGE_GIF:
            case EpubContentType.IMAGE_JPEG:
            case EpubContentType.IMAGE_PNG:
            case EpubContentType.IMAGE_SVG:
            case EpubContentType.FONT_TRUETYPE:
            case EpubContentType.FONT_OPENTYPE:
            case EpubContentType.OTHER:
              break;
          }
          result.allFiles[fileName] = epubTextContentFile;
          break;
        default:
          final epubByteContentFile = EpubByteContentFileRef(bookRef)
            ..fileName = Uri.decodeFull(fileName)
            ..contentType = contentType
            ..contentMimeType = contentMimeType;
          switch (contentType) {
            case EpubContentType.IMAGE_GIF:
            case EpubContentType.IMAGE_JPEG:
            case EpubContentType.IMAGE_PNG:
            case EpubContentType.IMAGE_SVG:
              result.images[fileName] = epubByteContentFile;
              break;
            case EpubContentType.FONT_TRUETYPE:
            case EpubContentType.FONT_OPENTYPE:
              result.fonts[fileName] = epubByteContentFile;
              break;
            case EpubContentType.CSS:
            case EpubContentType.XHTML_1_1:
            case EpubContentType.DTBOOK:
            case EpubContentType.DTBOOK_NCX:
            case EpubContentType.OEB1_DOCUMENT:
            case EpubContentType.XML:
            case EpubContentType.OEB1_CSS:
            case EpubContentType.OTHER:
              break;
          }
          result.allFiles[fileName] = epubByteContentFile;
          break;
      }
    }
    return result;
  }

  static EpubContentType getContentTypeByContentMimeType(String type) =>
      switch (type.toLowerCase()) {
        'application/xhtml+xml' => EpubContentType.XHTML_1_1,
        'application/x-dtbook+xml' => EpubContentType.DTBOOK,
        'application/x-dtbncx+xml' => EpubContentType.DTBOOK_NCX,
        'text/x-oeb1-document' => EpubContentType.OEB1_DOCUMENT,
        'application/xml' => EpubContentType.XML,
        'text/css' => EpubContentType.CSS,
        'text/x-oeb1-css' => EpubContentType.OEB1_CSS,
        'image/gif' => EpubContentType.IMAGE_GIF,
        'image/jpeg' => EpubContentType.IMAGE_JPEG,
        'image/png' => EpubContentType.IMAGE_PNG,
        'image/svg+xml' => EpubContentType.IMAGE_SVG,
        'font/truetype' => EpubContentType.FONT_TRUETYPE,
        'font/opentype' => EpubContentType.FONT_OPENTYPE,
        'application/vnd.ms-opentype' => EpubContentType.FONT_OPENTYPE,
        _ => EpubContentType.OTHER,
      };
}
