import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';


class InstructionPage extends StatelessWidget {

  static const String routeName = '/instructions';
  final ConfigManager configManager;

  InstructionPage(this.configManager);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      drawer: Drawer(
        child: MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: FutureBuilder(
            future: rootBundle.loadString('assets/instructions.md'),
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