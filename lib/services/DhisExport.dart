import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mrdqa_tool/models/Payload.dart';
import 'SecurityManager.dart';

/// This Service class exports data to DHIS2 Tracker Event or a Dataset
class DhisExport {
  /// The string used for encoding DHIS2 credentials
  String _encoded;

  /// The program UID as assigned by DHIS2
  String _program;

  /// Map containing general app configurations. See Config object for more details.
  Map<String, String> _configs;

  /// The security manager.
  final SecurityManager _securityManager = new SecurityManager();
  DhisExport(this._configs){
    String credentials = "${this._configs['username']}:${_securityManager.decrypt(this._configs['password'])}";
    _encoded = base64Url.encode(utf8.encode(credentials));
    _program = _configs['program'];
  }
  /// Exports payload of type [event or dataset] to a DHIS2 Event Tracker and Dataset
  Future<http.Response> postRequest (Payload payload, String type) async {
    switch (type) {
      case 'event':
        String endPoint ="/api/events";
        //payload.setProgram(_program);
        var body = json.encode(payload);
        var response = await http.post(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
            headers: {"Content-Type": "application/json", "Authorization": "BASIC ${_encoded}"},
            body: body
        );
        return response;
      case 'dataset':
        String endPoint = "/api/dataValueSets";
        var body = json.encode(payload);
        print("${this._configs['baseUrl'] + endPoint}");
        print(body);
        var response = await http.post(Uri.encodeFull("${this._configs['baseUrl'] + endPoint}"),
            headers: {"Content-Type": "application/json", "Authorization": "BASIC ${_encoded}"},
            body: body
        );
        return response;
    }
  }
}