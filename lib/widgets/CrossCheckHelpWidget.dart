import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CrossCheckHelpWidget extends StatefulWidget {
  const CrossCheckHelpWidget({Key key}) : super(key: key);

  @override
  _CrossCheckHelpWidgetState createState() => _CrossCheckHelpWidgetState();
}

class _CrossCheckHelpWidgetState extends State<CrossCheckHelpWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      /*drawer: Drawer(
        child: MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),*/
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: FutureBuilder(
            future: rootBundle.loadString('assets/cross_checks_help_text.md'),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot){

              if (snapshot.hasData){
                return Markdown(
                  data: snapshot.data,
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
