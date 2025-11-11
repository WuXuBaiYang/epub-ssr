import 'package:epub_ssr/src/schema/opf/spine.dart';
import 'package:xml/xml.dart';

class EpubSpineWriter {
  static void writeSpine(XmlBuilder builder, EpubSpine spine) {
    return builder.element(
      'spine',
      attributes: {'toc': spine.tableOfContents ?? ''},
      nest: () => spine.items.forEach(
        (e) => builder.element(
          'itemref',
          attributes: {'idref': e.idRef, 'linear': e.isLinear ? 'no' : 'yes'},
        ),
      ),
    );
  }
}
