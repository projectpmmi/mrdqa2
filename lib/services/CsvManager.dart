import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// CSV Load and read manager service
class CsvManager {
  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String filePath = '$path/data.csv';
    print(filePath.toString());
    return File('$path/data.csv').create();
  }

  /// Loads and reads csv file named [csvFileName]
  Future<List<dynamic>> loadCSV(String csvFileName) async {
    final _rawData = await rootBundle.loadString("assets/${csvFileName}");
    List<dynamic> _listData = CsvToListConverter().convert(_rawData);
    return _listData;
  }

  void createCsv(List<List<dynamic>> data) async {
    File f = await _localFile;
    String csv = const ListToCsvConverter().convert(data);
    f.writeAsString(csv);
  }

  Future<String> getFilePath() async {
    final path = await _localPath;

    return '$path/data.csv';
  }
}
