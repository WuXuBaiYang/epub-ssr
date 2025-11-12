import 'dart:typed_data';

import 'package:epub_ssr/src/entities/ref/book.dart';
import 'package:epub_ssr/src/utils/list_where.dart';

class BookCoverReader {
  static Uint8List? readBookCover(EpubBookRef bookRef) {
    final metaItems = bookRef.schema.package.metadata.metaItems;
    if (metaItems.isEmpty) return null;
    final coverMetaItem = metaItems.firstWhereOrNull(
      (e) => e.name.toLowerCase() == 'cover',
    );
    if (coverMetaItem?.content == null) return null;
    final coverManifestItem = bookRef.schema.package.manifest.items
        .firstWhereOrNull(
          (e) => e.id.toLowerCase() == coverMetaItem?.content.toLowerCase(),
        );
    if (coverManifestItem == null) {
      throw Exception(
        'Incorrect EPUB manifest: item with ID = "${coverMetaItem?.content}" is missing.',
      );
    }
    if (!bookRef.content.images.containsKey(coverManifestItem.href)) {
      throw Exception(
        'Incorrect EPUB manifest: item with href = "${coverManifestItem.href}" is missing.',
      );
    }
    return bookRef.content.images[coverManifestItem.href]?.readContentAsBytes();
  }
}
