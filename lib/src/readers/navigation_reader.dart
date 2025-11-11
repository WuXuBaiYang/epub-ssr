import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:epub_ssr/epub.dart';
import 'package:epub_ssr/src/schema/navigation/doc_author.dart';
import 'package:epub_ssr/src/schema/navigation/doc_title.dart';
import 'package:epub_ssr/src/schema/navigation/head.dart';
import 'package:epub_ssr/src/schema/navigation/head_meta.dart';
import 'package:epub_ssr/src/schema/navigation/label.dart';
import 'package:epub_ssr/src/schema/navigation/list.dart';
import 'package:epub_ssr/src/schema/navigation/map.dart';
import 'package:epub_ssr/src/schema/navigation/metadata.dart';
import 'package:epub_ssr/src/schema/navigation/page_list.dart';
import 'package:epub_ssr/src/schema/navigation/page_target.dart';
import 'package:epub_ssr/src/schema/navigation/point.dart';
import 'package:epub_ssr/src/schema/navigation/target.dart';
import 'package:epub_ssr/src/schema/opf/version.dart';
import 'package:epub_ssr/src/utils/list_where.dart';
import 'package:epub_ssr/src/utils/zip_path_utils.dart';
import 'package:xml/xml.dart';

class NavigationReader {
  static EpubNavigation? readNavigation(Archive epubArchive,
      String contentDirectoryPath,
      EpubPackage package,) {
    final result = EpubNavigation();
    final tocId = package.spine.tableOfContents;
    if (tocId == null || tocId.isEmpty) {
      if (package.version == EpubVersion.Epub2) {
        throw Exception('EPUB parsing error: TOC ID is empty.');
      }
      return null;
    }
    final tocManifestItem = package.manifest.items.firstWhereOrNull(
          (e) => e.id.toLowerCase() == tocId.toLowerCase(),
    );
    if (tocManifestItem == null) {
      throw Exception(
        'EPUB parsing error: TOC item $tocId not found in EPUB manifest.',
      );
    }
    final tocFileEntryPath = ZipPathUtils.combine(
      contentDirectoryPath,
      tocManifestItem.href,
    );
    final tocFileEntry = epubArchive.files.firstWhereOrNull(
          (e) => e.name.toLowerCase() == tocFileEntryPath.toLowerCase(),
    );
    if (tocFileEntry == null) {
      throw Exception(
        'EPUB parsing error: TOC file $tocFileEntryPath not found in archive.',
      );
    }
    final containerDocument = XmlDocument.parse(
      convert.utf8.decode(tocFileEntry.content),
    );
    final ncxNamespace = 'http://www.daisy.org/z3986/2005/ncx/';
    final ncxNode = containerDocument
        .findAllElements('ncx', namespace: ncxNamespace)
        .firstOrNull;
    if (ncxNode == null) {
      throw Exception(
        'EPUB parsing error: TOC file does not contain ncx element.',
      );
    }
    final headNode = ncxNode
        .findAllElements('head', namespace: ncxNamespace)
        .firstOrNull;
    if (headNode == null) {
      throw Exception(
        'EPUB parsing error: TOC file does not contain head element.',
      );
    }
    result.head = readNavigationHead(headNode);
    final docTitleNode = ncxNode
        .findElements('docTitle', namespace: ncxNamespace)
        .firstOrNull;
    if (docTitleNode == null) {
      throw Exception(
        'EPUB parsing error: TOC file does not contain docTitle element.',
      );
    }
    result.docTitle = readNavigationDocTitle(docTitleNode);
    ncxNode
        .findElements('docAuthor', namespace: ncxNamespace)
        .forEach((e) => result.docAuthors.add(readNavigationDocAuthor(e)));
    final navMapNode = ncxNode
        .findElements('navMap', namespace: ncxNamespace)
        .firstOrNull;
    if (navMapNode == null) {
      throw Exception(
        'EPUB parsing error: TOC file does not contain navMap element.',
      );
    }
    result.navMap = readNavigationMap(navMapNode);
    final pageListNode = ncxNode
        .findElements('pageList', namespace: ncxNamespace)
        .firstOrNull;
    if (pageListNode != null) {
      result.pageList = readNavigationPageList(pageListNode);
    }
    ncxNode
        .findElements('navList', namespace: ncxNamespace)
        .forEach((e) => result.navLists.add(readNavigationList(e)));
    return result;
  }

  static EpubNavigationContent readNavigationContent(XmlElement node) {
    final result = EpubNavigationContent();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.value,
        'Source' => result.source = e.value,
        'src' => result.source = e.value,
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationDocAuthor readNavigationDocAuthor(XmlElement node) {
    final result = EpubNavigationDocAuthor();
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'text' => result.authors.add(e.innerText),
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationDocTitle readNavigationDocTitle(XmlElement node) {
    final result = EpubNavigationDocTitle();
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'text' => result.titles.add(e.innerText),
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationHead readNavigationHead(XmlElement node) {
    final result = EpubNavigationHead();
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'meta' =>
                () {
              final meta = EpubNavigationHeadMeta();
              e.attributes.forEach(
                    (e) =>
                switch (e.name.local.toLowerCase()) {
                  'name' => meta.name = e.value,
                  'content' => meta.content = e.value,
                  'scheme' => meta.scheme = e.value,
                  _ => null,
                },
              );
              if (meta.name.isEmpty) {
                throw Exception(
                  'Incorrect EPUB navigation meta: meta name is missing.',
                );
              }
              if (meta.content == null) {
                throw Exception(
                  'Incorrect EPUB navigation meta: meta content is missing.',
                );
              }
              result.metadata.add(meta);
            }(),
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationLabel readNavigationLabel(XmlElement node) {
    final navigationLabelTextNode = node
        .findElements('text', namespace: node.name.namespaceUri)
        .firstOrNull;
    if (navigationLabelTextNode == null) {
      throw Exception(
        'Incorrect EPUB navigation label: label text element is missing.',
      );
    }
    return EpubNavigationLabel()
      ..text = navigationLabelTextNode.innerText;
  }

  static EpubNavigationList readNavigationList(XmlElement node) {
    final result = EpubNavigationList();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.value,
        'class' => result.clazz = e.value,
        _ => null,
      },
    );
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'navlabel' => result.navigationLabels.add(readNavigationLabel(e)),
        'navtarget' => result.navigationTargets.add(readNavigationTarget(e)),
        _ => null,
      },
    );
    if (result.navigationLabels.isEmpty) {
      throw Exception(
        'Incorrect EPUB navigation page target: at least one navLabel element is required.',
      );
    }
    return result;
  }

  static EpubNavigationMap readNavigationMap(XmlElement node) {
    final result = EpubNavigationMap();
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'navpoint' => result.points.add(readNavigationPoint(e)),
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationPageList readNavigationPageList(XmlElement node) {
    final result = EpubNavigationPageList();
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'navTarget' => result.targets.add(readNavigationPageTarget(e)),
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationPageTarget readNavigationPageTarget(XmlElement node) {
    final result = EpubNavigationPageTarget();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.value,
        'value' => result.value = e.value,
        'type' =>
        result.type = EnumFromString<EpubNavigationPageTargetType>(
          EpubNavigationPageTargetType.values,
        ).get(e.value, EpubNavigationPageTargetType.UNDEFINED)!,
        'class' => result.clazz = e.value,
        'playorder' => result.playOrder = e.value,
        _ => null,
      },
    );
    if (result.type == EpubNavigationPageTargetType.UNDEFINED) {
      throw Exception(
        'Incorrect EPUB navigation page target: page target type is missing.',
      );
    }
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'navlabel' => result.navigationLabels.add(readNavigationLabel(e)),
        'content' => result.content = readNavigationContent(e),
        _ => null,
      },
    );
    if (result.navigationLabels.isEmpty) {
      throw Exception(
        'Incorrect EPUB navigation page target: at least one navLabel element is required.',
      );
    }
    return result;
  }

  static EpubNavigationPoint readNavigationPoint(XmlElement node) {
    final result = EpubNavigationPoint();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.value,
        'class' => result.clazz = e.value,
        'playorder' => result.playOrder = e.value,
        _ => null,
      },
    );
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'navlabel' => result.navigationLabels.add(readNavigationLabel(e)),
        'content' => result.content = readNavigationContent(e),
        'navpoint' => result.childNavigationPoints.add(readNavigationPoint(e)),
        _ => null,
      },
    );
    return result;
  }

  static EpubNavigationTarget readNavigationTarget(XmlElement node) {
    var result = EpubNavigationTarget();
    node.attributes.forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'id' => result.id = e.value,
        'value' => result.value = e.value,
        'class' => result.clazz = e.value,
        'playorder' => result.playOrder = e.value,
        _ => null,
      },
    );
    node.children.whereType<XmlElement>().forEach(
          (e) =>
      switch (e.name.local.toLowerCase()) {
        'navlabel' => result.navigationLabels.add(readNavigationLabel(e)),
        'content' => result.content = readNavigationContent(e),
        _ => null,
      },
    );
    return result;
  }
}
