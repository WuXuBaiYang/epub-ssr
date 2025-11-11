import 'metadata.dart';
import 'label.dart';

class EpubNavigationPageTarget {
  String id = '';
  String value = '';
  EpubNavigationPageTargetType type = EpubNavigationPageTargetType.UNDEFINED;
  String clazz = '';
  String playOrder = '';
  List<EpubNavigationLabel> navigationLabels = [];
  EpubNavigationContent content = EpubNavigationContent();
}

enum EpubNavigationPageTargetType { UNDEFINED, FRONT, NORMAL, SPECIAL }
