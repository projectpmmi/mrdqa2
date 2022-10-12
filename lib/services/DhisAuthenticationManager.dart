import 'dart:convert';

import 'package:mrdqa_tool/models/Config.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';

class DhisAuthenticationManager {
  final ConfigManager _configManager = new ConfigManager();

  Map<String, String> authHeaders() {
    Future<Config> _config = _configManager.getConfig();
    _config.then((data) {
      String credentials = "${data.getUsername()}:${data.getPassword()}";
      String encoded = base64Url.encode(utf8.encode(credentials));
      return {"Accept": "application/json", "Authorization": "BASIC ${encoded}"};
    });

    return {};
  }

  Future<String> baseUrl() async {
    Future<Config> _config = _configManager.getConfig();
    _config.then((data) {
      return data.getBaseUrl();
    }, onError: (error) {
      print(error);
    });
    return "";
  }
}
