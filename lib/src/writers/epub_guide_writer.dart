import 'package:epub_ssr/src/schema/opf/guide.dart';
import 'package:xml/xml.dart';

class EpubGuideWriter {
  static void writeGuide(XmlBuilder builder, EpubGuide? guide) {
    return builder.element(
      'guide',
      nest: () => guide?.items.forEach(
        (e) => builder.element(
          'reference',
          attributes: {'type': e.type, 'title': e.title, 'href': e.href},
        ),
      ),
    );
  }
}
