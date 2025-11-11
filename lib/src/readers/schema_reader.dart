import 'package:archive/archive.dart';
import 'package:epub_ssr/src/entities/schema.dart';
import 'package:epub_ssr/src/utils/zip_path_utils.dart';
import 'navigation_reader.dart';
import 'package_reader.dart';
import 'root_file_path_reader.dart';

class SchemaReader {
  static EpubSchema readSchema(Archive epubArchive) {
    final rootFilePath = RootFilePathReader.getRootFilePath(epubArchive);
    if (rootFilePath == null) {
      throw Exception('Root file path not found');
    }
    final package = PackageReader.readPackage(epubArchive, rootFilePath);
    final contentDirectoryPath = ZipPathUtils.getDirectoryPath(rootFilePath);
    final navigation = NavigationReader.readNavigation(
      epubArchive,
      contentDirectoryPath,
      package,
    );
    if (navigation == null) {
      throw Exception('navigation not found');
    }
    return EpubSchema()
      ..package = package
      ..navigation = navigation
      ..contentDirectoryPath = contentDirectoryPath;
  }
}
