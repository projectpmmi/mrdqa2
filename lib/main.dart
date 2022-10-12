git import 'package:flutter/material.dart';
import 'package:mrdqa_tool/pages/LandingPage.dart';
import 'package:mrdqa_tool/pages/InstructionPage.dart';
import 'package:mrdqa_tool/routes/RouteManager.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';

void main() {
  runApp(MyApp(new ConfigManager()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final ConfigManager configManager;

  MyApp(this.configManager);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Malaria RDQA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new LandingPage(this.configManager),
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}
