import 'dart:convert';
import 'dart:io';

class LocalJsonStore {
  const LocalJsonStore();

  Future<Map<String, dynamic>?> readObject(String fileName) async {
    final file = await _file(fileName);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    if (content.trim().isEmpty) return null;
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> writeObject(String fileName, Map<String, dynamic> value) async {
    final file = await _file(fileName);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(value),
      flush: true,
    );
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }

  Future<List<dynamic>?> readList(String fileName) async {
    final file = await _file(fileName);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    if (content.trim().isEmpty) return null;
    return jsonDecode(content) as List<dynamic>;
  }

  Future<void> writeList(String fileName, List<dynamic> value) async {
    final file = await _file(fileName);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(value),
      flush: true,
    );
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }

  Future<File> _file(String fileName) async {
    final root = Platform.environment['APPDATA'] ?? Directory.current.path;
    final directory = Directory('$root${Platform.pathSeparator}UniHostel');
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }
}
