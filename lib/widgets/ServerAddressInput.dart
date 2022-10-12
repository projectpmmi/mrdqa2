import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerAddressInput extends StatefulWidget {
  //const ServerAddressInput({Key key}) : super(key: key);
  TextEditingController _baseUrlTextController;

  ServerAddressInput(this._baseUrlTextController);

  @override
  _ServerAddressInputState createState() => _ServerAddressInputState(this._baseUrlTextController);
}

class _ServerAddressInputState extends State<ServerAddressInput> {
  final TextEditingController _baseUrlTextController;
  final _focusNode = FocusNode();
  String _url;

  _ServerAddressInputState(this._baseUrlTextController) {
    print(this._baseUrlTextController.text);
    print("HHHHH");
  }
  @override
  void initState(){
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus){
        print("verify URL");
        print("URL: ${this._baseUrlTextController.text}");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.cloud_upload_rounded),
        hintText: "DHIS2 Base URL without trailing /",
        labelText: "DHIS2 URL",
      ),
      controller: _baseUrlTextController,
      autofocus: true,
      focusNode: _focusNode
      //textInputAction: TextInputAction.done,
    );
  }
}
