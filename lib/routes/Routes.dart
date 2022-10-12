import 'package:mrdqa_tool/pages/ConfigurationPage.dart';
import 'package:mrdqa_tool/pages/SupervisionFacilityDashboardList.dart';
import 'package:mrdqa_tool/pages/TestDatabasePage.dart';
import 'package:mrdqa_tool/pages/DashboardPage.dart';
import 'package:mrdqa_tool/pages/FacilityInformationPage.dart';
import 'package:mrdqa_tool/pages/IndicatorPage.dart';
import 'package:mrdqa_tool/pages/InstructionPage.dart';
import 'package:mrdqa_tool/pages/SupervisionPage.dart';
import 'package:mrdqa_tool/pages/DataEntryPage.dart';
import 'package:mrdqa_tool/forms/IndicatorForm.dart';
import 'package:mrdqa_tool/forms/FacilitySelectionForm.dart';
import 'package:mrdqa_tool/forms/IndicatorSelectionForm.dart';
import 'package:mrdqa_tool/pages/SupervisionPlanningList.dart';
import 'package:mrdqa_tool/pages/SupervisionEntryList.dart';
import 'package:mrdqa_tool/pages/SupervisionDqiList.dart';
import 'package:mrdqa_tool/pages/SupervisionExportList.dart';

class Routes {
  String _instructions = InstructionPage.routeName;
  String _facilityInformation = FacilityInformationPage.routeName;
  String _indicator = IndicatorPage.routeName;
  String _dashboards = DashboardPage.routeName;
  String _supervisions = SupervisionPage.routeName; // not used
  String _databaseTest = TestDatabasePage.routeName;
  String _dataEntry = DataEntryPage.routeName; // not used
  String _addIndicator = IndicatorForm.routeName;
  String _supervisionFacility = FacilitySelectionForm.routeName;
  String _supervisionIndicator = IndicatorSelectionForm.routeName;
  String _configuration = ConfigurationPage.routeName;
  String _supervisionsPlanningList = SupervisionPlanningList.routeName;
  String _supervisionsEntryList = SupervisionEntryList.routeName;
  String _supervisionsDqiList = SupervisionDqiList.routeName;
  String _supervisionsExportList = SupervisionExportList.routeName;
  String _supervisionsFacilityDashboardList = SupervisionFacilityDashboardList.routeName;

  String get instructions => _instructions;

  String get facilityInformation => _facilityInformation;

  String get indicator => _indicator;

  String get dashboards => _dashboards;

  String get supervisions => _supervisions;

  String get databaseTest => _databaseTest;

  String get dataEntry => _dataEntry;

  String get addIndicator => _addIndicator;

  String get supervisionFacility => _supervisionFacility;

  String get supervisionIndicator => _supervisionIndicator;

  String get configRouteName => _configuration;

  String get supervisionsPlanningList => _supervisionsPlanningList;

  String get supervisionsEntryList => _supervisionsEntryList;

  String get supervisionsDqiList => _supervisionsDqiList;

  String get supervisionsExportList => _supervisionsExportList;

  String get supervisionsFacilityDashboardList => _supervisionsFacilityDashboardList;
}
