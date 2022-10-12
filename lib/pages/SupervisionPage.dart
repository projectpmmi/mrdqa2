import 'package:flutter/material.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/DatastorePayload.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/models/SupervisionPeriod.dart';
import 'package:mrdqa_tool/models/SupervisionSection.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import '../models/Indicator.dart';
import '../models/Facility.dart';
import 'package:unicorndial/unicorndial.dart';
import '../forms/FacilitySelectionForm.dart';
import '../forms/IndicatorSelectionForm.dart';
import '../models/SelectedIndicator.dart';
import '../models/CrossCheck.dart';
import '../models/ConsistencyOverTime.dart';
import '../models/DataElementCompleteness.dart';
import '../models/SourceDocumentCompleteness.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:mrdqa_tool/models/Visit.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:uuid/uuid.dart';
import 'package:mrdqa_tool/services/DatastoreManager.dart';
import 'package:mrdqa_tool/models/Config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mrdqa_tool/widgets/SupervisionFormHelpWidget.dart';

class SupervisionPage extends StatefulWidget {
  static String routeName = '/supervisions';
  final ConfigManager configManager;
  Supervision selectedSupervision;

  SupervisionPage(this.configManager, this.selectedSupervision);

  @override
  _SupervisionPageState createState() => _SupervisionPageState(this.configManager, this.selectedSupervision);
}

class _SupervisionPageState extends State<SupervisionPage> {
  final ConfigManager configManager;
  Supervision selectedSupervision;
  List<Facility> selectedFacilities;
  Supervision supervision = Supervision();
  List<Facility> _facilities;
  Map<String, dynamic> planningData = {};
  Map<String, bool> facilitiesMap = {};
  List<SelectedIndicator> selectedIndicators = [];
  List<DataElementCompleteness> dataElementCompleteness = [];
  List<SourceDocumentCompleteness> sourceDocumentCompleteness = [];

  List<SourceDocument> dataSources = [
    SourceDocument(id: 1, name: 'Primary register'),
    SourceDocument(id: 2, name: 'Monthly report'),
    SourceDocument(id: 3, name: 'Laboratory register'),
    SourceDocument(id: 4, name: 'Patient record'),
  ];
  List<Map<String, dynamic>> dataSourceItems = [];

  String _supervisionDescription = 'Empty';
  DateTime _supervisionPeriod;
  String _addButtonLabel = 'Add';
  DateTime selectedPeriod;
  bool _changed;
  Map<String, int> _sectionMap = {
    "I. Completeness/Timeliness": 1,
    "II. Data Accuracy": 2,
    "III. Cross check": 3,
    "IV. Consistency over time": 4,
    "V. System Assessment": 5,
    "VI. Data Quality Improvement": 6
  };
  Map<String, int> _periodMap = {
    "January": 1,
    "February": 2,
    "March": 3,
    "April": 4,
    "May": 5,
    "June": 6,
    "July": 7,
    "August": 8,
    "September": 9,
    "October": 10,
    "November": 11,
    "December": 12
  };

  List<String> _selectedSection = [];
  List<String> _selectedMonths = [];
  List<String> _notSelectedMonths = [];
  Set<String> _a = {};
  Set<String> _b = {};
  Map<String, dynamic> planningObject;
  Map<String, Visit> _visits;
  List<DataElementCompleteness> _dataElementCompleteness;
  List<SourceDocumentCompleteness> _sourceDocumentCompleteness;
  ConsistencyOverTime _consistencyOverTime;
  List<CrossCheck> _crossChecks;
  List<SelectedIndicator> _selectedIndicators;
  FToast _configSaveToast;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _SupervisionPageState(this.configManager, this.selectedSupervision);

  @override
  void initState() {
    if (widget.selectedSupervision != null) {
      _setAllFacilities(widget.selectedSupervision.usePackage);
      setState(() {
        planningData = {widget.selectedSupervision.id.toString(): new Map<String, dynamic>()};
        selectedPeriod = widget.selectedSupervision.period;
        planningData[widget.selectedSupervision.id.toString()] = {
          'selected_facilities': <Facility>[],
        };
      });
      _addPlanningData(widget.selectedSupervision.id).then((value) {
        _updateFields();
      });
    } else {
      _setAllFacilities(null);
      setState(() {
        widget.selectedSupervision = null;
        selectedPeriod = DateTime.now();
        _selectedMonths = [];
        _selectedSection = [];
        _notSelectedMonths = [];
      });
    }
    _visits = {};
    _configSaveToast = FToast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataSourceItems = _buildDataSourceItems();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Supervision planning'),
      ),
      drawer: Drawer(
        child: MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      floatingActionButton: UnicornDialer(
        parentButtonBackground: Colors.blue,
        parentButton: Icon(Icons.settings),
        childButtons: _getProfileMenu(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(children: <Widget>[
        Container(
          height: (5 * MediaQuery.of(context).size.height) / 14,
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              side: new BorderSide(color: Colors.blue, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _informationWidget(),
                ListTile(
                  title: const Text('Supervision details'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                        Divider(),
                        Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _supervisionDescription != null ? Text(_supervisionDescription) : Text('Empty'),
                        Divider(),
                        _supervisionPeriod != null ? Text('${DateFormat.yMMM('en_US').format(_supervisionPeriod)}') : Text('Empty'),
                      ],
                    )
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _buildButtonBar(),
                ]),
              ],
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height / 2,
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
              child: DataTable(
            columns: [
              DataColumn(label: Text('Name (District)')),
              DataColumn(label: Text('UID')),
            ],
            rows: selectedFacilities
                    ?.map((facility) => DataRow(cells: <DataCell>[
                          DataCell(Container(child: facility.name != null ? Text(facility.name) : Text('Empty name'))),
                          DataCell(Container(
                              width: 50, //SET width
                              child: facility.uid != null ? Text(facility.uid) : Text('Empty uid'))),
                        ]))
                    ?.toList() ??
                [],
          )),
        ),
      ]),
    );
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            supervision = await _supervisionForm(context, widget.selectedSupervision);
            setState(() {
              widget.selectedSupervision = supervision;
              _setAllFacilities(widget.selectedSupervision.usePackage);
              planningData = {widget.selectedSupervision.id.toString(): new Map<String, dynamic>()};
              selectedPeriod = supervision.period;
              planningData[widget.selectedSupervision.id.toString()] = {
                'selected_facilities': <Facility>[],
              };

              _updateFields();
            });
          },
          child: Text(_addButtonLabel),
        ),
        isSupervisionReady() == true
            ? TextButton(
                onPressed: () async {
                  await _setPlanningForImport(widget.selectedSupervision.id);
                  if (widget.selectedSupervision != null && _visits.length > 0) {
                    // todo check the role
                    List<int> sectionPlanning;
                    List<int> periodPlaning;
                    _selectedSection.forEach((element) {
                      if (sectionPlanning != null)
                        sectionPlanning.add(_sectionMap[element]);
                      else
                        sectionPlanning = [_sectionMap[element]];
                    });
                    _selectedMonths.forEach((element) {
                      if (periodPlaning != null)
                        periodPlaning.add(_periodMap[element]);
                      else
                        periodPlaning = [_periodMap[element]];
                    });
                    DatastorePayload datastorePayload = DatastorePayload(widget.selectedSupervision, _visits, _dataElementCompleteness,
                        _sourceDocumentCompleteness, _consistencyOverTime, _crossChecks, _selectedIndicators, sectionPlanning, periodPlaning);
                    Future<Config> config = configManager.getConfig();
                    config.then((data) async {
                      Map<String, String> configs = new Map();
                      configs['baseUrl'] = data.getBaseUrl();
                      configs['username'] = data.getUsername();
                      configs['password'] = data.getPassword();
                      DatastoreManager datastoreManager = new DatastoreManager(configs);
                      var res = await datastoreManager.create(widget.selectedSupervision.uid, datastorePayload);
                      if (res.statusCode == 201) {
                        _showToast(_scaffoldKey.currentContext, "Your planning is successfully exported!", "success");
                      } else {
                        if (res.statusCode == 409) {
                          var res = await datastoreManager.create(widget.selectedSupervision.uid, datastorePayload, method: "");
                          if (res.statusCode == 200) {
                            _showToast(_scaffoldKey.currentContext, "Your planning is successfully updated!", "success");
                          } else {
                            _showToast(_scaffoldKey.currentContext, "Failed make sure your planning is completed!", "");
                          }
                        }
                      }
                    });
                  } else {
                    _showToast(_scaffoldKey.currentContext, "Failed! your planning is not ready", "");
                  }
                },
                child: Text("Push/Update"),
              )
            : Container(),
      ],
    );
  }

  List<UnicornButton> _getProfileMenu() {
    List<UnicornButton> children = [];
    String indicator = 'Indicator';
    String facility = 'Facility';

    // Add Children here
    children.add(_profileOption(
        iconData: Icons.data_usage,
        label: facility,
        onPressed: () {
          _navigateAndFacilitySelection(context);
        }));
    children.add(_profileOption(
        iconData: Icons.book,
        label: indicator,
        onPressed: () {
          _navigateAndIndicatorSelection(context);
        }));

    return children;
  }

  _navigateAndFacilitySelection(BuildContext context) async {
    List<Facility> selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilitySelectionForm(
            supervision: widget.selectedSupervision,
            facilities: _facilities,
            selectedFacilities: planningData[widget.selectedSupervision.id.toString()]['selected_facilities']),
      ),
    );
    setState(() {
      planningData[widget.selectedSupervision.id.toString()]['selected_facilities'] = selected;
      selectedFacilities = selected;
    });
  }

  _navigateAndIndicatorSelection(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndicatorSelectionForm(supervision: widget.selectedSupervision, selectedSection: _selectedSection),
      ),
    );
  }

  Widget _profileOption({IconData iconData, String label, Function onPressed}) {
    bool status = false;
    if (label == "Facility" && widget.selectedSupervision != null) {
      status = true;
    } else if (label == "Indicator" && _selectedSection.length > 0) {
      status = true;
    }
    return status
        ? UnicornButton(
            hasLabel: true,
            labelText: label,
            labelBackgroundColor: Colors.blue,
            labelColor: Colors.black,
            currentButton: FloatingActionButton(
              heroTag: label,
              backgroundColor: Colors.blue,
              mini: true,
              child: Icon(iconData),
              onPressed: onPressed,
            ))
        : UnicornButton(
            hasLabel: true,
            labelText: label == "Facility" ? "Add supervision first!" : "Check sections first!",
            labelBackgroundColor: Colors.blue,
            labelColor: Colors.red,
            currentButton: FloatingActionButton(
              heroTag: label == "Facility" ? "Add supervision first!" : "Check sections first!",
              backgroundColor: Colors.blue,
              mini: true,
              child: Icon(iconData),
            ));
  }

  Future<Supervision> _supervisionForm(BuildContext context, supervision) async {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    _changed = false;
    bool _packageValue = false;
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _descriptionController = TextEditingController();
          if (supervision != null) {
            _descriptionController.text = supervision.description;
            selectedPeriod = supervision.period;
            _packageValue = supervision.usePackage;
          } else {
            supervision = new Supervision();
          }
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
                child: AlertDialog(
              title: Text('Supervision form'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Form(
                        key: _formkey,
                        child: Column(children: <Widget>[
                          Container(
                            child: Column(
                              children: [
                                _supervisionFormInformationWidget(),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Name'),
                                  controller: _descriptionController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'The Supervision should have a name';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    supervision.setDescription(val);
                                    _changed = true;
                                  },
                                ),
                                Divider(),
                                CheckboxListTile(
                                  title: Text("Use a DHIS2 Package"),
                                  value: _packageValue,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      _packageValue = newValue;
                                      supervision.setUsePackage(newValue);
                                      _changed = true;
                                    });
                                  },
                                  //controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                                ),
                                Divider(),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        title: const Text('Supervision period'),
                                      ),
                                      Text('${DateFormat.yMMM('en_US').format(selectedPeriod)}'),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          DateTime newDate = DateTime.now();
                                          newDate = await _selectDate(context);
                                          if (newDate != null) {
                                            setState(() {
                                              selectedPeriod = newDate;
                                              _changed = true;
                                            });
                                          }
                                        },
                                        child: Text('Choose'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(children: [
                            Row(
                              children: [
                                Flexible(
                                  child: ListTile(
                                    title: const Text('Reporting periods'),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              height: 120,
                              //margin: const EdgeInsets.all(8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  side: new BorderSide(color: Colors.blue, width: 2.0),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                elevation: 3,
                                margin: EdgeInsets.all(4),
                                child: SingleChildScrollView(
                                    child: new CheckboxGroup(
                                        labels: <String>[
                                      "January",
                                      "February",
                                      "March",
                                      "April",
                                      "May",
                                      "June",
                                      "July",
                                      "August",
                                      "September",
                                      "October",
                                      "November",
                                      "December"
                                    ],
                                        checked: _selectedMonths != null ? _selectedMonths : [],
                                        disabled: (_notSelectedMonths != null && _notSelectedMonths.length < 10) ? _notSelectedMonths : [],
                                        onChange: (bool isChecked, String label, int index) {
                                          if (isChecked == true) {
                                            setState(() {
                                              _selectedMonths.add(label);
                                              if (_selectedMonths.length > 2) {
                                                _a = _periodMap.keys.toList().toSet();
                                                _b = _selectedMonths.toSet();
                                                _notSelectedMonths = _a.difference(_b).toList();
                                              }
                                            });
                                          } else {
                                            setState(() {
                                              _selectedMonths.remove(label);
                                              if (_selectedMonths.length < 3) {
                                                _a = _periodMap.keys.toList().toSet();
                                                _b = _selectedMonths.toSet();
                                                _notSelectedMonths = _a.difference(_b).toList();
                                              }
                                            });
                                          }
                                          _changed = true;
                                        },
                                        onSelected: (List<String> checked) {})),
                                // ),
                              ),
                            )
                          ]),
                          Column(children: [
                            Row(
                              children: [
                                Flexible(
                                  child: ListTile(
                                    title: const Text('Assessment sections'),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              height: 120,
                              //margin: const EdgeInsets.all(8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  side: new BorderSide(color: Colors.blue, width: 2.0),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                elevation: 3,
                                margin: EdgeInsets.all(4),
                                child: SingleChildScrollView(
                                    child: new CheckboxGroup(
                                        labels: <String>[
                                      "I. Completeness/Timeliness",
                                      "II. Data Accuracy",
                                      "III. Cross check",
                                      "IV. Consistency over time",
                                      "V. System Assessment",
                                      "VI. Data Quality Improvement",
                                    ],
                                        checked: _selectedSection != null ? _selectedSection : [],
                                        onChange: (bool isChecked, String label, int index) {
                                          setState(() {
                                            if (isChecked == true) {
                                              _selectedSection.add(label);
                                            } else {
                                              _selectedSection.remove(label);
                                            }
                                            _changed = true;
                                          });
                                        },
                                        onSelected: (List<String> checked) {})),
                                // ),
                              ),
                            )
                          ]),
                        ])),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(supervision),
                  child: Text("Cancel"),
                ),
                TextButton(
                    child: Text('Save'),
                    onPressed: () {
                      if (_formkey.currentState.validate()) {
                        if (_changed) {
                          if (supervision.id != null) {
                            int item;
                            SupervisionPeriod supervisionPeriod;
                            SupervisionSection supervisionSection;
                            supervision.setPeriod(selectedPeriod);
                            configManager.updateRowById('supervision', supervision);
                            configManager.clearRowsOfSupervision('supervisionperiod', supervision.id);
                            configManager.clearRowsOfSupervision('supervisionsection', supervision.id);
                            if (_selectedMonths != null && _selectedMonths.isNotEmpty) {
                              _selectedMonths.forEach((element) {
                                item = _periodMap[element];
                                supervisionPeriod = new SupervisionPeriod(supervisionId: supervision.id, periodNumber: item);
                                configManager.saveRowData('supervisionperiod', supervisionPeriod);
                              });
                            }
                            if (_selectedSection != null && _selectedSection.isNotEmpty) {
                              _selectedSection.forEach((element) {
                                item = _sectionMap[element];
                                supervisionSection = new SupervisionSection(supervisionId: supervision.id, sectionNumber: item);
                                configManager.saveRowData('supervisionsection', supervisionSection);
                              });
                            }
                            setState(() {
                              Navigator.of(context).pop(supervision);
                            });
                          } else {
                            int item;
                            SupervisionPeriod supervisionPeriod;
                            SupervisionSection supervisionSection;
                            supervision.setPeriod(selectedPeriod);
                            var uuid = Uuid();
                            String uid = uuid.v1();
                            supervision.setUid(uid);
                            configManager.saveRowData('supervision', supervision).then((value) {
                              if (value != null) {
                                supervision.setId(value);
                                if (_selectedMonths != null && _selectedMonths.isNotEmpty) {
                                  _selectedMonths.forEach((element) {
                                    item = _periodMap[element];
                                    supervisionPeriod = new SupervisionPeriod(supervisionId: supervision.id, periodNumber: item);
                                    configManager.saveRowData('supervisionperiod', supervisionPeriod);
                                  });
                                }
                                if (_selectedSection != null && _selectedSection.isNotEmpty) {
                                  _selectedSection.forEach((element) {
                                    item = _sectionMap[element];
                                    supervisionSection = new SupervisionSection(supervisionId: supervision.id, sectionNumber: item);
                                    configManager.saveRowData('supervisionsection', supervisionSection);
                                  });
                                }
                                setState(() {
                                  Navigator.of(context).pop(supervision);
                                });
                              }
                            });
                          }
                        } else {
                          Navigator.of(context).pop(supervision);
                        }
                      }
                      ;
                    }),
              ],
            ));
          });
        });
  }

  Future<dynamic> _selectDate(BuildContext context) async {
    final DateTime picked =
        await showDatePicker(context: context, initialDate: selectedPeriod, firstDate: DateTime(2020, 1), lastDate: DateTime(2050));
    if (picked != null && picked != selectedPeriod) {
      return picked;
    }

    return null;
  }

  Future<void> _addPlanningData(supervisionId) async {
    configManager.getDataRowsBySupervision('supervisionfacilities', supervisionId).then((supervisionFacilities) {
      setState(() {
        planningData[supervisionId.toString()]['selected_facilities'] =
            supervisionFacilities.isNotEmpty ? _getSelectedFacilities(_facilities, supervisionFacilities) : <Facility>[];
        selectedFacilities = new List<Facility>();

        selectedFacilities = planningData[supervisionId.toString()]['selected_facilities'];
      });
    });
    var periodEntryList = _periodMap.entries.toList();
    configManager.getDataRowsBySupervision('supervisionperiod', widget.selectedSupervision.id).then((value) {
      value.forEach((element) {
        setState(() {
          _selectedMonths.add(periodEntryList[element.periodNumber - 1].key);
          if (_selectedMonths.length > 2) {
            //_disabled = true;
            _a = _periodMap.keys.toList().toSet();
            _b = _selectedMonths.toSet();
            _notSelectedMonths = _a.difference(_b).toList();
          }
        });
      });
    });

    var sectionEntryList = _sectionMap.entries.toList();
    configManager.getDataRowsBySupervision('supervisionsection', widget.selectedSupervision.id).then((value) {
      value.forEach((element) {
        setState(() {
          _selectedSection.add(sectionEntryList[element.sectionNumber - 1].key);
        });
      });
    });
  }

  getValue(Map<String, dynamic> map, String key) {
    return map != null ? map[key] : null;
  }

  Future<void> _setAllFacilities(dynamic usePackage) async {
    configManager.getSupervisionConfig('facility').then((value) {
      setState(() {
        _facilities = _uncheckFacilities(value);
      });
      if (usePackage == true) {
        _facilities.removeWhere((item) => item.isDhisFacility == true);
      }
    });
  }

  List<dynamic> _uncheckFacilities(List<dynamic> fac) {
    for (var i = 0; i < fac.length; i++) {
      fac[i].isSupervisable = false;
    }

    return fac;
  }

  _updateFields() {
    setState(() {
      _supervisionDescription = widget.selectedSupervision.description;
      _supervisionPeriod = widget.selectedSupervision.period;
      _addButtonLabel = 'Edit';
    });
  }

  List<Facility> _getSelectedFacilities(List<Facility> facilities, List<SupervisionFacilities> supervisionFacilities) {
    List<Facility> result = new List<Facility>();

    supervisionFacilities.forEach((sup) {
      facilities.forEach((fac) {
        if (fac.id == sup.facilityId) {
          result.add(fac);
        }
      });
    });

    return result;
  }

  List<Map<String, dynamic>> _buildDataSourceItems() {
    List<Map<String, dynamic>> dataSourceItems = [];
    dataSources.forEach((dataSource) {
      Map<String, dynamic> dataSourceItem = {};
      dataSourceItem['value'] = dataSource.id.toString();
      dataSourceItem['label'] = dataSource.name;
      dataSourceItems.add(dataSourceItem);
    });
    return dataSourceItems;
  }

  _showHelpTextDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              scrollable: true,
              title: new Text("Info!"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Click \"Add\" to fill in the key details of the supervision"),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                        "Click the gear icon to select the facilities and other indicators, data elements, and data sources that will be used in the supervision checks"),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Widget _informationWidget() {
    return GestureDetector(
        child: Icon(
          Icons.info_outline,
          color: Colors.teal,
          size: 50,
        ),
        onDoubleTap: () {
          _showHelpTextDialog();
        });
  }

  Widget _supervisionFormInformationWidget() {
    return GestureDetector(
        child: Icon(
          Icons.info_outline,
          color: Colors.teal,
          size: 50,
        ),
        onDoubleTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SupervisionFormHelpWidget()),
          );
        });
  }

  Future<void> _setPlanningForImport(int supervisionId) async {
    await configManager.getDataRowsBySupervision('visits', supervisionId).then((value) {
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          _visits[getFacilityById(value[i].facilityId).uid] = value[i];
          setState(() {});
        }
      }
    });
    await configManager.getDataRowsBySupervision('dataelementcompleteness', supervisionId).then((value) {
      if (value != null) {
        setState(() {
          _dataElementCompleteness = value;
        });
      } else {
        _dataElementCompleteness = new List<DataElementCompleteness>();
      }
    });
    await configManager.getDataRowsBySupervision('sourcedocumentcompleteness', supervisionId).then((value) {
      if (value != null) {
        setState(() {
          _sourceDocumentCompleteness = value;
        });
      } else {
        _sourceDocumentCompleteness = new List<SourceDocumentCompleteness>();
      }
    });
    await configManager.getDataRowBySupervision('consistencyovertime', supervisionId).then((value) {
      if (value != null) {
        setState(() {
          _consistencyOverTime = value;
        });
      } else {
        _consistencyOverTime = new ConsistencyOverTime();
      }
    });
    await configManager.getDataRowsBySupervision('crosscheck', supervisionId).then((value) {
      if (value != null || value.isNotEmpty || value != []) {
        setState(() {
          _crossChecks = value;
        });
      } else {
        _crossChecks = new List<CrossCheck>();
      }
    });
    await configManager.getDataRowsBySupervision('selectedindicator', supervisionId).then((value) {
      if (value != null || value.isNotEmpty) {
        setState(() {
          _selectedIndicators = value;
        });
      } else {
        _selectedIndicators = new List<SelectedIndicator>();
      }
    });
  }

  Facility getFacilityById(facilityId) {
    Facility facility = new Facility();
    facility = selectedFacilities.firstWhere((element) => element.id == facilityId, orElse: () => null);

    return facility;
  }

  bool isSupervisionReady() {
    if (widget.selectedSupervision != null) {
      if (_selectedSection.length == 0 || planningData[widget.selectedSupervision.id.toString()]['selected_facilities'].isEmpty) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  //displays the save configuration toast
  _showToast(BuildContext context, String message, String status) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: status == 'success' ? Colors.greenAccent : Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );

    _configSaveToast.init(context);
    _configSaveToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}
