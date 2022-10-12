import 'package:flutter/material.dart';
import 'package:mrdqa_tool/forms/FacilitySelectionForm.dart';
import 'package:mrdqa_tool/forms/IndicatorForm.dart';
import 'package:mrdqa_tool/pages/ConfigurationPage.dart';
import 'package:mrdqa_tool/pages/SupervisionEntryList.dart';
import 'package:mrdqa_tool/pages/SupervisionFacilityDashboardList.dart';
import 'package:mrdqa_tool/pages/SupervisionPlanningList.dart';
import 'package:mrdqa_tool/pages/TestDatabasePage.dart';
import 'package:mrdqa_tool/pages/FacilityInformationPage.dart';
import 'package:mrdqa_tool/pages/IndicatorPage.dart';
import 'package:mrdqa_tool/pages/InstructionPage.dart';
import 'package:mrdqa_tool/forms/IndicatorSelectionForm.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:mrdqa_tool/pages/SupervisionDqiList.dart';
import 'package:mrdqa_tool/pages/SupervisionExportList.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/instructions':
        if (args is ConfigManager) {
          return MaterialPageRoute(builder: (_) => InstructionPage(args));
        }
        return _errorRoute();

      case '/facility_information':
        if (args is ConfigManager) {
          return MaterialPageRoute(builder: (_) => FacilityInformationPage(args));
        }
        return _errorRoute();

      case '/indicators':
        if (args is ConfigManager) {
          return MaterialPageRoute(builder: (_) => IndicatorPage(args));
        }
        return _errorRoute();

      case '/supervisions_planning_list':
        if (args is ConfigManager){
          return MaterialPageRoute(builder: (_) => SupervisionPlanningList(args));
        }
        return _errorRoute();

      case '/test_database': //For TESTING PURPOSES ONLY
        return MaterialPageRoute(builder: (_) => TestDatabasePage());

      case '/supervisions_entry_list':
        if (args is ConfigManager){
          return MaterialPageRoute(builder: (_) => SupervisionEntryList(args));
        }
        return _errorRoute();

      case '/supervisions_dqi_list':
        if (args is ConfigManager){
          return MaterialPageRoute(builder: (_) => SupervisionDqiList(args));
        }
        return _errorRoute();

      case '/supervisions_export_list':
        if (args is ConfigManager){
          return MaterialPageRoute(builder: (_) => SupervisionExportList(args));
        }
        return _errorRoute();

      case '/supervisions_facility_dashboard_list':
        if (args is ConfigManager){
          return MaterialPageRoute(builder: (_) => SupervisionFacilityDashboardList(args));
        }
        return _errorRoute();

      case '/indicators/add_indicator':
        return MaterialPageRoute(builder: (_) => IndicatorForm());

      case '/supervisions/facility':
        return MaterialPageRoute(builder: (_) => FacilitySelectionForm());

      case '/supervisions/indicator':
        return MaterialPageRoute(builder: (_) => IndicatorSelectionForm());

      case '/configuration':
        if (args is ConfigManager){
          return MaterialPageRoute(builder: (_) => ConfigurationPage(configManager: args,));
        }

        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Error: "),
        ),
        body: Center(
          child: Text("Error: "),
        ),
      );
    });
  }
}
