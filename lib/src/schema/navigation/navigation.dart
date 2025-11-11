import 'doc_author.dart';
import 'doc_title.dart';
import 'head.dart';
import 'list.dart';
import 'map.dart';
import 'page_list.dart';

class EpubNavigation {
  EpubNavigationHead head = EpubNavigationHead();
  EpubNavigationDocTitle docTitle = EpubNavigationDocTitle();
  List<EpubNavigationDocAuthor> docAuthors = [];
  EpubNavigationMap navMap = EpubNavigationMap();
  EpubNavigationPageList pageList = EpubNavigationPageList();
  List<EpubNavigationList> navLists = [];
}
