import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mrdqa_tool/Exceptions/AppException.dart';
import 'package:mrdqa_tool/Handlers/ApiResponseHandler.dart';
import 'package:mrdqa_tool/models/DataSet.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Program.dart';
import 'package:mrdqa_tool/models/CategoryOptionCombo.dart';

import 'SecurityManager.dart';

/// Responsible for pulling in remote configurations
/// Checks if remote site has metadata package installed
class RemoteConfigManager {
  Map<String, String> _configs;
  List<Indicator> _indicators = [];
  List<Facility> _facilities = [];
  List<DataElement> _dataElements = [];
  List<CategoryOptionCombo> _categoryOptionCombo = [];
  List<Program> _programs = [];
  List<DataSet> _dataSet = [];
  String _encoded;
  final ApiResponseHandler _apiResponseHandler = ApiResponseHandler();
  final SecurityManager _securityManager = new SecurityManager();

  RemoteConfigManager(this._configs) {
    //String credentials = "${this._configs['username']}:${this._configs['password']}";
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    _encoded = base64Url.encode(utf8.encode(credentials));
  }

  Future<List<DataSet>> getDatasetConfig({String code = 'MRDQA_DATA_COLLECTION'}) async {
    String endPoint = "/api/dataSets.json?fields=id,displayName,shortName,code,periodType&paging=false&filter=code:eq:${code}";

    try {
      var response = await http.get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
          headers: {"Accept": "application/json", "Authorization": "BASIC ${_encoded}"});
      if (response.statusCode == 200) {
        _dataSet = [];
        // print("Code: $code; Body: ${response.body}");
        Map<String, dynamic> res = json.decode(response.body);
        res['dataSets'].forEach((v) {
          _dataSet.add(DataSet.fromJson(v));
        });

        return _dataSet;
      } else
        _apiResponseHandler.returnResponse(response);
    } on SocketException {
      //throw FetchDataException('No Internet connection or server cannot be reached');
      print("Communication error");
    }
    return _dataSet;
  }

  /*Future<List<Program>> getProgramConfig({String code = 'MRDQA'}) async {
    String endPoint = "/api/programs.json?fields=id,displayName,shortName,programType&paging=false&filter=code:eq:${code}";

    try{
      var response = await http
          .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${_encoded}"});
      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        res['programs'].forEach((v) {
          _programs.add(Program.fromJson(v));
        });

        return _programs;
      }
      else
        _apiResponseHandler.returnResponse(response);
    } on SocketException {
      //throw FetchDataException('No Internet connection or server cannot be reached');
      print("Communication error");
    }
    return _programs;
  }*/

  Future<List<Indicator>> getIndicatorConfigs(String code) async {
    //api call to Indicator group
    //String endPoint = "/api/indicatorGroups.json?fields=id,displayName,code,indicators[id,displayName,code]&links=false&paging=false&filter=code:eq:${code}";
    String endPoint =
        "/api/indicatorGroups.json?fields=id,displayName,code,indicators[id,displayName,code]&links=false&paging=false&filter=displayName:eq:${code}";
    //fields=id,displayName,code,indicators[id,name,code]&links=false&paging=false&filter=code:eq:Commodities
    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${_encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['indicatorGroups'][0]['indicators'].forEach((v) {
        _indicators.add(Indicator.fromJson(v));
      });
      return _indicators;
    } else {
      throw Exception('Failed to load indicator');
    }
  }

  Future<List<DataElement>> getDataElementConfigs({String code = 'MRDQA_DATA_ELEMENTS'}) async {
    print("this._configs['baseUrl']");
    print(this._configs['baseUrl']);
    print("^^^^^^^^");
    //api call to DataElement group
    // String endPoint =
    //     "/api/dataElementGroups.json?fields=code,dataElements[id,displayName,code,categoryCombo[id,displayName,categoryOptionCombos[id,displayName]]]&links=false&paging=false&filter=code:eq:${code}";
    String endPoint =
        "/api/dataElementGroups.json?fields=code,dataElements[id,displayName,code]&links=false&paging=false&filter=code:eq:${code}";
    print(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"));
    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${_encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      _dataElements = [];
      if (res['dataElementGroups'].isEmpty) {
        return _dataElements;
      }
      res['dataElementGroups'][0]['dataElements'].forEach((v) {
        _dataElements.add(DataElement.fromJson(v));
      });
      return _dataElements;
    } else {
      throw Exception('Failed to load data elements');
    }
  }

  Future<List<Facility>> getFacilityConfigs({String code = 'MRDQA_DATA_COLLECTION'}) async {
    //api call to Facility group
    // String endPoint = "/api/organisationUnitGroups.json?fields=id,displayName,code,organisationUnits[id,displayName,code]&links=false&paging=false&filter=code:eq:${code}";
    //fields=id,displayName,code,organisationUnits[id,name,code]&links=false&paging=false&filter=code:eq:CHC
    String endPoint =
        "/api/dataSets.json?fields=id,displayName,code,organisationUnits[id,displayName,code]&links=false&paging=false&filter=code:eq:${code}";
    print(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${_encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['dataSets'][0]['organisationUnits'].forEach((v) {
        _facilities.add(Facility.fromJsonPackage(v, dhis: false));
      });
      return _facilities;
    } else {
      throw Exception('Failed to load facilities');
    }
  }

  Future<List<CategoryOptionCombo>> getCategoryOptionComboConfigs(String codes) async {
    print("this._configs['baseUrl']");
    print(this._configs['baseUrl']);
    print("^^^^^^^^");
    String endPoint =
        "/api/categoryOptionCombos.json?fields=id,displayName,code&links=false&paging=false&filter=code:in:[$codes]";
    print(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"));
    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${_encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      _categoryOptionCombo = [];
      res['categoryOptionCombos'].forEach((v) {
        _categoryOptionCombo.add(CategoryOptionCombo.fromJson(v));
      });
      return _categoryOptionCombo;
    } else {
      throw Exception('Failed to load category option combos');
    }
  }
}
