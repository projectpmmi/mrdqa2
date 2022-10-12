import 'package:http/http.dart' as http;
import 'package:mrdqa_tool/models/Facility.dart';
import 'dart:convert';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/OrgUnitLevel.dart';
import 'SecurityManager.dart';

/// General service for handling and processing requests from DHIS2
class DhisManager {
  /// Map containing Config object parameters. See Config object for details.
  Map<String, String> _configs;

  /// This list will contain indicators pulled from DHIS2
  List<Indicator> indicators = [];

  /// This list will contain organisation units pulled from DHIS2
  List<OrgUnitLevel> orgUnitLevels = [];

  /// This list will contain facilities pulled from DHIS2
  List<Facility> facilities = [];

  /// This list will contain data elements pulled from DHIS2
  List<DataElement> dataElements = [];

  /// The security manager.
  final SecurityManager _securityManager = new SecurityManager();

  DhisManager(this._configs);

  ///@todo to be removed.
  Future<String> getData(String endPoint) async {
    String credentials = "${this._configs['username']}:${this._configs['password']}";
    String encoded = base64Url.encode(utf8.encode(credentials));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    return response.body;
  }

  Future<List<Indicator>> getIndicators() async {
    String endPoint = "/api/indicators.json";
    String credentials = "${this._configs['username']}:${this._configs['password']}";
    String encoded = base64Url.encode(utf8.encode(credentials));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['indicators'].forEach((v) {
        indicators.add(Indicator.fromJson(v));
      });
      return indicators;
    } else {
      throw Exception('Failed to load indicator');
    }
  }

  Future<List<Map<String, dynamic>>> getOrgUnitLevels() async {
    List<Map<String, dynamic>> orgLevels = new List<Map<String, dynamic>>();

    String endPoint = "/api/organisationUnitLevels.json?fields=id,name,displayName,level";
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    String encoded = base64Url.encode(utf8.encode(credentials));

    print("Get level: ${this._configs['baseUrl'] + endPoint}");
    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['organisationUnitLevels'].forEach((v) {
        Map<String, dynamic> map = new Map<String, dynamic>();
        map['id'] = v['id'];
        map['name'] = v['displayName'];
        map['level'] = v['level'].toString();
        orgLevels.add(map);
      });
      print("Success: $orgLevels");

      return orgLevels;
    } else {
      print("Failed to load facilities");
      throw Exception('Failed to load org unit levels');
    }
  }

  Future<Indicator> getIndicator(String indicatorUID) async {
    String endPoint = "/api/indicators/${indicatorUID}.json";
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    String encoded = base64Url.encode(utf8.encode(credentials));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      return Indicator.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load indicator');
    }
  }

  Future<List<Facility>> getFacilities() async {
    String endPoint = "/api/organisationUnits.json?pageSize=8";
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    String encoded = base64Url.encode(utf8.encode(credentials));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['organisationUnits'].forEach((v) {
        facilities.add(Facility.fromJson(v));
      });
      return facilities;
    } else {
      throw Exception('Failed to load Facilities');
    }
  }

  Future<List<Facility>> searchFacilities(String search) async {
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    String encoded = base64Url.encode(utf8.encode(credentials));
    int level = int.parse(this._configs['level']);
    String endPoint = "/api/organisationUnits.json?fields=id,name,displayName,level,parent[displayName],dataSets[code,displayName]&query=$search&level=${level + 1}";
    print("${this._configs['baseUrl'] + endPoint}");

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['organisationUnits'].forEach((v) {
        var r = hasDataSet(v['dataSets'], 'MDQA_DATA_COLLECTION');
        if(r == null)
          facilities.add(Facility.fromJsonPackage(v, dhis: true));
        else
          facilities.add(Facility.fromJsonPackage(v, dhis: false));
      });

      return facilities;
    } else {
      throw Exception('Failed to load Facilities');
    }
  }

  dynamic hasDataSet(dynamic dataSets, String code) {
    var result = dataSets.firstWhere((element) => element['code'] == code, orElse: () => null);

    return result;
  }

  Future<List<Indicator>> searchIndicators(String search) async {
    String endPoint = "/api/indicators?query=${search}";
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";

    String encoded = base64Url.encode(utf8.encode(credentials));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['indicators'].forEach((v) {
        indicators.add(Indicator.fromJson(v));
      });
      return indicators;
    } else {
      throw Exception('Failed to load indicators');
    }
  }

  Future<List<DataElement>> searchDataElements(String search) async {
    String endPoint = "/api/dataElements?query=$search";
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    String encoded = base64Url.encode(utf8.encode(credentials));

    var response = await http
        .get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"), headers: {"Accept": "application/json", "Authorization": "BASIC ${encoded}"});

    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      res['dataElements'].forEach((v) {
        dataElements.add(DataElement.fromJson(v));
      });
      return dataElements;
    } else {
      throw Exception('Failed to load indicators');
    }
  }
}
