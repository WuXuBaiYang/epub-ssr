class EnumFromString<T> {
  List<T> enumValues;

  EnumFromString(this.enumValues);

  T? get(String value, [T? def]) {
    value = '$T.$value';
    try {
      var x = enumValues.firstWhere(
        (f) => f.toString().toUpperCase() == value.toUpperCase(),
      );
      return x;
    } catch (_) {}
    return def;
  }
}
