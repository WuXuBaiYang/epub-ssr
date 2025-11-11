class ZipPathUtils {
  static String getDirectoryPath(String filePath) {
    final lastSlashIndex = filePath.lastIndexOf('/');
    if (lastSlashIndex == -1) return '';
    return filePath.substring(0, lastSlashIndex);
  }

  static String combine(String? directory, String fileName) {
    if (directory == null || directory == '') return fileName;
    return directory + '/' + fileName;
  }
}
