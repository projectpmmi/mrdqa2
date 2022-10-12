import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/Periods.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/models/SupervisionSection.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import '../models/Supervision.dart';
import '../models/EntryDqImprovementPlan.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:date_field/date_field.dart';

class DqiDataEntryPage extends StatefulWidget {
  final ConfigManager configManager;
  Supervision selectedSupervision;

  DqiDataEntryPage(this.configManager, this.selectedSupervision);

  @override
  _DqiDataEntryPageState createState() => _DqiDataEntryPageState(this.configManager, this.selectedSupervision);
}

class _DqiDataEntryPageState extends State<DqiDataEntryPage> {
  int currentStep;
  bool complete;
  final ConfigManager configManager;
  Supervision selectedSupervision;
  final _dataqualityformkey = GlobalKey<FormState>();
  Map<String, dynamic> supervisionData = {}; // keys: 'supervision' and facility ids.
  Map<String, dynamic> facilityData = {}; // Keys: 'completeness' ...
  Facility _currentFacility;
  Map<String, EntryDqImprovementPlan> _entryDqImprovementPlanMap;

  List<Facility> _selectedFacilities;

  List<DataElement> _dataElements;
  List<SourceDocument> _sourceDocuments;
  List<Indicator> _indicators;
  List<Periods> _periods;
  List<SupervisionSection> _supervisionSections = [];
  List<Facility> _facilities;
  int _facilityId;
  String _facilityName = '';
  String _facilityUid = '';

  // Data Quality improvement.
  TextEditingController vi1Weaknesses = new TextEditingController(); // String
  TextEditingController vi1ActionPointDescription = new TextEditingController(); // String
  TextEditingController vi1Responsibles = new TextEditingController(); // String
  DateTime vi1TimeLine = new DateTime.now(); // String
  TextEditingController vi1Comment = new TextEditingController(); // String

  TextEditingController vi2Weaknesses = new TextEditingController(); // String
  TextEditingController vi2ActionPointDescription = new TextEditingController(); // String
  TextEditingController vi2Responsibles = new TextEditingController(); // String
  DateTime vi2TimeLine = new DateTime.now(); // String
  TextEditingController vi2Comment = new TextEditingController(); // String

  TextEditingController vi3Weaknesses = new TextEditingController(); // String
  TextEditingController vi3ActionPointDescription = new TextEditingController(); // String
  TextEditingController vi3Responsibles = new TextEditingController(); // String
  DateTime vi3TimeLine = new DateTime.now(); // String
  TextEditingController vi3Comment = new TextEditingController(); // String

  TextEditingController vi4Weaknesses = new TextEditingController(); // String
  TextEditingController vi4ActionPointDescription = new TextEditingController(); // String
  TextEditingController vi4Responsibles = new TextEditingController(); // String
  DateTime vi4TimeLine = new DateTime.now(); // String
  TextEditingController vi4Comment = new TextEditingController(); // String

  List<StepState> _listState;
  List<Step> _stepList;
  Map<int, int> _sectionsMap = {
    0: 0,
  };
  bool _isFillingPushing;
  bool _dqiChecked;

  _DqiDataEntryPageState(this.configManager, this.selectedSupervision);

  @override
  void initState() {
    super.initState();

    currentStep = 0;
    complete = false;
    _isFillingPushing = false;
    _dqiChecked = false;
    _listState = [
      StepState.indexed,
      StepState.editing,
      StepState.complete,
    ];
    _facilityId = null;
    _getConfig().then((value) {
      _stepList = _createSteps(context, _selectedFacilities);
    });
  }

  List<Step> _createSteps(BuildContext context, items) {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    TextEditingController _facilityController = TextEditingController();
    List<Map<String, dynamic>> dropItems = new List();
    if (items != null) {
      items.asMap().forEach((index, value) {
        Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
        dropItems.add(dropDownItemsMap);
      });
    }
    List<Step> _steps = <Step>[
      new Step(
        title: const Text('Routine Supervision Data Quality Checklist'),
        isActive: true,
        state: currentStep == 0
            ? _listState[1]
            : currentStep > 0
                ? _listState[2]
                : _listState[0],
        content: Column(
          children: <Widget>[
            Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectFormField(
                    controller: _facilityController,
                    type: SelectFormFieldType.dropdown,
                    // or can be dialog
                    icon: Icon(Icons.local_hospital),
                    labelText: 'Facility',
                    items: dropItems,
                    onChanged: (value) async {
                      setState(() {
                        _facilityId = int.parse(value.toString());
                      });
                      configManager.getConfigRowById('facility', _facilityId).then((value) async {
                        setState(() {
                          _currentFacility = value;
                          _facilityName = value.name;
                          _facilityUid = value.uid;
                          _isFillingPushing = true;
                        });
                        await _fillForm();
                        setState(() {
                          _isFillingPushing = false;
                        });
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'The facility should have a Type';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
    for (int i = 0; i < _supervisionSections.length; i++) {
      if (_supervisionSections[i].sectionNumber == 6) {
        _dqiChecked = true;
        _steps.add(new Step(
          state: currentStep == 1 ? _listState[1] : _listState[0],
          title: const Text('Data Quality Improvement Plan for the Health Facility'),
          content: Column(
            children: <Widget>[
              _dataQualityForm(),
            ],
          ),
        ));
      }
    }
    ;

    return _steps;
  }

  next(length) {
    currentStep + 1 != length ? goTo(currentStep + 1) : setState(() => complete = true);
    print(currentStep);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    currentStep = step;
  }

  StepperType stepperType = StepperType.vertical;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data quality improvement plan'),
      ),
      drawer: Drawer(
        child: MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: (_supervisionSections != null && _stepList != null)
          ? Column(children: <Widget>[
              complete
                  ? Expanded(
                      child: Center(
                        child: AlertDialog(
                          title: new Text("Form successfully submitted"),
                          content: new Text(
                            "You can go for another facility!",
                          ),
                          actions: <Widget>[
                            new TextButton(
                              child: new Text("Close"),
                              onPressed: () {
                                setState(() => complete = false);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : _isFillingPushing
                      ? Expanded(
                          child: Center(child: new CircularProgressIndicator()),
                        )
                      : Expanded(
                          child: Stepper(
                            steps: _stepList,
                            type: stepperType,
                            currentStep: currentStep,
                            onStepContinue: () async {
                              if (currentStep == 0 && _facilityId == null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => _buildPopupDialog(context, 'Empty facilty', 'Please select a facility first'),
                                );
                              } else {
                                if (currentStep == 1 && _dqiChecked) {
                                  setState(() {
                                    _isFillingPushing = true;
                                  });
                                  await _pushDqi();
                                  setState(() {
                                    _isFillingPushing = false;
                                  });
                                }
                                setState(() {
                                  next(_stepList.length);
                                });
                              }
                            },
                            onStepCancel: () {
                              setState(() {
                                cancel();
                              });
                            },
                            onStepTapped: (step) {
                              if (currentStep == 0 && _facilityId == null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => _buildPopupDialog(context, 'Empty facilty', 'Please select a facility first'),
                                );
                              } else {
                                setState(() {
                                  goTo(step);
                                });
                              }
                            },
                          ),
                        ),
            ])
          : Center(child: new CircularProgressIndicator()),
    );
  }

  Widget _buildPopupDialog(BuildContext context, String $title, String $text) {
    return new AlertDialog(
      title: Text($title),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text($text),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _dataQualityForm() {
    return Form(
        key: _dataqualityformkey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            child: Card(
                shape: new RoundedRectangleBorder(side: new BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: vi1Weaknesses,
                              decoration: const InputDecoration(
                                labelText: "Identified Weakness 1",
                              ),
                            ),
                          ),
                        ]),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: vi1Responsibles,
                                decoration: const InputDecoration(
                                  labelText: "Responsible(s)",
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: DateTimeFormField(
                                key: Key("vi1_" + vi1TimeLine.toString()),
                                initialValue: vi1TimeLine,
                                decoration: const InputDecoration(
                                  errorStyle: TextStyle(color: Colors.redAccent),
                                  suffixIcon: Icon(Icons.event_note),
                                  labelText: 'Time line',
                                ),
                                mode: DateTimeFieldPickerMode.date,
                                // autovalidateMode: AutovalidateMode.always,
                                // validator: (e) => (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                                onDateSelected: (DateTime value) {
                                  setState(() {
                                    vi1TimeLine = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: vi1ActionPointDescription,
                                decoration: const InputDecoration(
                                  labelText: "Description of Action plan",
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                controller: vi1Comment,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  labelText: "Comments",
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ))),
          ),
          Container(
            child: Card(
                shape: new RoundedRectangleBorder(side: new BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: vi2Weaknesses,
                              decoration: const InputDecoration(
                                labelText: "Identified Weakness 2",
                              ),
                            ),
                          ),
                        ]),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: vi2Responsibles,
                                decoration: const InputDecoration(
                                  labelText: "Responsible(s)",
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: DateTimeFormField(
                                key: Key("vi2_" + vi2TimeLine.toString()),
                                initialValue: vi2TimeLine,
                                decoration: const InputDecoration(
                                  errorStyle: TextStyle(color: Colors.redAccent),
                                  suffixIcon: Icon(Icons.event_note),
                                  labelText: 'Time line',
                                ),
                                mode: DateTimeFieldPickerMode.date,
                                // autovalidateMode: AutovalidateMode.always,
                                // validator: (e) => (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                                onDateSelected: (DateTime value) {
                                  vi2TimeLine = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: vi2ActionPointDescription,
                                decoration: const InputDecoration(
                                  labelText: "Description of Action plan",
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: vi2Comment,
                                decoration: const InputDecoration(
                                  labelText: "Comments",
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ))),
          ),
          Container(
            child: Card(
                shape: new RoundedRectangleBorder(side: new BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: vi3Weaknesses,
                              decoration: const InputDecoration(
                                labelText: "Identified Weakness 3",
                              ),
                            ),
                          ),
                        ]),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: vi3Responsibles,
                                decoration: const InputDecoration(
                                  labelText: "Responsible(s)",
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: DateTimeFormField(
                                key: Key("vi3_" + vi3TimeLine.toString()),
                                initialValue: vi3TimeLine,
                                decoration: const InputDecoration(
                                  errorStyle: TextStyle(color: Colors.redAccent),
                                  suffixIcon: Icon(Icons.event_note),
                                  labelText: 'Time line',
                                ),
                                mode: DateTimeFieldPickerMode.date,
                                // autovalidateMode: AutovalidateMode.always,
                                // validator: (e) => (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                                onDateSelected: (DateTime value) {
                                  vi3TimeLine = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: vi3ActionPointDescription,
                                decoration: const InputDecoration(
                                  labelText: "Description of Action plan",
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: vi3Comment,
                                decoration: const InputDecoration(
                                  labelText: "Comments",
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ))),
          ),
          Container(
              child: Card(
                  shape: new RoundedRectangleBorder(side: new BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                  child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Row(children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: vi4Weaknesses,
                                decoration: const InputDecoration(
                                  labelText: "Identified Weakness 4",
                                ),
                              ),
                            ),
                          ]),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: vi4Responsibles,
                                  decoration: const InputDecoration(
                                    labelText: "Responsible(s)",
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                // child: TextFormField(
                                //   keyboardType: TextInputType.text,
                                //   controller: vi4TimeLine,
                                //   decoration: const InputDecoration(
                                //     labelText: "Time line",
                                //   ),
                                // ),
                                child: DateTimeFormField(
                                  key: Key("vi4_" + vi4TimeLine.toString()),
                                  initialValue: vi4TimeLine,
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: Colors.redAccent),
                                    suffixIcon: Icon(Icons.event_note),
                                    labelText: 'Time line',
                                  ),
                                  mode: DateTimeFieldPickerMode.date,
                                  // autovalidateMode: AutovalidateMode.always,
                                  // validator: (e) => (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                                  onDateSelected: (DateTime value) {
                                    vi4TimeLine = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: vi4ActionPointDescription,
                                  decoration: const InputDecoration(
                                    labelText: "Description of Action plan",
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: vi4Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comments",
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )))),
        ]));
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

  Periods getPeriodById(periodId) {
    Periods period = new Periods();
    period = _periods.firstWhere((element) => element.id == periodId, orElse: () => null);

    return period;
  }

  DataElement getDataElementById(dataElementId) {
    DataElement dataElement = new DataElement();
    dataElement = _dataElements.firstWhere((element) => element.id == dataElementId, orElse: () => null);

    return dataElement;
  }

  Indicator getIndicatorById(indicatorId) {
    Indicator indicator = new Indicator();
    indicator = _indicators.firstWhere((element) => element.id == indicatorId, orElse: () => null);

    return indicator;
  }

  SourceDocument getSourceDocumentById(sourceDocumentId) {
    SourceDocument sourceDocument = new SourceDocument();
    sourceDocument = _sourceDocuments.firstWhere((element) => element.id == sourceDocumentId, orElse: () => null);

    return sourceDocument;
  }

  Periods getPeriodByNumber(number) {
    Periods period = new Periods();
    period = _periods.firstWhere((element) => element.number == number, orElse: () => null);

    return period;
  }

  Future<void> _getConfig() async {
    _facilities = await configManager.getSupervisionConfig('facility');
    configManager.getDataRowsBySupervision('supervisionfacilities', widget.selectedSupervision.id).then((value) {
      setState(() {
        //_supervisionFacilities = value;
        _selectedFacilities = _getSelectedFacilities(_facilities, value);
      });
    });
    _supervisionSections = await configManager.getDataRowsBySupervision('supervisionsection', widget.selectedSupervision.id);
    setState(() {});
  }

  Future<void> _fillDataQualityFields() async {
    _entryDqImprovementPlanMap = {
      "a": new EntryDqImprovementPlan(id: 0, type: "a"),
      "b": new EntryDqImprovementPlan(id: 0, type: "b"),
      "c": new EntryDqImprovementPlan(id: 0, type: "c"),
      "d": new EntryDqImprovementPlan(id: 0, type: "d")
    };
    configManager.getDataRowsByFacilityAndSupervision('entrydqimprovementplan', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.length > 0) {
        setState(() {
          vi1Weaknesses.text = '';
          vi1ActionPointDescription.text = '';
          vi1Responsibles.text = '';
          vi1TimeLine = null;
          vi1Comment.text = '';
          vi2Weaknesses.text = '';
          vi2ActionPointDescription.text = '';
          vi2Responsibles.text = '';
          vi2TimeLine = null;
          vi2Comment.text = '';
          vi3Weaknesses.text = '';
          vi3ActionPointDescription.text = '';
          vi3Responsibles.text = '';
          vi3TimeLine = null;
          vi3Comment.text = '';
          vi4Weaknesses.text = '';
          vi4ActionPointDescription.text = '';
          vi4Responsibles.text = '';
          vi4TimeLine = null;
          vi4Comment.text = '';
        });
        for (var i = 0; i < value.length; i++) {
          if (value[i].type == 'a') {
            setState(() {
              _entryDqImprovementPlanMap["a"] = value[i];
              vi1Weaknesses.text = value[i].weaknesses;
              vi1ActionPointDescription.text = value[i].actionPointDescription;
              vi1Responsibles.text = value[i].responsibles;
              vi1TimeLine = value[i].timeLine;
              vi1Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'b') {
            setState(() {
              _entryDqImprovementPlanMap["b"] = value[i];
              vi2Weaknesses.text = value[i].weaknesses;
              vi2ActionPointDescription.text = value[i].actionPointDescription;
              vi2Responsibles.text = value[i].responsibles;
              vi2TimeLine = value[i].timeLine;
              vi2Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'c') {
            setState(() {
              _entryDqImprovementPlanMap["c"] = value[i];
              vi3Weaknesses.text = value[i].weaknesses;
              vi3ActionPointDescription.text = value[i].actionPointDescription;
              vi3Responsibles.text = value[i].responsibles;
              vi3TimeLine = value[i].timeLine;
              vi3Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'd') {
            setState(() {
              _entryDqImprovementPlanMap["d"] = value[i];
              vi4Weaknesses.text = value[i].weaknesses;
              vi4ActionPointDescription.text = value[i].actionPointDescription;
              vi4Responsibles.text = value[i].responsibles;
              vi4TimeLine = value[i].timeLine;
              vi4Comment.text = value[i].comment;
            });
          }
        }
      } else {
        setState(() {
          vi1Weaknesses.text = '';
          vi1ActionPointDescription.text = '';
          vi1Responsibles.text = '';
          vi1TimeLine = DateTime.now();
          vi1Comment.text = '';
          vi2Weaknesses.text = '';
          vi2ActionPointDescription.text = '';
          vi2Responsibles.text = '';
          vi2TimeLine = DateTime.now();
          vi2Comment.text = '';
          vi3Weaknesses.text = '';
          vi3ActionPointDescription.text = '';
          vi3Responsibles.text = '';
          vi3TimeLine = DateTime.now();
          vi3Comment.text = '';
          vi4Weaknesses.text = '';
          vi4ActionPointDescription.text = '';
          vi4Responsibles.text = '';
          vi4TimeLine = DateTime.now();
          vi4Comment.text = '';
        });
      }
    });
  }

  Future<void> _pushDataQualityImprovmentForm() async {
    _entryDqImprovementPlanMap.forEach((key, value) {
      if (key == "a") {
        if (value.id == 0) {
          _entryDqImprovementPlanMap[key].supervisionId = widget.selectedSupervision.id;
          _entryDqImprovementPlanMap[key].facilityId = _facilityId;
        }
        _entryDqImprovementPlanMap[key].weaknesses = vi1Weaknesses.text;
        _entryDqImprovementPlanMap[key].actionPointDescription = vi1ActionPointDescription.text;
        _entryDqImprovementPlanMap[key].responsibles = vi1Responsibles.text;
        _entryDqImprovementPlanMap[key].timeLine = vi1TimeLine;
        _entryDqImprovementPlanMap[key].comment = vi1Comment.text;
      } else if (key == "b") {
        if (value.id == 0) {
          _entryDqImprovementPlanMap[key].supervisionId = widget.selectedSupervision.id;
          _entryDqImprovementPlanMap[key].facilityId = _facilityId;
        }
        _entryDqImprovementPlanMap[key].weaknesses = vi2Weaknesses.text;
        _entryDqImprovementPlanMap[key].actionPointDescription = vi2ActionPointDescription.text;
        _entryDqImprovementPlanMap[key].responsibles = vi2Responsibles.text;
        _entryDqImprovementPlanMap[key].timeLine = vi2TimeLine;
        _entryDqImprovementPlanMap[key].comment = vi2Comment.text;
      } else if (key == "c") {
        if (value.id == 0) {
          _entryDqImprovementPlanMap[key].supervisionId = widget.selectedSupervision.id;
          _entryDqImprovementPlanMap[key].facilityId = _facilityId;
        }
        _entryDqImprovementPlanMap[key].weaknesses = vi3Weaknesses.text;
        _entryDqImprovementPlanMap[key].actionPointDescription = vi3ActionPointDescription.text;
        _entryDqImprovementPlanMap[key].responsibles = vi3Responsibles.text;
        _entryDqImprovementPlanMap[key].timeLine = vi3TimeLine;
        _entryDqImprovementPlanMap[key].comment = vi3Comment.text;
      } else if (key == "d") {
        if (value.id == 0) {
          _entryDqImprovementPlanMap[key].supervisionId = widget.selectedSupervision.id;
          _entryDqImprovementPlanMap[key].facilityId = _facilityId;
        }
        _entryDqImprovementPlanMap[key].weaknesses = vi4Weaknesses.text;
        _entryDqImprovementPlanMap[key].actionPointDescription = vi4ActionPointDescription.text;
        _entryDqImprovementPlanMap[key].responsibles = vi4Responsibles.text;
        _entryDqImprovementPlanMap[key].timeLine = vi4TimeLine;
        _entryDqImprovementPlanMap[key].comment = vi4Comment.text;
      }
    });
    _entryDqImprovementPlanMap.forEach((key, value) {
      print('Identified: ${value.weaknesses}');
      if (value.id != 0) {
        configManager.updateRowById('entrydataqualityimprovement', value);
      } else if (value.weaknesses != '') {
        configManager.saveRowData('entrydataqualityimprovement', value);
      }
    });
  }

  Future<void> _fillForm() async {
    print('Filling form dqi');
    await _fillDataQualityFields();
    print('Finished filling form dqi!');
  }

  Future<void> _pushDqi() async {
    print('Pushing dqi');
    await _pushDataQualityImprovmentForm();
    print('Finished pushing dqi!');
  }
}
