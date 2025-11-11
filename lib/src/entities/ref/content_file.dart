import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:epub_ssr/epub.dart';
import 'package:epub_ssr/src/utils/list_where.dart';
import 'package:epub_ssr/src/utils/zip_path_utils.dart';

class EpubContentFileRef {
  EpubBookRef epubBookRef;
  String fileName = '';
  EpubContentType contentType = EpubContentType.OTHER;
  String contentMimeType = '';

  EpubContentFileRef(this.epubBookRef);

  ArchiveFile? get contentFileEntry {
    final contentFilePath = ZipPathUtils.combine(
      epubBookRef.schema.contentDirectoryPath,
      fileName,
    );
    return epubBookRef.epubArchive.files.firstWhereOrNull(
      (e) => e.name == contentFilePath,
    );
  }

  Uint8List get contentStream => openContentStream(contentFileEntry);

  Uint8List openContentStream(ArchiveFile? contentFileEntry) {
    if (contentFileEntry == null) throw Exception('content file not found');
    return contentFileEntry.content;
  }

  Uint8List readContentAsBytes() => openContentStream(contentFileEntry);

  String readContentAsText() => convert.utf8.decode(contentStream);
}
