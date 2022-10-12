import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/models/Visit.dart';
import '../models/Facility.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:intl/intl.dart';

class FacilitySelectionForm extends StatefulWidget {
  static String routeName = '/supervisions/facility';

  // Declare a field that holds the RecordObject.
  final Supervision supervision;
  final List<Facility> facilities; // All facilities
  List<Facility> selectedFacilities; // Selected facilities

  // In the constructor, require a RecordObject.
  FacilitySelectionForm({Key key, @required this.supervision, @required this.facilities, @required this.selectedFacilities}) : super(key: key);

  @override
  _FacilitySelectionFormState createState() => _FacilitySelectionFormState();
}

class _FacilitySelectionFormState extends State<FacilitySelectionForm> {
  final ConfigManager configManager = new ConfigManager();

  //Map<String, Visit> visits; // facilityId and visit.
  Map<int, Visit> _visits;
  SupervisionFacilities _supervisionFacilities;
  DateTime controllerDate;
  String controllerTeamLead;
  bool _dataEntryStatus;

  @override
  void initState() {
    _visits = {};
    if (widget.facilities != null && widget.selectedFacilities != null) {
      print("Things exists");
      _checkSelectedFacilities();
      _setVisits(widget.supervision.id);
    } else {
      widget.selectedFacilities = new List<Facility>();
    }

    controllerDate = DateTime(2020, 1, 1);
    controllerTeamLead = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        // The number of tabs / content sections to display.
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Check facilities for visit"),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  Navigator.pop(context, widget.selectedFacilities);
                });
              },
            ),
          ),
          // body: TabBarView(children: [
          body: Scaffold(
            body: Center(
              //child: _buildListView(mapAllFacilities),
              child: widget.facilities != null ? _buildListView() : CircularProgressIndicator(),
            ),
          ),
        ));
  }

  Widget _buildListView() {
    return widget.facilities != null
        ? ListView(
            children: widget.facilities
                .asMap()
                .map((int index, Facility facility) => MapEntry(
                    index,
                    CheckboxListTile(
                      title: Text(facility.name),
                      subtitle: _visits[facility.id] != null
                          ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Team lead: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_visits[facility.id].teamLead),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(DateFormat.yMMMd('en_US').format(_visits[facility.id].date)),
                                ],
                              ),
                            ])
                          : Container(child: Text('Not selected')),
                      value: facility.isSupervisable,
                      onChanged: (bool val) async {
                        if (val == true) {
                          Visit visit = new Visit(supervisionId: widget.supervision.id, facilityId: facility.id);
                          await _addVisitForm(context, index, facility, visit);
                        } else {
                          _dataEntryStatus = await _checkFacilityHasData(widget.supervision.id, facility.id);
                          if (!_dataEntryStatus)
                            await _removeFacilityAndVisit(index, facility);
                          else
                            _dataExistInfo(context);
                        }
                      },
                    )))
                .values
                .toList(),
          )
        : Container(
            child: Text('Configure facilities first.'),
          );
  }

  Future<void> _addFacilityAndVisit(int index, Facility facility, Visit visit) {
    widget.facilities[index].isSupervisable = true;
    _visits[visit.facilityId] = visit;
    _supervisionFacilities = new SupervisionFacilities(supervisionId: widget.supervision.id, facilityId: facility.id);
    configManager.saveRowData('supervisionfacility', _supervisionFacilities).then((value) {
      if (widget.selectedFacilities != null) {
        widget.selectedFacilities.add(facility);
      } else {
        widget.selectedFacilities = <Facility>[facility];
      }
      configManager.saveRowData('visit', visit);
    });
    setState(() {});
  }

  void _dataExistInfo(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
              title: Text('This facility has data', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('Please clean the existing data before removing this facility'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ]);
        });
  }

  Future<void> _removeFacilityAndVisit(int index, Facility facility) {
    widget.facilities[index].isSupervisable = false;
    _setVisits(widget.supervision.id);
    configManager.clearRowOfSupervisionFacility('visit', widget.supervision.id, facility.id).then((value) {
      configManager.clearRowOfSupervisionFacility('supervisionfacility', widget.supervision.id, facility.id);
      _visits.remove(facility.id);
      setState(() {});
    });
    if (widget.selectedFacilities != null) {
      widget.selectedFacilities.remove(facility);
    }
    setState(() {});
  }

  Future<void> _addVisitForm(BuildContext context, int index, Facility facility, Visit visit) async {
    GlobalKey<FormState> _addvisitformkey = GlobalKey<FormState>();

    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _teamLeadController = TextEditingController();

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Facility visit'),
              content: SingleChildScrollView(
                  child: Form(
                key: _addvisitformkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _teamLeadController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Enter the team lead name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'You need a team lead name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: const Text('Visit date'),
                                subtitle: Text(
                                  'Enter the date of visit',
                                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              visit.date != null
                                  ? Expanded(child: Text('${DateFormat.yMMMd('en_US').format(visit.date)}'))
                                  : Expanded(child: Text('${DateFormat.yMMMd('en_US').format(DateTime.now())}')),
                              TextButton(
                                onPressed: () async {
                                  DateTime newDate = DateTime.now();
                                  setState(() {
                                    visit.date = newDate;
                                  });
                                  newDate = await _selectDate(context, visit);
                                  if (newDate != null) {
                                    setState(() {
                                      visit.date = newDate;
                                      // _changed = true;
                                    });
                                  }
                                },
                                child: Text('Choose'),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )),
              actions: <Widget>[
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_addvisitformkey.currentState.validate() && visit.date != null) {
                      visit.teamLead = _teamLeadController.text;
                      _addFacilityAndVisit(index, facility, visit);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Future<dynamic> _selectDate(BuildContext context, Visit visit) async {
    final DateTime picked = await showDatePicker(context: context, initialDate: visit.date, firstDate: DateTime(2020, 1), lastDate: DateTime(2050));
    if (picked != null && picked != visit.date) {
      return picked;
    }

    return null;
  }

  Future<bool> _checkFacilityHasData(int supervisionId, int facilityId) async {
    _dataEntryStatus = false;
    int count = 0;

    count = await configManager.checkFacilityDataEntryStatus('entrycompletenessmonthlyreport', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entrytimelinessmonthlyreport', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entrydataelementcompleteness', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entrysourcedocumentcompleteness', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entrydataaccuracy', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entrycrosscheckab', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entryconsistencyovertime', supervisionId, facilityId);
    count = count + await configManager.checkFacilityDataEntryStatus('entrysystemassessment', supervisionId, facilityId);

    if (count > 0)
      return true;
    else
      return false;
  }

  Future<Void> _setVisits(int supervisionId) async {
    configManager.getDataRowsBySupervision('visits', supervisionId).then((value) {
      print("Visits: $value");
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          _visits[value[i].facilityId] = value[i];
        }
        setState(() {});
      }
    });
  }

  Future<void> _checkSelectedFacilities() async {
    for (var i = 0; i < widget.selectedFacilities.length; i++) {
      for (var j = 0; j < widget.facilities.length; j++) {
        if (widget.facilities[j].id == widget.selectedFacilities[i].id) {
          widget.facilities[j].isSupervisable = true;
        }
      }
    }
    setState(() {});
  }
}
