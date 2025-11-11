import 'metadata_contributor.dart';
import 'metadata_creator.dart';
import 'metadata_date.dart';
import 'metadata_identifier.dart';
import 'metadata_meta.dart';

class EpubMetadata {
  List<String> titles = [];
  List<EpubMetadataCreator> creators = [];
  List<String> subjects = [];
  String description = '';
  List<String> publishers = [];
  List<EpubMetadataContributor> contributors = [];
  List<EpubMetadataDate> dates = [];
  List<String> types = [];
  List<String> formats = [];
  List<EpubMetadataIdentifier> identifiers = [];
  List<String> sources = [];
  List<String> languages = [];
  List<String> relations = [];
  List<String> coverages = [];
  List<String> rights = [];
  List<EpubMetadataMeta> metaItems = [];
}
