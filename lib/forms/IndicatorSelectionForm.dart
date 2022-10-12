import 'package:flutter/material.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:mrdqa_tool/services/MetaDataManager.dart';
import 'package:mrdqa_tool/widgets/CrossCheckHelpWidget.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:unicorndial/unicorndial.dart';
import '../models/ConsistencyOverTime.dart';
import '../models/CrossCheck.dart';
import '../models/DataElement.dart';
import '../models/DataElementCompleteness.dart';
import '../models/Indicator.dart';
import '../models/SelectedIndicator.dart';
import '../models/SourceDocument.dart';
import '../models/SourceDocumentCompleteness.dart';
import '../models/Supervision.dart';

class IndicatorSelectionForm extends StatefulWidget {
  static String routeName = '/supervisions/indicator';

  // Declare a field that holds the RecordObject.
  final Supervision supervision;
  final List<String> selectedSection;

  // In the constructor, require a RecordObject.
  IndicatorSelectionForm({Key key, @required this.supervision, @required this.selectedSection}) : super(key: key);

  @override
  _IndicatorSelectionFormState createState() => _IndicatorSelectionFormState();
}

class _IndicatorSelectionFormState extends State<IndicatorSelectionForm> {
  ConfigManager configManager;
  MetaDataManager _metaDataManager;
  List<SelectedIndicator> _selectedIndicators; // Selected indicators
  List<Indicator> _indicators;
  Indicator _indicator;
  List<Indicator> _dataAccuracyIndicators;
  List<SourceDocumentCompleteness> _sourceDocumentCompleteness;
  List<DataElement> _dataElements;
  DataElement _dataElement;
  List<DataElementCompleteness> _dataElementCompleteness;
  List<DataElement> _dataElementCompletenessElements;
  List<SourceDocument> _sourceDocuments;
  SourceDocument _sourceDocument;
  List<SourceDocument> _sourceDocumentCompletnessElements;
  List<CrossCheck> _crossChecks;
  ConsistencyOverTime _consistencyOverTime;
  Indicator _consistencyIndicator;
  int _tabsNumber = 0;
  List<Widget> _tabsList = [];
  List<Widget> _tabViewList = [];
  String _warningContent;
  bool _dataEntryStatus;

  @override
  void initState() {
    super.initState();

    configManager = new ConfigManager();
    _metaDataManager = MetaDataManager();
    setState(() {
      _dataAccuracyIndicators = new List<Indicator>();
      _dataElementCompletenessElements = new List<DataElement>();
      _indicator = new Indicator();
      _dataElement = new DataElement();
      _sourceDocument = new SourceDocument();
      _sourceDocumentCompletnessElements = new List<SourceDocument>();
      _consistencyIndicator = new Indicator();
      _addPlanningData(widget.supervision.id, widget.supervision.usePackage);
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildTabs(widget.selectedSection);
    return DefaultTabController(
      // The number of tabs / content sections to display.
      length: _tabsNumber,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: _tabsList,
          ),
          title: Text("Indicators"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                // Test if selections are saved.
                // Navigator.pushReplacementNamed(
                //     context, Routes().supervisions);
                Navigator.pop(context);
              });
            },
          ),
        ),
        body: TabBarView(children: _tabViewList),
      ),
    );
  }

  List<UnicornButton> _getCompletenessProfileMenu() {
    List<UnicornButton> children = [];
    String dataElement = 'Data element';
    String sourceDocument = 'Source document';

    // Add Children here
    children.add(_completenessProfileOption(
      iconData: Icons.data_usage,
      label: dataElement,
      onPressed: () async {
        await _dataElementCompletenessForm(context, _dataElements);
      },
    ));
    children.add(_completenessProfileOption(
      iconData: Icons.book,
      label: sourceDocument,
      onPressed: () async {
        await _sourceDocumentCompletenessForm(context, _sourceDocuments);
      },
    ));

    return children;
  }

  Widget _completenessProfileOption({IconData iconData, String label, Function onPressed}) {
    return UnicornButton(
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
        ));
  }

  Widget _selectedIndicatorView(List<Indicator> indicators) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: indicators.isNotEmpty
          ? SingleChildScrollView(
              child: DataTable(
              columns: [
                DataColumn(label: Text('Indicator name')),
                // DataColumn(label: Text('UID')),
              ],
              rows: indicators
                      ?.map((indicator) => DataRow(cells: <DataCell>[
                            DataCell(
                              GestureDetector(
                                  onDoubleTap: () async {
                                    if (!_dataEntryStatus)
                                      _onDeleteConfirm(context, 'IND', widget.supervision.id, indicator);
                                    else
                                      _dataExistInfo(context);
                                  },
                                  child: Text(indicator.name)),
                              // Container(
                              // width: 200,)),
                              // DataCell(Container(
                              //   child: Text(indicator.uid),
                              // )),
                            )
                          ]))
                      ?.toList() ??
                  [],
            ))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    Text("Click the \"+\" button to add up to 3 indicators for data accuracy checks will be performed."),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _crossCheckView(List<CrossCheck> crossChecks) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: crossChecks != null
          ? SingleChildScrollView(
              child: DataTable(
              columns: [
                DataColumn(label: Text('Primary')),
                DataColumn(label: Text('Secondary')),
              ],
              rows: crossChecks
                      ?.map((crossCheck) => DataRow(cells: <DataCell>[
                            DataCell(
                              GestureDetector(
                                  onDoubleTap: () async {
                                    if (!_dataEntryStatus)
                                      _onDeleteConfirm(context, 'CROSS', widget.supervision.id, crossCheck);
                                    else
                                      _dataExistInfo(context);
                                  },
                                  child: Text(getItemById('source_document', _sourceDocuments, crossCheck.primaryDataSourceId).name)),
                            ),
                            DataCell(
                              GestureDetector(
                                onDoubleTap: () async {
                                  if (!_dataEntryStatus)
                                    _onDeleteConfirm(context, 'CROSS', widget.supervision.id, crossCheck);
                                  else
                                    _dataExistInfo(context);
                                },
                                child: Text(getItemById('source_document', _sourceDocuments, crossCheck.secondaryDataSourceId).name),
                              ),
                            ),
                          ]))
                      ?.toList() ??
                  [],
            ))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    Text('Empty, click the floating button to add cross check'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _consistencyOverTimeView(Indicator indicator) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: indicator.name != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Indicator name:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    indicator.name != null ? Text(indicator.name) : Text('Empty'),
                  ],
                )
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    Text("Click the \"+\" button to add the indicator you want to conduct consistency checks on."),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _dataElementCompletenessView(List<DataElement> dataElements) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: dataElements.isNotEmpty
          ? SingleChildScrollView(
              child: DataTable(
              columns: [
                // DataColumn(label: Text('UID')),
                DataColumn(label: Text('DATA ELEMENTS', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: dataElements
                      ?.map((dataElement) => DataRow(cells: <DataCell>[
                            DataCell(GestureDetector(
                                onDoubleTap: () async {
                                  if (!_dataEntryStatus)
                                    _onDeleteConfirm(context, 'DE', widget.supervision.id, dataElement);
                                  else
                                    _dataExistInfo(context);
                                },
                                child: Text(dataElement.name))),
                          ]))
                      ?.toList() ??
                  [],
            ))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    Text("Click the \"+\" button to add up to 6 data elements that will be checked as part of the Data Element Completeness check. "),
                  ],
                ),
              ),
            ),

      // : Center(
      //     child: Text('Data Elements are not configured'),
      //   ),
    );
  }

  Widget _sourceDocumentCompletenessView(List<SourceDocument> sourceDocuments) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: sourceDocuments.isNotEmpty
          ? SingleChildScrollView(
              child: DataTable(
              columns: [
                // DataColumn(label: Text('UID')),
                DataColumn(label: Text('SOURCE DOCUMENTS', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: sourceDocuments
                      ?.map((sourceDocument) => DataRow(cells: <DataCell>[
                            DataCell(
                              GestureDetector(
                                  onDoubleTap: () async {
                                    if (!_dataEntryStatus)
                                      _onDeleteConfirm(context, 'SRC', widget.supervision.id, sourceDocument);
                                    else
                                      _dataExistInfo(context);
                                  },
                                  child: Text(sourceDocument.name)),
                            ),
                          ]))
                      ?.toList() ??
                  [],
            ))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    Text(
                        "Click the \"+\" button to add up to 7 source documents that will be checked as part of the Source Document Completeness checks."),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectIndicatorForm(BuildContext context, items) async {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _indicatorController = TextEditingController();
          TextEditingController _numberController = TextEditingController();
          List<Map<String, dynamic>> dropItems = new List();
          if (items != null) {
            items.asMap().forEach((index, value) {
              Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
              dropItems.add(dropDownItemsMap);
            });
          }
          List<Map<String, dynamic>> dropDownNumber = [
            {'value': "1", 'label': "Indicator 1"},
            {'value': "2", 'label': "Indicator 2"},
            {'value': "3", 'label': "Indicator 3"}
          ];
          return items != null
              ? AlertDialog(
                  content: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectFormField(
                          controller: _numberController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Number',
                          items: dropDownNumber,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'The Indicator should have a number';
                            }
                            for (int i = 0; i < _selectedIndicators.length; i++) {
                              if (int.parse(value) == _selectedIndicators[i].number) {
                                return 'Existing number';
                              }
                            }
                            return null;
                          },
                        ),
                        SelectFormField(
                          controller: _indicatorController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Indicator',
                          items: dropItems,
                          maxLines: 3,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'The Indicator should have a Type';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          int indicatorId = int.parse(_indicatorController.text);
                          int number = int.parse(_numberController.text);
                          SelectedIndicator result =
                              SelectedIndicator(indicatorId: indicatorId, number: number, supervisionId: widget.supervision.id);
                          configManager.saveRowData('selectedindicator', result).then((value) {
                            _selectedIndicators.add(result);
                            _indicator = getItemById('indicator', _indicators, indicatorId);
                            setState(() {
                              if (_dataAccuracyIndicators != null) {
                                _dataAccuracyIndicators.add(_indicator);
                              } else {
                                _dataAccuracyIndicators = [];
                                _dataAccuracyIndicators.add(_indicator);
                              }
                              Navigator.of(context).pop();
                            });
                          });
                        }
                      },
                    ),
                  ],
                )
              : Center(
                  child: Text('Configure indicators first'),
                );
        });
  }

  Future<void> _crossCheckForm(BuildContext context, dataSource) async {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _primaryController = TextEditingController();
          TextEditingController _secondaryController = TextEditingController();
          TextEditingController _typeController = TextEditingController();
          List<Map<String, dynamic>> dropItems = new List();
          if (dataSource != null) {
            dataSource.asMap().forEach((index, value) {
              Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
              dropItems.add(dropDownItemsMap);
            });
          }
          List<Map<String, dynamic>> dropDownType = [
            {'value': "a", 'label': "Cross check 1"},
            {'value': "b", 'label': "Cross check 2"},
            {'value': "c", 'label': "Cross check 3"}
          ];
          return dataSource != null
              ? AlertDialog(
                  content: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectFormField(
                          controller: _typeController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Type',
                          items: dropDownType,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cross check need a type';
                            }
                            for (int i = 0; i < _crossChecks.length; i++) {
                              if (value == _crossChecks[i].type) {
                                return 'Existing type';
                              }
                            }
                            return null;
                          },
                        ),
                        SelectFormField(
                          controller: _primaryController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Primary data source',
                          items: dropItems,
                          maxLines: 2,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cross check need a primary data source';
                            }
                            return null;
                          },
                        ),
                        SelectFormField(
                          controller: _secondaryController,
                          keyboardType: TextInputType.number,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Secondary data source',
                          items: dropItems,
                          maxLines: 2,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cross check need a secondary data source';
                            }
                            int primaryValue = int.parse(_primaryController.text);
                            int secondaryValue = int.parse(value);
                            if (primaryValue > secondaryValue) {
                              return 'Secondary should be higher than the primary';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          int primary = int.parse(_primaryController.text);
                          int secondary = int.parse(_secondaryController.text);
                          String type = _typeController.text;
                          CrossCheck result = CrossCheck(
                              primaryDataSourceId: primary, secondaryDataSourceId: secondary, type: type, supervisionId: widget.supervision.id);
                          configManager.saveRowData('crosscheck', result).then((value) {
                            setState(() {
                              _crossChecks.add(result);
                              Navigator.of(context).pop();
                            });
                          });
                        }
                      },
                    ),
                  ],
                )
              : Center(
                  child: Text('Configure data source first'),
                );
        });
  }

  Future<void> _consistencyOverTimeForm(BuildContext context, indicators) async {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _indicatorController = TextEditingController();
          List<Map<String, dynamic>> dropItems = new List();
          if (indicators != null) {
            indicators.asMap().forEach((index, value) {
              Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
              dropItems.add(dropDownItemsMap);
            });
          }
          return indicators != null
              ? AlertDialog(
                  content: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectFormField(
                          controller: _indicatorController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Indicator',
                          items: dropItems,
                          maxLines: 4,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'The Indicator should have a Type';
                            }
                            return null;
                          },
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          setState(() {
                            int indicatorId = int.parse(_indicatorController.text);
                            ConsistencyOverTime result = ConsistencyOverTime(indicatorId: indicatorId, supervisionId: widget.supervision.id);
                            //remove with this supervision
                            configManager.clearRowsOfSupervision('consistencyovertime', widget.supervision.id).then((value) {
                              configManager.saveRowData('consistencyovertime', result).then((value) {
                                setState(() {
                                  // _consistencyOverTime = result;
                                  _consistencyIndicator = getItemById('indicator', _indicators, indicatorId);
                                  Navigator.of(context).pop();
                                });
                              });
                            });
                          });
                        }
                      },
                    ),
                  ],
                )
              : Center(
                  child: Text('Configure indicators first'),
                );
        });
  }

  Future<void> _dataElementCompletenessForm(BuildContext context, dataElements) async {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _dataElementController = TextEditingController();
          TextEditingController _deNumberController = TextEditingController();
          List<Map<String, dynamic>> dropItems = new List();
          if (dataElements != null) {
            dataElements.asMap().forEach((index, value) {
              Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
              dropItems.add(dropDownItemsMap);
            });
          }
          List<Map<String, dynamic>> dropDownDeNumber = [
            {'value': "1", 'label': "Data Element 1"},
            {'value': "2", 'label': "Data Element 2"},
            {'value': "3", 'label': "Data Element 3"},
            {'value': "4", 'label': "Data Element 4"},
            {'value': "5", 'label': "Data Element 5"},
            {'value': "6", 'label': "Data Element 6"}
          ];
          return dataElements != null
              ? AlertDialog(
                  content: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectFormField(
                          controller: _deNumberController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Number',
                          items: dropDownDeNumber,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You should select a number';
                            }
                            for (int i = 0; i < _dataElementCompleteness.length; i++) {
                              if (int.parse(value) == _dataElementCompleteness[i].number) {
                                return 'Existing number';
                              }
                            }
                            return null;
                          },
                        ),
                        SelectFormField(
                          controller: _dataElementController,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Data element',
                          items: dropItems,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You should select a data element';
                            }
                            return null;
                          },
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          int dataElementId = int.parse(_dataElementController.text);
                          int number = int.parse(_deNumberController.text);
                          DataElementCompleteness result =
                              DataElementCompleteness(dataElementId: dataElementId, number: number, supervisionId: widget.supervision.id);
                          configManager.saveRowData('dataelementcompleteness', result).then((value) {
                            _dataElementCompleteness.add(result);
                            _dataElement = getItemById('data_element', _dataElements, dataElementId);
                            setState(() {
                              if (_dataElementCompletenessElements != null) {
                                _dataElementCompletenessElements.add(_dataElement);
                              } else {
                                _dataElementCompletenessElements = [];
                                _dataElementCompletenessElements.add(_dataElement);
                              }
                              Navigator.of(context).pop();
                            });
                          });
                        }
                      },
                    ),
                  ],
                )
              : Center(
                  child: Text('Configure data elements first'),
                );
        });
  }

  Future<void> _sourceDocumentCompletenessForm(BuildContext context, sourceDocuments) async {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _sourceDocumentController = TextEditingController();
          TextEditingController _sourceDocNumberController = TextEditingController();
          List<Map<String, dynamic>> dropItems = new List();
          if (sourceDocuments != null) {
            sourceDocuments.asMap().forEach((index, value) {
              Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
              dropItems.add(dropDownItemsMap);
            });
          }
          List<Map<String, dynamic>> dropDownSourceDoc = [
            {'value': "1", 'label': "Source document 1"},
            {'value': "2", 'label': "Source document 2"},
            {'value': "3", 'label': "Source document 3"},
            {'value': "4", 'label': "Source document 4"},
            {'value': "5", 'label': "Source document 5"},
            {'value': "6", 'label': "Source document 6"},
            {'value': "7", 'label': "Source document 7"}
          ];
          return sourceDocuments != null
              ? AlertDialog(
                  content: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectFormField(
                          controller: _sourceDocNumberController,
                          keyboardType: TextInputType.number,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Number',
                          items: dropDownSourceDoc,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You should select a number';
                            }
                            for (int i = 0; i < _sourceDocumentCompleteness.length; i++) {
                              if (int.parse(value) == _sourceDocumentCompleteness[i].number) {
                                return 'Existing number';
                              }
                            }
                            return null;
                          },
                        ),
                        SelectFormField(
                          controller: _sourceDocumentController,
                          keyboardType: TextInputType.number,
                          type: SelectFormFieldType.dropdown,
                          // or can be dialog
                          icon: Icon(Icons.local_hospital),
                          labelText: 'Source document',
                          items: dropItems,
                          maxLines: 2,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You should select a source document';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text('Save'),
                        onPressed: () {
                          if (_formkey.currentState.validate()) {
                            int sourceDocumentId = int.parse(_sourceDocumentController.text);
                            int number = int.parse(_sourceDocNumberController.text);
                            SourceDocumentCompleteness result =
                                SourceDocumentCompleteness(sourceDocumentId: sourceDocumentId, number: number, supervisionId: widget.supervision.id);
                            configManager.saveRowData('sourcedocumentcompleteness', result).then((value) {
                              _sourceDocumentCompleteness.add(result);
                              _sourceDocument = getItemById('source_document', _sourceDocuments, sourceDocumentId);
                              setState(() {
                                if (_sourceDocumentCompletnessElements != null) {
                                  _sourceDocumentCompletnessElements.add(_sourceDocument);
                                } else {
                                  _sourceDocumentCompletnessElements = [];
                                  _sourceDocumentCompletnessElements.add(_sourceDocument);
                                }
                                Navigator.of(context).pop();
                              });
                            });
                          }
                        }),
                  ],
                )
              : Center(
                  child: Text('Configure data source first'),
                );
        });
  }

  dynamic getItemById(String type, dynamic container, int id) {
    switch (type) {
      case 'indicator':
        container.forEach((element) {
          if (element.id == id) {
            _indicator = element;
          }
        });

        return _indicator;

      case 'data_element':
        container.forEach((element) {
          if (element.id == id) {
            _dataElement = element;
          }
        });

        return _dataElement;

      case 'source_document':
        container.forEach((element) {
          if (element.id == id) {
            _sourceDocument = element;
          }
        });

        return _sourceDocument;
    }
  }

  List<Indicator> getDataAccuracyIndicators(List<Indicator> objects, List<SelectedIndicator> selected) {
    List<Indicator> result = new List<Indicator>();

    selected.forEach((sel) {
      objects.forEach((obj) {
        if (sel.indicatorId == obj.id) {
          result.add(obj);
        }
      });
    });

    return result;
  }

  List<DataElement> getDataElementCompletenessElements(List<DataElement> objects, List<DataElementCompleteness> selected) {
    List<DataElement> result = new List<DataElement>();

    selected.forEach((sel) {
      objects.forEach((obj) {
        if (sel.dataElementId == obj.id) {
          result.add(obj);
        }
      });
    });

    return result;
  }

  List<SourceDocument> getSourceDocumentCompletenessElements(List<SourceDocument> objects, List<SourceDocumentCompleteness> selected) {
    List<SourceDocument> result = new List<SourceDocument>();

    selected.forEach((sel) {
      objects.forEach((obj) {
        if (sel.sourceDocumentId == obj.id) {
          result.add(obj);
        }
      });
    });

    return result;
  }

  Indicator getConsistencyOverTimeIndicators(List<Indicator> objects, ConsistencyOverTime selected) {
    Indicator result = new Indicator();

    objects.forEach((obj) {
      if (selected.indicatorId == obj.id) {
        result = obj;
      }
    });

    return result;
  }

  void _buildTabs(List<String> sections) {
    _tabsNumber = 0;
    _tabsList = [];
    _tabViewList = [];
    sections.forEach((element) {
      if (element == "II. Data Accuracy") {
        _tabsNumber++;
        setState(() {
          _tabsList.add(Tab(
              child: Flexible(
                child: Text("Data Accuracy"),
              ),
              icon: Icon(Icons.computer)));
          _tabViewList.add(Scaffold(
            body: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
              _selectedIndicatorView(_dataAccuracyIndicators),
            ])),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await _selectIndicatorForm(context, _indicators);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ));
        });
      } else if (element == "I. Completeness/Timeliness") {
        _tabsNumber++;
        setState(() {
          _tabsList.add(Tab(
              child: Flexible(
                child: Text("Completeness"),
              ),
              icon: Icon(Icons.drag_indicator)));
          _tabViewList.add(Scaffold(
            body: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Column(
                    children: [
                      Divider(),
                      _dataElementCompletenessView(_dataElementCompletenessElements),
                    ],
                  ),
                  Column(
                    children: [
                      Divider(),
                      _sourceDocumentCompletenessView(_sourceDocumentCompletnessElements),
                    ],
                  )
                ])),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: UnicornDialer(
              parentButtonBackground: Colors.blue,
              parentButton: Icon(Icons.add),
              childButtons: _getCompletenessProfileMenu(),
            ),
          ));
        });
      } else if (element == "III. Cross check") {
        _tabsNumber++;
        _tabsList.add(Tab(
            child: Flexible(
              child: Text("Cross check"),
            ),
            icon: Icon(Icons.book)));
        _tabViewList.add(Scaffold(
          body: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _informationWidget(),
              _crossCheckView(_crossChecks),
            ],
          )),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await _crossCheckForm(context, _sourceDocuments);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
        ));
      } else if (element == "IV. Consistency over time") {
        _tabsNumber++;
        _tabsList.add(Tab(
            child: Flexible(
              child: Text("Consistency"),
            ),
            icon: Icon(Icons.drag_indicator)));
        _tabViewList.add(Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [_consistencyOverTimeView(_consistencyIndicator)],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!_dataEntryStatus)
                await _consistencyOverTimeForm(context, _indicators);
              else
                _dataExistInfo(context);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
        ));
      }
    });
  }

  Future<void> _addPlanningData(supervisionId, usePackage) async {
    _indicators = await configManager.getSupervisionConfig('indicator');
    if (usePackage) {
      _indicators.removeWhere((item) => item.isDhisDataElement == true);
    } else if (!usePackage) {
      _indicators.removeWhere((item) => item.isDhisDataElement == false);
    }

    _dataElements = await configManager.getSupervisionConfig('data_element');
    _sourceDocuments = await configManager.getSupervisionConfig('source_document');
    _dataEntryStatus = false;

    configManager.getDataRowsBySupervision('selectedindicator', supervisionId).then((value) {
      if (value != null || value.isNotEmpty) {
        setState(() {
          _selectedIndicators = value;
          _dataAccuracyIndicators = getDataAccuracyIndicators(_indicators, value);
        });
      } else {
        _selectedIndicators = new List<SelectedIndicator>();
      }
    });
    configManager.getDataRowsBySupervision('dataelementcompleteness', supervisionId).then((value) {
      if (value != null) {
        setState(() {
          _dataElementCompleteness = value;
          _dataElementCompletenessElements = getDataElementCompletenessElements(_dataElements, value);
        });
      } else {
        _dataElementCompleteness = new List<DataElementCompleteness>();
      }
    });
    configManager.getDataRowsBySupervision('sourcedocumentcompleteness', supervisionId).then((value) {
      if (value != null) {
        setState(() {
          _sourceDocumentCompleteness = value;
          _sourceDocumentCompletnessElements = getSourceDocumentCompletenessElements(_sourceDocuments, value);
        });
      } else {
        _sourceDocumentCompleteness = new List<SourceDocumentCompleteness>();
      }
    });
    configManager.getDataRowsBySupervision('crosscheck', supervisionId).then((value) {
      if (value != null || value.isNotEmpty || value != []) {
        setState(() {
          _crossChecks = value;
        });
      } else {
        _crossChecks = new List<CrossCheck>();
      }
    });
    configManager.getDataRowBySupervision('consistencyovertime', supervisionId).then((value) {
      if (value != null) {
        setState(() {
          _consistencyIndicator = getConsistencyOverTimeIndicators(_indicators, value);
        });
      } else {
        _consistencyOverTime = new ConsistencyOverTime();
      }
    });
    configManager.checkDataEntryStatus('entrycompletenessmonthlyreport', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entrytimelinessmonthlyreport', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entrydataelementcompleteness', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entrysourcedocumentcompleteness', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entrydataaccuracy', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entrycrosscheckab', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entryconsistencyovertime', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
    configManager.checkDataEntryStatus('entrysystemassessment', supervisionId).then((value) {
      if (value > 0) _dataEntryStatus = true;
    });
  }

  void _onDeleteConfirm(BuildContext context, String deleteType, int supervisionId, Object obj) {
    if (obj is DataElement)
      _warningContent = obj.name;
    else if (obj is SourceDocument)
      _warningContent = obj.name;
    else if (obj is Indicator)
      _warningContent = obj.name;
    else if (obj is CrossCheck)
      _warningContent = "cross check " +
          getItemById('source_document', _sourceDocuments, obj.primaryDataSourceId).name +
          " : " +
          getItemById('source_document', _sourceDocuments, obj.secondaryDataSourceId).name;

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
              title: Text('$_warningContent', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('Are you sure to remove $_warningContent?'),
              actions: [
                TextButton(
                  onPressed: () {
                    if (deleteType == 'DE' && obj is DataElement)
                      this._onDoubleTapDataElement(obj, supervisionId);
                    else if (deleteType == 'SRC' && obj is SourceDocument)
                      this._onDoubleTapSourceDocument(obj, supervisionId);
                    else if (deleteType == 'IND' && obj is Indicator)
                      this._onDoubleTapIndicator(obj, supervisionId);
                    else if (deleteType == 'CROSS' && obj is CrossCheck)
                      this._onDoubleTapCrossCheck(obj, supervisionId);
                    else {}
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'))
              ]);
        });
  }

  void _dataExistInfo(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
              title: Text('This supervision has data', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('Please clean the existing data before deleting configuration or update consistency'),
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

  Future<void> _deleteMetadata(String completenessType, int id, int supervisionId) async {
    await _metaDataManager.deleteCompletenessMetadata(completenessType, id, supervisionId);
  }

  void _onDoubleTapDataElement(DataElement dataElement, int supervisionId) {
    setState(() {
      _deleteMetadata('DATA_ELEMENT_COMPLETENESS', dataElement.id, supervisionId);
      _removeDataElementCompleteness(dataElement.id);
      _dataElementCompletenessElements.remove(dataElement);
    });
  }

  void _onDoubleTapSourceDocument(SourceDocument sourceDocument, int supervisionId) {
    setState(() {
      _deleteMetadata('SOURCE_DOCUMENT_COMPLETENESS', sourceDocument.id, supervisionId);
      _removeSourceDocumentCompleteness(sourceDocument.id);
      _sourceDocumentCompletnessElements.remove(sourceDocument);
    });
  }

  void _onDoubleTapIndicator(Indicator indicator, int supervisionId) {
    setState(() {
      _deleteMetadata('SELECTED_INDICATORS', indicator.id, supervisionId);
      _removeSelectedIndicator(indicator.id);
      _dataAccuracyIndicators.remove(indicator);
    });
  }

  void _removeSelectedIndicator(int indicatorId) {
    for (int i = 0; i < _selectedIndicators.length; i++) {
      if (_selectedIndicators[i].indicatorId == indicatorId) _selectedIndicators.remove(_selectedIndicators[i]);
    }
  }

  void _removeDataElementCompleteness(int dataElementId) {
    for (int i = 0; i < _dataElementCompleteness.length; i++) {
      if (_dataElementCompleteness[i].dataElementId == dataElementId) _dataElementCompleteness.remove(_dataElementCompleteness[i]);
    }
  }

  void _removeSourceDocumentCompleteness(int sourceDocumentId) {
    for (int i = 0; i < _sourceDocumentCompleteness.length; i++) {
      if (_sourceDocumentCompleteness[i].sourceDocumentId == sourceDocumentId) _sourceDocumentCompleteness.remove(_sourceDocumentCompleteness[i]);
    }
  }

  void _onDoubleTapCrossCheck(CrossCheck crossCheck, int supervisionId) {
    setState(() {
      _deleteMetadata('CROSS_CHECK', crossCheck.id, supervisionId);
      _crossChecks.remove(crossCheck);
    });
  }

  Widget _informationWidget() {
    return GestureDetector(
        child: Icon(
          Icons.info_outline,
          color: Colors.teal,
          size: 50,
        ),
        onDoubleTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CrossCheckHelpWidget()),
          );
        });
  }
}
