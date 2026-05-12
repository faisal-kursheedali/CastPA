import 'dart:convert';

List<String> parseStringList(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
  } catch (_) {}
  return [];
}

String encodeStringList(List<String> list) => jsonEncode(list);

List<double> parseDoubleList(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => (e as num).toDouble()).toList();
    }
  } catch (_) {}
  return [];
}

String encodeDoubleList(List<double> list) => jsonEncode(list);

List<List<double>> parseDoubleMatrix(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((row) {
        if (row is List) {
          return row.map((e) => (e as num).toDouble()).toList();
        }
        return <double>[];
      }).toList();
    }
  } catch (_) {}
  return [];
}

String encodeDoubleMatrix(List<List<double>> matrix) => jsonEncode(matrix);

Map<String, List<String>> parseStringMap(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is Map) {
      return decoded.map(
        (k, v) => MapEntry(
          k.toString(),
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    }
  } catch (_) {}
  return {};
}

String encodeStringMap(Map<String, List<String>> map) => jsonEncode(map);
