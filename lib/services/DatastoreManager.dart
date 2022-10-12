import 'dart:convert';
import 'dart:io';

import 'package:mrdqa_tool/Handlers/ApiResponseHandler.dart';
import 'package:mrdqa_tool/models/DataStore.dart';
import 'package:http/http.dart' as http;
import 'package:mrdqa_tool/models/DatastorePayload.dart';
import 'SecurityManager.dart';

class DatastoreManager {
  Map<String, String> _configs;
  List<DataStore> _dataStore = [];
  String _encoded;
  final ApiResponseHandler _apiResponseHandler = ApiResponseHandler();
  final SecurityManager _securityManager = new SecurityManager();

  DatastoreManager(this._configs){
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    _encoded = base64Url.encode(utf8.encode(credentials));
  }

  Future<List<dynamic>> get({String namespace = 'MRDQA'}) async {
    String endPoint = "/api/dataStore/$namespace";
    List<dynamic> res;

    try {
      var response = await http.get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
          headers: {"Accept": "application/json", "Authorization": "BASIC $_encoded"});
      if (response.statusCode == 200) {
        res = json.decode(response.body);

        return res;
      } else
        _apiResponseHandler.returnResponse(response);
    } on SocketException {
      //throw FetchDataException('No Internet connection or server cannot be reached');
      print("Communication error");
    }
    return res;
  }

  Future<dynamic> getValue(String key, {String namespace = 'MRDQA'}) async {
    String endPoint = "/api/dataStore/$namespace/$key";
    dynamic res;

    try {
      var response = await http.get(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
          headers: {"Accept": "application/json", "Authorization": "BASIC $_encoded"});
      if (response.statusCode == 200) {
        res = json.decode(response.body);

        return res;
      } else
        _apiResponseHandler.returnResponse(response);
    } on SocketException {
      //throw FetchDataException('No Internet connection or server cannot be reached');
      print("Communication error");
    }
    return res;
  }

  Future<http.Response> create (String key, dynamic payload, {String method = "post", String namespace = "MRDQA"}) async {
    String endPoint = "/api/dataStore/$namespace/$key";
    var body = jsonEncode(payload);
    var response;
    if (method == "post") {
      response = await http.post(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
          headers: {"Content-Type": "application/json", "Authorization": "BASIC $_encoded"}, body: body);
    } else {
      response = await http.put(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
          headers: {"Content-Type": "application/json", "Authorization": "BASIC $_encoded"}, body: body);
    }
    return response;
  }

  Future<http.Response> delete(String key, {String namespace = "MRDQA"}) async {
    String endPoint = "/api/dataStore/$namespace/$key";
    var response = await http.delete(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
        headers: {"Accept": "application/json", "Authorization": "BASIC $_encoded"});

    return response;
  }
}