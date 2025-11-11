import 'metadata.dart';
import 'label.dart';

class EpubNavigationTarget {
  String id = '';
  String clazz = '';
  String value = '';
  String playOrder = '';
  List<EpubNavigationLabel> navigationLabels = [];
  EpubNavigationContent content = EpubNavigationContent();
}
