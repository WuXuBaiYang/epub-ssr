import 'package:epub_ssr/src/schema/opf/manifest.dart';
import 'package:xml/xml.dart';

class EpubManifestWriter {
  static void writeManifest(XmlBuilder builder, EpubManifest manifest) {
    return builder.element(
      'manifest',
      nest: () {
        manifest.items.forEach(
          (e) => builder.element(
            'item',
            nest: () => builder
              ..attribute('id', e.id)
              ..attribute('href', e.href)
              ..attribute('media-type', e.mediaType),
          ),
        );
      },
    );
  }
}
