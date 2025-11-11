import 'dart:convert' as convert;
import 'package:archive/archive.dart';
import 'package:epub_ssr/src/utils/list_where.dart';
import 'package:xml/xml.dart';

class RootFilePathReader {
  static const EPUB_CONTAINER_FILE_PATH = 'META-INF/container.xml';

  static String? getRootFilePath(Archive epubArchive) {
    final containerFileEntry = epubArchive.files.firstWhereOrNull(
      (e) => e.name == EPUB_CONTAINER_FILE_PATH,
    );
    if (containerFileEntry == null) {
      throw Exception(
        'EPUB parsing error: $EPUB_CONTAINER_FILE_PATH file not found in archive.',
      );
    }
    final containerDocument = XmlDocument.parse(
      convert.utf8.decode(containerFileEntry.content),
    );
    final packageElement = containerDocument
        .findAllElements(
          'container',
          namespace: 'urn:oasis:names:tc:opendocument:xmlns:container',
        )
        .firstOrNull;
    if (packageElement == null) {
      throw Exception('EPUB parsing error: Invalid epub container');
    }
    final rootFileElement = packageElement.descendants.firstWhereOrNull(
      (e) => (e is XmlElement) && 'rootfile' == e.name.local,
    );
    return rootFileElement?.getAttribute('full-path');
  }
}
