import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';

class MenuManager {
  BuildContext context;
  Routes routes;
  final ConfigManager configManager;

  MenuManager(this.context, this.routes, this.configManager);

  Widget getDrawer(){

    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 20)),
        ListTile(
          leading: Icon(FontAwesomeIcons.info),
          title: Text("Instructions"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.instructions, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.signal),
          title: Text("Indicators"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.indicator, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.car),
          title: Text("Supervisions planning"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.supervisionsPlanningList, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.clipboard),
          title: Text("Data Entry"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.supervisionsEntryList, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.chartPie),
          title: Text("Facility dashboards"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.supervisionsFacilityDashboardList, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.clipboard),
          title: Text("Data quality improvement plan"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.supervisionsDqiList, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.fileExport),
          title: Text("Export"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.supervisionsExportList, arguments: this.configManager);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.wrench),
          title: Text("Configuration"),
          onTap: () {
            Navigator.pushReplacementNamed(this.context, this.routes.configRouteName, arguments: this.configManager);
          },
        ),
        Divider(),
      ],
    );
  }

}