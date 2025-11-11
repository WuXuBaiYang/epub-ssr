import 'package:epub_ssr/epub.dart';
import 'package:epub_ssr/src/schema/opf/version.dart';
import 'package:xml/xml.dart';

import 'epub_guide_writer.dart';
import 'epub_manifest_writer.dart';
import 'epub_metadata_writer.dart';
import 'epub_spine_writer.dart';

class EpubPackageWriter {
  static const String _namespace = 'http://www.idpf.org/2007/opf';

  static String writeContent(EpubPackage package) {
    final builder = XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element(
        'package',
        attributes: {
          'version': package.version == EpubVersion.Epub2 ? '2.0' : '3.0',
          'unique-identifier': 'etextno',
        },
        nest: () {
          builder.namespace(_namespace);
          EpubMetadataWriter.writeMetadata(
            builder,
            package.metadata,
            package.version,
          );
          EpubManifestWriter.writeManifest(builder, package.manifest);
          EpubSpineWriter.writeSpine(builder, package.spine);
          EpubGuideWriter.writeGuide(builder, package.guide);
        },
      );
    return builder.buildDocument().toXmlString(pretty: false);
  }
}
