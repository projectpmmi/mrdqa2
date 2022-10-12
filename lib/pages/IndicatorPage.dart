import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrdqa_tool/Constants/IndicatorPageHelp.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:uuid/uuid.dart';
import '../models/DataElement.dart';
import '../models/Indicator.dart';
import '../models/SourceDocument.dart';

class IndicatorPage extends StatefulWidget {
  static String routeName = '/indicators';
  final ConfigManager configManager;

  IndicatorPage(this.configManager);

  @override
  _IndicatorPageState createState() => _IndicatorPageState(this.configManager);
}

class _IndicatorPageState extends State<IndicatorPage> {
  String _warningContent;
  final ConfigManager configManager;

  _IndicatorPageState(this.configManager);

  List<Indicator> _indicators;
  List<DataElement> _dataElements;
  List<SourceDocument> _sourceDocuments;

  @override
  void initState() {
    super.initState();

    _getMetadata();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // The number of tabs / content sections to display.
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Indicators', icon: Icon(Icons.computer)),
              Tab(text: 'Data elements', icon: Icon(Icons.drag_indicator)),
              Tab(text: 'Data sources', icon: Icon(Icons.book)),
            ],
          ),
          title: Text("Indicators"),
        ),
        drawer: Drawer(
          child: MenuManager(context, Routes(), this.configManager).getDrawer(),
        ),
        body: TabBarView(children: [
          Scaffold(
            body: ListView(children: [
              _informationWidget("indicator_help"),
              _indicatorsView(),
            ]),
          ),
          Scaffold(
            body: ListView(children: [
              _informationWidget("dataelement_help"),
              _dataElementsView(),
            ]),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await _addDataElementForm(context);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ), //IndicatorForm(context, Routes()).getDrawer(
          Scaffold(
            body: ListView(children: [
              _informationWidget("datasource_help"),
              _dataSourcesView(),
            ]),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await _addSourceDocumentForm(context);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _indicatorsView() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          child: _indicators != null
              ? DataTable(
                  columns: [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Name')),
                  ],
                  rows: _indicators
                      .map((indicator) => DataRow(cells: <DataCell>[
                            DataCell(Container(
                                width: 40, //SET width
                                child: Text(indicator.id.toString()))),
                            DataCell(Container(child: Text(indicator.name))),
                          ]))
                      .toList(),
                )
              : Container(
                  child: Center(
                    child: Text("Empty indicators"),
                  ),
                )),
    );
  }

  Widget _dataElementsView() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          child: _dataElements != null
              ? DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                  ],
                  rows: _dataElements
                      .map((dataElement) => DataRow(cells: <DataCell>[
                            DataCell(
                              GestureDetector(
                                  onDoubleTap: () async {
                                    _onDeleteConfirm(context, 'DE', dataElement);
                                  },
                                  child: Text(dataElement.name)),
                            ),
                          ]))
                      .toList(),
                )
              : Container(
                  child: Center(
                    child: Text("Empty Data Element"),
                  ),
                )),
    );
  }

  Widget _dataSourcesView() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          child: _sourceDocuments != null
              ? DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                  ],
                  rows: _sourceDocuments
                      .map((dataSource) => DataRow(cells: <DataCell>[
                            DataCell(GestureDetector(
                                child: Text(dataSource.name),
                                onDoubleTap: () async {
                                  _onDeleteConfirm(context, 'SRC', dataSource);
                                })),
                          ]))
                      .toList(),
                )
              : Container(
                  child: Center(
                    child: Text("Empty Source documents"),
                  ),
                )),
    );
  }

  Future<void> _addDataElementForm(BuildContext context) async {
    GlobalKey<FormState> _dataelementformkey = GlobalKey<FormState>();

    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _dataElementName = TextEditingController();

          return AlertDialog(
            content: Form(
              key: _dataelementformkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _dataElementName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: 'Data Element name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'The Data element should have a name';
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
                  if (_dataelementformkey.currentState.validate()) {
                    String name = _dataElementName.text;
                    var uuid = Uuid();
                    String uid = uuid.v1();
                    DataElement dataElement = new DataElement(
                      name: name,
                      uid: uid,
                    );
                    configManager.saveRowData('data_element', dataElement).then((value) {
                      setState(() {
                        _dataElements.add(dataElement);
                      });
                      Navigator.of(context).pop();
                    });
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _addSourceDocumentForm(BuildContext context) async {
    GlobalKey<FormState> _sourcedocumentformkey = GlobalKey<FormState>();

    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _sourceDocumentName = TextEditingController();

          return AlertDialog(
            content: Form(
              key: _sourcedocumentformkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _sourceDocumentName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: 'Source document name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'The Source document should have a name';
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
                  if (_sourcedocumentformkey.currentState.validate()) {
                    String name = _sourceDocumentName.text;
                    var uuid = Uuid();
                    String uid = uuid.v1();
                    SourceDocument sourceDocument = new SourceDocument(
                      name: name,
                      uid: uid,
                    );
                    configManager.saveRowData('source_document', sourceDocument).then((value) {
                      setState(() {
                        _sourceDocuments.add(sourceDocument);
                      });
                      Navigator.of(context).pop();
                    });
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _getMetadata() async {
    _dataElements = await configManager.getSupervisionConfig('data_element');
    _indicators = await configManager.getSupervisionConfig('indicator');
    _sourceDocuments = await configManager.getSupervisionConfig('source_document');
    setState(() {});
  }

  Future<void> _deleteMetadata(String uid, String configType) async {
    await configManager.clearSupervisionConfig(uid, configType);
  }

  void _onDoubleTapDataElement(DataElement dataElement) {
    setState(() {
      var dataElementUid = dataElement.uid.toString();
      this._deleteMetadata(dataElementUid, "data_element");
      _dataElements.remove(dataElement);
    });
  }

  void _onDoubleTapSourceDocument(SourceDocument sourceDocument) {
    setState(() {
      var sourceDocumentUid = sourceDocument.uid.toString();
      this._deleteMetadata(sourceDocumentUid, "source_document");
      _sourceDocuments.remove(sourceDocument);
    });
  }

  void _onDeleteConfirm(BuildContext context, String deleteType, Object obj) {
    if (obj is DataElement)
      _warningContent = obj.name;
    else if (obj is SourceDocument) _warningContent = obj.name;

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(title: Text('Please Confirm'), content: Text('Are you sure you want to remove $_warningContent?'), actions: [
            TextButton(
              onPressed: () {
                if (deleteType == 'DE' && obj is DataElement)
                  this._onDoubleTapDataElement(obj);
                else if (deleteType == 'SRC')
                  this._onDoubleTapSourceDocument(obj);
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

  _showHelpTextDialog(String tab, String helpText) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Info!"),
              content: new Text(helpText),
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

  Widget _informationWidget(String tab) {
    return GestureDetector(
        child: Icon(
          Icons.info_outline,
          color: Colors.teal,
          size: 50,
        ),
        onDoubleTap: () {
          var helpText = '';
          switch (tab) {
            case 'indicator_help':
              helpText = IndicatorPageHelp.indicator_help;
              break;
            case 'dataelement_help':
              helpText = IndicatorPageHelp.dataelement_help;
              break;
            case 'datasource_help':
              helpText = IndicatorPageHelp.datasource_help;
              break;
          }
          _showHelpTextDialog(tab, helpText);
        });
  }
}
