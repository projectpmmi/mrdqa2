import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:overlay_support/overlay_support.dart';
import '../menus/MenuManager.dart';
import '../routes/Routes.dart';

class LandingPage extends StatelessWidget {
  final ConfigManager configManager;

  LandingPage(this.configManager);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malaria RDQA'),
      ),
      drawer: Drawer(
        child: new MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/landing_page.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*class LandingPage extends StatefulWidget {
  final ConfigManager configManager;
  const LandingPage(this.configManager);

  @override
  _LandingPageState createState() => _LandingPageState(this.configManager);
}

class _LandingPageState extends State<LandingPage> {
  final ConfigManager configManager;
  bool isInternet = false;
  _LandingPageState(this.configManager);

  @override
  void initState() {
    Future<bool> hasInternet = InternetConnectionChecker().hasConnection;
    print("Calling me");
    hasInternet.then((value) {
      print(value);
      isInternet = value;
      print("####");
      final internetMsg = value ? 'Internet' : 'No Internet';
      final internetMsgColor = value ? Colors.green : Colors.red;
      showSimpleNotification(Text('$internetMsg', style: TextStyle(color: Colors.white, fontSize: 20),), background: internetMsgColor);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malaria RDQA'),
      ),
      drawer: Drawer(
        child: new MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/landing_page.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/

