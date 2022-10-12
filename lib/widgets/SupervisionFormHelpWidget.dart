import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SupervisionFormHelpWidget extends StatefulWidget {
  const SupervisionFormHelpWidget({Key key}) : super(key: key);

  @override
  _SupervisionFormHelpWidgetState createState() => _SupervisionFormHelpWidgetState();
}

class _SupervisionFormHelpWidgetState extends State<SupervisionFormHelpWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: FutureBuilder(
            future: rootBundle.loadString('assets/supervision_form_help_text.md'),
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
