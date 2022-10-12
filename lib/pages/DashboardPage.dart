import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:mrdqa_tool/widgets/Dashboard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/routes/Routes.dart';

class DashboardPage extends StatefulWidget {
  static const String routeName = '/dashboards';
  final ConfigManager configManager;
  Supervision selectedSupervision;

  DashboardPage(this.configManager, this.selectedSupervision);

  @override
  _DashboardPageState createState() => _DashboardPageState(this.configManager, this.selectedSupervision);
}

class _DashboardPageState extends State<DashboardPage> {
  final ConfigManager configManager;
  Supervision selectedSupervision;
  List<Facility> _facilities = [];
  List<Facility> _selectedFacilities = [];

  _DashboardPageState(this.configManager, this.selectedSupervision);

  @override
  void initState() {
    // todo all selected facilities here.
    _getConfig().then((value) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Dashboard"),
        ),
        drawer: Drawer(
          child: MenuManager(context, Routes(), this.configManager).getDrawer(),
        ),
        body: _selectedFacilities.isNotEmpty ? Dashboard(this.configManager, this.selectedSupervision, _selectedFacilities) : Container());
  }

  List<Facility> _getSelectedFacilities(List<Facility> facilities, List<SupervisionFacilities> supervisionFacilities) {
    List<Facility> result = [];

    supervisionFacilities.forEach((sup) {
      facilities.forEach((fac) {
        if (fac.id == sup.facilityId) {
          result.add(fac);
        }
      });
    });

    return result;
  }

  Future<void> _getConfig() async {
    _facilities = await configManager.getSupervisionConfig('facility');
    configManager.getDataRowsBySupervision('supervisionfacilities', widget.selectedSupervision.id).then((value) {
      setState(() {
        _selectedFacilities = _getSelectedFacilities(_facilities, value);
      });
    });
  }
}
