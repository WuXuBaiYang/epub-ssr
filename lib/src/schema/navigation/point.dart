import 'metadata.dart';
import 'label.dart';

class EpubNavigationPoint {
  String id = '';
  String clazz = '';
  String playOrder = '';
  List<EpubNavigationLabel> navigationLabels = [];
  EpubNavigationContent content = EpubNavigationContent();
  List<EpubNavigationPoint> childNavigationPoints = [];
}
