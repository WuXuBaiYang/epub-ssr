import 'guide.dart';
import 'manifest.dart';
import 'metadata.dart';
import 'spine.dart';
import 'version.dart';

class EpubPackage {
  EpubVersion version = EpubVersion.Epub3;
  EpubMetadata metadata = EpubMetadata();
  EpubManifest manifest = EpubManifest();
  EpubSpine spine = EpubSpine();
  EpubGuide? guide;
}
