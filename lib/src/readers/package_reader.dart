import 'dart:convert' as convert;
import 'package:archive/archive.dart';
import 'package:epub_ssr/epub.dart';
import 'package:epub_ssr/src/schema/opf/guide.dart';
import 'package:epub_ssr/src/schema/opf/guide_reference.dart';
import 'package:epub_ssr/src/schema/opf/manifest.dart';
import 'package:epub_ssr/src/schema/opf/manifest_item.dart';
import 'package:epub_ssr/src/schema/opf/metadata.dart';
import 'package:epub_ssr/src/schema/opf/metadata_contributor.dart';
import 'package:epub_ssr/src/schema/opf/metadata_creator.dart';
import 'package:epub_ssr/src/schema/opf/metadata_date.dart';
import 'package:epub_ssr/src/schema/opf/metadata_identifier.dart';
import 'package:epub_ssr/src/schema/opf/metadata_meta.dart';
import 'package:epub_ssr/src/schema/opf/spine.dart';
import 'package:epub_ssr/src/schema/opf/spine_item_ref.dart';
import 'package:epub_ssr/src/schema/opf/version.dart';
import 'package:epub_ssr/src/utils/list_where.dart';
import 'package:xml/xml.dart';

class PackageReader {
  static EpubGuide readGuide(XmlElement node) {
    return EpubGuide()
      ..items = node.children
          .whereType<XmlElement>()
          .where((e) => e.name.local.toLowerCase() == 'reference')
          .map<EpubGuideReference>((e) {
        final item = EpubGuideReference();
        e.attributes.forEach(
              (e) =>
          switch (e.name.local.toLowerCase()) {
            'type' => item.type = e.value,
            'title' => item.title = e.value,
            'href' => item.href = e.value,
            _ => null,
          },
        );
        return item;
      })
          .toList();
  }

  static EpubManifest readManifest(XmlElement node) {
    return EpubManifest()
      ..items = node.children
          .whereType<XmlElement>()
          .where((e) => e.name.local.toLowerCase() == 'item')
          .map((e) {
        final item = EpubManifestItem();
        e.attributes.forEach(
              (e) =>
          switch (e.name.local.toLowerCase()) {
            'id' => item.id = e.value,
            'href' => item.href = e.value,
            'media-type' => item.mediaType = e.value,
            'fallback' => item.fallback = e.value,
            'fallback-style' => item.fallbackStyle = e.value,
            'required-namespace' => item.requiredNamespace = e.value,
            'required-modules' => item.requiredModules = e.value,
            _ => null,
          },
        );
        return item;
      })
          .toList();
  }

  static EpubMetadata readMetadata(XmlElement node, EpubVersion epubVersion) {
    final result = EpubMetadata();
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'title' => result.titles.add(e.innerText),
        'creator' => result.creators.add(readMetadataCreator(e)),
        'subject' => result.subjects.add(e.innerText),
        'description' => result.description = e.innerText,
        'publisher' => result.publishers.add(e.innerText),
        'contributor' => result.contributors.add(readMetadataContributor(e)),
        'date' => result.dates.add(readMetadataDate(e)),
        'type' => result.types.add(e.innerText),
        'format' => result.formats.add(e.innerText),
        'identifier' => result.identifiers.add(readMetadataIdentifier(e)),
        'source' => result.sources.add(e.innerText),
        'language' => result.languages.add(e.innerText),
        'relation' => result.relations.add(e.innerText),
        'coverage' => result.coverages.add(e.innerText),
        'rights' => result.rights.add(e.innerText),
        'meta' =>
            result.metaItems.add(switch (epubVersion) {
              EpubVersion.Epub2 => readMetadataMetaVersion2(e),
              EpubVersion.Epub3 => readMetadataMetaVersion3(e),
            }),
        _ => null,
      },
    );
    return result;
  }

  static EpubMetadataContributor readMetadataContributor(XmlElement node) {
    final result = EpubMetadataContributor()
      ..contributor = node.innerText ?? '';
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'role' => result.role = e.innerText,
        'file-as' => result.fileAs = e.innerText,
        _ => null,
      },
    );
    return result;
  }

  static EpubMetadataCreator readMetadataCreator(XmlElement node) {
    final result = EpubMetadataCreator()
      ..creator = node.innerText ?? '';
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'role' => result.role = e.innerText,
        'file-as' => result.fileAs = e.innerText,
        _ => null,
      },
    );
    return result;
  }

  static EpubMetadataDate readMetadataDate(XmlElement node) {
    return EpubMetadataDate()
      ..date = node.innerText ?? ''
      ..event =
          node.getAttribute('event', namespace: node.name.namespaceUri) ?? '';
  }

  static EpubMetadataIdentifier readMetadataIdentifier(XmlElement node) {
    final result = EpubMetadataIdentifier()
      ..identifier = node.innerText ?? '';
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.innerText,
        'scheme' => result.scheme = e.innerText,
        _ => null,
      },
    );
    return result;
  }

  static EpubMetadataMeta readMetadataMetaVersion2(XmlElement node) {
    final result = EpubMetadataMeta();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'name' => result.name = e.innerText,
        'content' => result.content = e.innerText,
        _ => null,
      },
    );
    return result;
  }

  static EpubMetadataMeta readMetadataMetaVersion3(XmlElement node) {
    final result = EpubMetadataMeta();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.value,
        'refines' => result.refines = e.value,
        'property' => result.property = e.value,
        'scheme' => result.scheme = e.value,
        'name' => result.name = e.value,
        'content' => result.content = e.value,
        _ => null,
      },
    );
    return result;
  }

  static EpubPackage readPackage(Archive epubArchive, String rootFilePath) {
    final rootFileEntry = epubArchive.files.firstWhereOrNull(
          (e) => e.name == rootFilePath,
    );
    if (rootFileEntry == null) {
      throw Exception('EPUB parsing error: root file not found in archive.');
    }
    final containerDocument = XmlDocument.parse(
      convert.utf8.decode(rootFileEntry.content),
    );
    final opfNamespace = 'http://www.idpf.org/2007/opf';
    final packageNode = containerDocument
        .findElements('package', namespace: opfNamespace)
        .firstOrNull;
    if (packageNode == null) {
      throw Exception('EPUB parsing error: package not found.');
    }
    final version = switch (packageNode.getAttribute('version')) {
      '2.0' => EpubVersion.Epub2,
      '3.0' => EpubVersion.Epub3,
      _ => throw Exception('Unsupported EPUB version'),
    };
    final metadataNode = packageNode
        .findElements('metadata', namespace: opfNamespace)
        .firstOrNull;
    if (metadataNode == null) {
      throw Exception('EPUB parsing error: metadata not found in the package.');
    }
    final metadata = readMetadata(metadataNode, version);
    final manifestNode = packageNode
        .findElements('manifest', namespace: opfNamespace)
        .firstOrNull;
    if (manifestNode == null) {
      throw Exception('EPUB parsing error: manifest not found in the package.');
    }
    final manifest = readManifest(manifestNode);
    final spineNode = packageNode
        .findElements('spine', namespace: opfNamespace)
        .firstOrNull;
    if (spineNode == null) {
      throw Exception('EPUB parsing error: spine not found in the package.');
    }
    final spine = readSpine(spineNode);
    final guideNode = packageNode
        .findElements('guide', namespace: opfNamespace)
        .firstOrNull;
    return EpubPackage()
      ..version = version
      ..metadata = metadata
      ..manifest = manifest
      ..spine = spine
      ..guide = guideNode != null ? readGuide(guideNode) : null;
  }

  static EpubSpine readSpine(XmlElement node) {
    return EpubSpine()
      ..tableOfContents = node.getAttribute('toc')
      ..items = node.children
          .whereType<XmlElement>()
          .where((e) => e.name.local.toLowerCase() == 'itemref')
          .map((e) {
        final idRefAttribute = e.getAttribute('idref');
        if (idRefAttribute == null || idRefAttribute.isEmpty) {
          throw Exception('Incorrect EPUB spine: item ID ref is missing');
        }
        final linearAttribute = e.getAttribute('linear');
        return EpubSpineItemRef()
          ..idRef = idRefAttribute
          ..isLinear =
              linearAttribute == null ||
                  (linearAttribute.toLowerCase() == 'no');
      })
          .toList();
  }
}
