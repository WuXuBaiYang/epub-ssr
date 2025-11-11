import 'package:epub_ssr/src/schema/opf/metadata.dart';
import 'package:epub_ssr/src/schema/opf/version.dart';
import 'package:xml/xml.dart';

class EpubMetadataWriter {
  static const _dc_namespace = 'http://purl.org/dc/elements/1.1/';
  static const _opf_namespace = 'http://www.idpf.org/2007/opf';

  static void writeMetadata(
    XmlBuilder builder,
    EpubMetadata meta,
    EpubVersion version,
  ) {
    return builder.element(
      'metadata',
      namespaces: {_opf_namespace: 'opf', _dc_namespace: 'dc'},
      nest: () {
        meta
          ..titles.forEach(
            (item) =>
                builder.element('title', nest: item, namespace: _dc_namespace),
          )
          ..creators.forEach(
            (item) => builder.element(
              'creator',
              namespace: _dc_namespace,
              nest: () {
                if (item.role.isNotEmpty) {
                  builder.attribute(
                    'role',
                    item.role,
                    namespace: _opf_namespace,
                  );
                }
                if (item.fileAs.isNotEmpty) {
                  builder.attribute(
                    'file-as',
                    item.fileAs,
                    namespace: _opf_namespace,
                  );
                }
                builder.text(item.creator);
              },
            ),
          )
          ..subjects.forEach(
            (item) => builder.element(
              'subject',
              namespace: _dc_namespace,
              nest: item,
            ),
          )
          ..publishers.forEach(
            (item) => builder.element(
              'publisher',
              namespace: _dc_namespace,
              nest: item,
            ),
          )
          ..contributors.forEach(
            (item) => builder.element(
              'contributor',
              namespace: _dc_namespace,
              nest: () {
                if (item.role.isNotEmpty) {
                  builder.attribute(
                    'role',
                    item.role,
                    namespace: _opf_namespace,
                  );
                }
                if (item.fileAs.isNotEmpty) {
                  builder.attribute(
                    'file-as',
                    item.fileAs,
                    namespace: _opf_namespace,
                  );
                }
                builder.text(item.contributor);
              },
            ),
          )
          ..dates.forEach(
            (date) => builder.element(
              'date',
              namespace: _dc_namespace,
              nest: () {
                if (date.event.isNotEmpty) {
                  builder.attribute(
                    'event',
                    date.event,
                    namespace: _opf_namespace,
                  );
                }
                builder.text(date.date);
              },
            ),
          )
          ..types.forEach(
            (type) =>
                builder.element('type', namespace: _dc_namespace, nest: type),
          )
          ..formats.forEach(
            (format) => builder.element(
              'format',
              namespace: _dc_namespace,
              nest: format,
            ),
          )
          ..identifiers.forEach(
            (id) => builder.element(
              'identifier',
              namespace: _dc_namespace,
              nest: () {
                if (id.id.isNotEmpty) builder.attribute('id', id.id);
                if (id.scheme.isNotEmpty) {
                  builder.attribute(
                    'scheme',
                    id.scheme,
                    namespace: _opf_namespace,
                  );
                }
                builder.text(id.identifier);
              },
            ),
          )
          ..sources.forEach(
            (item) =>
                builder.element('source', namespace: _dc_namespace, nest: item),
          )
          ..languages.forEach(
            (item) => builder.element(
              'language',
              namespace: _dc_namespace,
              nest: item,
            ),
          )
          ..relations.forEach(
            (item) => builder.element(
              'relation',
              namespace: _dc_namespace,
              nest: item,
            ),
          )
          ..coverages.forEach(
            (item) => builder.element(
              'coverage',
              namespace: _dc_namespace,
              nest: item,
            ),
          )
          ..rights.forEach(
            (item) =>
                builder.element('rights', namespace: _dc_namespace, nest: item),
          )
          ..metaItems.forEach(
            (metaItem) => builder.element(
              'meta',
              nest: () {
                if (version == EpubVersion.Epub2) {
                  if (metaItem.name.isNotEmpty) {
                    builder.attribute('name', metaItem.name);
                  }
                  if (metaItem.content.isNotEmpty) {
                    builder.attribute('content', metaItem.content);
                  }
                } else if (version == EpubVersion.Epub3) {
                  if (metaItem.id.isNotEmpty) {
                    builder.attribute('id', metaItem.id);
                  }
                  if (metaItem.refines.isNotEmpty) {
                    builder.attribute('refines', metaItem.refines);
                  }
                  if (metaItem.property.isNotEmpty) {
                    builder.attribute('property', metaItem.property);
                  }
                  if (metaItem.scheme.isNotEmpty) {
                    builder.attribute('scheme', metaItem.scheme);
                  }
                }
              },
            ),
          );
        if (meta.description.isNotEmpty) {
          builder.element(
            'description',
            namespace: _dc_namespace,
            nest: meta.description,
          );
        }
      },
    );
  }
}
