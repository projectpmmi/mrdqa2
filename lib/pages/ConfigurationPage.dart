import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mrdqa_tool/Constants/ConfigHelp.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/models/Config.dart';
import 'package:mrdqa_tool/models/CrossCheckDatastore.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/DataSet.dart';
import 'package:mrdqa_tool/models/DataValue.dart';
import 'package:mrdqa_tool/models/DatastorePayload.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/IndicatorDatastore.dart';
import 'package:mrdqa_tool/models/Payload.dart';
import 'package:mrdqa_tool/models/PlanningDatastore.dart';
import 'package:mrdqa_tool/models/SupervisionPeriod.dart';
import 'package:mrdqa_tool/models/SupervisionSection.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:mrdqa_tool/services/DatastoreManager.dart';
import 'package:mrdqa_tool/services/DhisExport.dart';
import 'package:mrdqa_tool/services/DhisManager.dart';
import 'package:mrdqa_tool/services/MetadataMappingService.dart';
import 'package:mrdqa_tool/services/RemoteConfigManager.dart';
import 'package:mrdqa_tool/services/SecurityManager.dart';
import 'package:mrdqa_tool/widgets/ServerAddressInput.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:intl/intl.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/models/Visit.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';
import 'package:mrdqa_tool/models/CrossCheck.dart';
import 'package:mrdqa_tool/models/ConsistencyOverTime.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:mrdqa_tool/models/SourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/CategoryOptionCombo.dart';

class ConfigurationPage extends StatefulWidget {
  static String routeName = '/configuration';
  final ConfigManager configManager;

  ConfigurationPage({@required this.configManager});

  @override
  _ConfigPageState createState() => _ConfigPageState(this.configManager);
}

class _ConfigPageState extends State<ConfigurationPage> with SingleTickerProviderStateMixin {
  bool _connectError = false;
  DhisManager _dhisManager;
  RemoteConfigManager _remoteConfigManager;
  DatastoreManager _dataStoreManager;
  String _metaDataType;
  String _level;
  String _program;
  String _programName;
  String _programPeriodType;
  TabController _tabController;
  FToast _configSaveToast;
  final _formKey = GlobalKey<FormState>();
  final _formSearchKey = GlobalKey<FormState>();
  final ConfigManager configManager;
  MetadataMappingService metadataMapping;

  //final NetworkManager networkManager = new NetworkManager("https://www.google.com");
  final SecurityManager _securityManager = new SecurityManager();
  TextEditingController _baseUrlTextController = TextEditingController();
  TextEditingController _passwordController;
  TextEditingController _usernameController;
  final Config _config = new Config();
  List<Facility> _facilities;
  Future<List<Map<String, dynamic>>> _orgUnitLevels;
  Future<List<dynamic>> _supervisedFacilities;
  int _radioValue1 = 0;
  int _configRadioValue = 0;

  ///Added for testing purposes only.
  DhisExport _dhisExport;
  bool _configChanged;
  List<Supervision> _supervisions;
  List<Supervision> _supervisionPlanning;
  List<DataSet> _dataSetConfig;
  List<DataElement> _dataElementConfig;
  List<CategoryOptionCombo> _categoryOptionComboConfig;

  _ConfigPageState(this.configManager);

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    Future<Config> config = configManager.getConfig();
    metadataMapping = new MetadataMappingService();

    /// Configures default settings for source documents, sections, data elements
    ///and periods that have already been preloaded in CSV files.
    configManager.configureDefaultSettings("SOURCE_DOCUMENT");
    configManager.configureDefaultSettings("SECTIONS");
    configManager.configureDefaultSettings("PERIODS");
    configManager.configureDefaultSettings("DATA_ELEMENTS");
    configManager.configureDefaultSettings("ENTRY_DISCREPANCIES");
    configManager.configureDefaultSettings("INDICATORS");
    _supervisedFacilities = configManager.getSupervisionConfig("facility");
    _configSaveToast = FToast();
    _configSaveToast.init(context);
    _configChanged = false;

    config.then((data) {
      setState(() {
        //_baseUrlTextController = new TextEditingController(text: data.getBaseUrl());
        _baseUrlTextController.text = data.getBaseUrl();
        _passwordController = new TextEditingController(text: _securityManager.decrypt(data.getPassword()));
        _usernameController = new TextEditingController(text: data.getUsername());
        _level = data.getLevel();
        _program = data.getProgram();
        _programName = data.getProgramName();
        _programPeriodType = data.getProgramPeriodType();

        Map<String, String> configs = new Map();
        configs['baseUrl'] = data.getBaseUrl();
        configs['username'] = data.getUsername();
        configs['password'] = data.getPassword();
        configs['program'] = data.getProgram();
        //configs['program_name'] = data.getProgramName();
        _remoteConfigManager = new RemoteConfigManager(configs);
        _dataStoreManager = new DatastoreManager(configs);
        _dhisExport = DhisExport(configs);
        _dhisManager = new DhisManager(configs);
        _orgUnitLevels = _dhisManager.getOrgUnitLevels();
        // Pull metadata mapping in local database
        _pullMetadataMappingConfig();
      });
    });

    configManager.getSupervisionConfig('supervision').then((value) {
      if (value != null && value.length > 0) {
        setState(() => _supervisions = value);
      } else {
        setState(() {
          _supervisions = null;
        });
      }
    });
    configManager.getSupervisionConfig('supervision_planning').then((value) {
      if (value != null && value.length > 0) {
        setState(() => _supervisionPlanning = value);
      } else {
        setState(() {
          _supervisionPlanning = null;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Configuration'),
        bottom: new TabBar(
          tabs: [
            new Tab(icon: new Icon(FontAwesomeIcons.wrench)),
            new Tab(
              icon: new Icon(FontAwesomeIcons.hospital),
            ),
            new Tab(
              icon: new Icon(FontAwesomeIcons.wpexplorer),
            ),
            new Tab(
              icon: new Icon(FontAwesomeIcons.anchor),
            )
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
        ),
        bottomOpacity: 1,
      ),
      drawer: Drawer(
        child: MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: new TabBarView(
        children: [
          new SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    _informationWidget("config_tab", this._configRadioValue),
                    ServerAddressInput(_baseUrlTextController),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.lock),
                        labelText: "Username",
                      ),
                      controller: _usernameController,
                      onChanged: (text) {
                        _configChanged = true;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.lock),
                        labelText: "Password",
                      ),
                      controller: _passwordController,
                      onChanged: (text) {
                        _configChanged = true;
                      },
                      obscureText: true,
                    ),
                    //_remoteConfigurationWidget(),
                    _levelDropdown(),
                    const SizedBox(height: 30),
                    new ElevatedButton(
                        style: style,
                        child: const Text('Save'),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            configManager.clearConfigs();
                            if (!this._connectError) {
                              var remoteConfig = await _remoteConfigManager.getDatasetConfig(code: "MRDQA_DATA_COLLECTION");
                              if (remoteConfig.isNotEmpty) {
                                var program = remoteConfig.elementAt(0);
                                _config.setProgram(program.uid);
                                _config.setProgramName(program.displayName);
                                _config.setProgramPeriodType(program.periodType);
                              }
                            }
                            _config.setBaseUrl(_baseUrlTextController.text);
                            _config.setUsername(_usernameController.text);
                            _config.setPassword(_passwordController.text);
                            _config.setLevel(_level);
                            configManager.saveConfig(_config);
                            setState(() {
                              _programName = _config.getProgramName();
                              _program = _config.getProgram();
                              _programPeriodType = _config.getProgramPeriodType();
                            });
                            // todo make sure to update levels when url change as well
                            if (_configChanged) {
                              if (!this._connectError) {
                                print("Something changed in config");
                                setState(() {
                                  _orgUnitLevels = _dhisManager.getOrgUnitLevels();
                                });
                                _configChanged = false;
                              }
                            }
                            // Update plannings table
                            if (!this._connectError) {
                              configManager.clearTable('PLANNING');
                              configManager.clearTable('METADATA_MAPPING');
                              Map<String, String> configs = new Map();
                              configs['baseUrl'] = _config.getBaseUrl();
                              configs['username'] = _config.getUsername();
                              configs['password'] = _securityManager.encrypt(_config.getPassword()).base16;
                              configs['program'] = _config.getProgram();
                              _dataStoreManager = new DatastoreManager(configs);
                              _initPlanning();
                              _pullMetadataMappingConfig();
                            }
                            _showToast("Config Saved!");
                          }
                        }),
                  ],
                ),
              ),
            ]),
          )),
          new Form(
            key: _formSearchKey,
            child: new Container(
              child: new Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  _informationWidget("metadata_tab", this._configRadioValue),
                  new Row(
                    children: _getConfigRadioButtons(),
                  ),
                  Expanded(
                      child: new FutureBuilder<dynamic>(
                    future: _supervisedFacilities,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.data.length != 0) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return new SafeArea(
                                child: new Container(
                                  child: new SingleChildScrollView(
                                      child: new Column(
                                    children: List.generate(snapshot.data.length, (index) {
                                      return new CheckboxListTile(
                                        title: new Text(snapshot.data[index].name),
                                        value: snapshot.data[index].isSupervisable,
                                        onChanged: (bool value) {
                                          setState(() {
                                            snapshot.data[index].isSupervisable = value;
                                            if (value) {
                                              String configTable = _getConfigMetaDataType(_configRadioValue);
                                              if (configTable == 'facility')
                                                configManager.saveSupervisionConfig(snapshot.data[index].uid, snapshot.data[index].name,
                                                    snapshot.data[index].isDhisFacility, configTable);
                                              else
                                                configManager.saveSupervisionConfig(snapshot.data[index].uid, snapshot.data[index].name,
                                                    snapshot.data[index].isDhisDataElement, configTable);
                                              _showToast("${snapshot.data[index].name}: has been saved.");
                                            } else {
                                              configManager.clearSupervisionConfig(
                                                  snapshot.data[index].uid, _getConfigMetaDataType(_configRadioValue));
                                              _showToast("${snapshot.data[index].name}: has been removed.");
                                            }
                                          });
                                        },
                                      );
                                    }),
                                  )),
                                ),
                              );
                            });
                      } else {
                        return Center(child: new Text("No Metadata Configuration available"));
                      }
                    },
                  ))
                ],
              ),
            ),
          ),
          new Container(
            child: new SafeArea(
                child: new SearchBar(
              searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
              onSearch: _search,
              onItemFound: (dynamic obj, int index) {
                return new Container(
                    child: new SingleChildScrollView(
                  child: new Column(
                    children: [
                      new CheckboxListTile(
                        title: new Text(obj.name),
                        value: obj.isSupervisable,
                        onChanged: (bool value) {
                          setState(() {
                            obj.isSupervisable = value;
                            if (value) {
                              if (_metaDataType == 'facility')
                                configManager.saveSupervisionConfig(obj.uid, obj.name, obj.isDhisFacility.toString(), _metaDataType);
                              else
                                configManager.saveSupervisionConfig(obj.uid, obj.name, 'true', _metaDataType);
                              _showToast("${obj.name}: has been saved.");
                            } else {
                              configManager.clearSupervisionConfig(obj.uid, _metaDataType);
                              _showToast("${obj.name}: has been removed.");
                            }
                          });
                        },
                      )
                    ],
                  ),
                ));
              },
              listPadding: EdgeInsets.symmetric(horizontal: 10),
              placeHolder: new Text("placeholder"),
              cancellationWidget: new Text("Cancel"),
              emptyWidget: new Text("empty"),
              header: new Row(
                children: _getSearchRadioButtons(),
              ),
              onCancelled: () {},
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 2,
            )),
          ),
          new Container(
              child: new SafeArea(
                  child: Column(
            children: [
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Dataset Name: ',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(text: "$_programName ", style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                  text: TextSpan(text: "Dataset UID: ", style: TextStyle(color: Colors.black, fontSize: 18), children: <TextSpan>[
                TextSpan(text: "$_program", style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
              ])),
              SizedBox(height: 15),
              _informationWidget("planning_tab", this._configRadioValue),
              SizedBox(height: 15),
              ElevatedButton(
                style: style,
                onPressed: () async {
                  var res = await _dataStoreManager.get();
                  if (res.isNotEmpty) {
                    var val;
                    Supervision sup;
                    _supervisionPlanning = [];
                    configManager.clearTable('PLANNING');
                    res.forEach((element) async {
                      val = await _dataStoreManager.getValue(element);
                      sup = Supervision(description: val["name"], period: DateTime.parse(val["period"]), uid: element);
                      if (_supervisionPlanning != null) {
                        _supervisionPlanning.add(sup);
                      } else {
                        _supervisionPlanning = [sup];
                      }
                      setState(() {});
                      configManager.saveRowData('supervision_planning', sup);
                    });
                    _showToast("Planning Imported!");
                  }
                },
                child: const Text('Refresh plannings'),
              ),
              SizedBox(height: 10),
              _planningView(),
            ],
          ))),
        ],
        controller: _tabController,
      ),
    );
  }

  void _facilityRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  //
  void _indicatorRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  void _dataElementRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  Future<List<dynamic>> _search(String search) async {
    List<Object> searchResults = new List<Object>();
    var config = await configManager.getConfig();
    Map<String, String> configs = new Map();
    configs['baseUrl'] = config.getBaseUrl();
    configs['username'] = config.getUsername();
    configs['password'] = config.getPassword();
    configs['level'] = config.getLevel();
    _dhisManager = new DhisManager(configs);

    if (_radioValue1 == 0) {
      //search orgunits
      _metaDataType = 'facility';
      var results = await _dhisManager.searchFacilities(search);

      if (results.isNotEmpty && results.length > 0) {
        results.asMap().forEach((key, value) async {
          // Checking if this config exist in database
          bool configExists = await _configExists(value.uid, _metaDataType);

          if (configExists) {
            results[key].isSupervisable = true;
          }

          Facility isFromPackage = await _isFromPackage(value.uid);
          if (isFromPackage != null) {
            results[key].isDhisFacility = false;
          }
        });
      }
      return results;
    } else if (_radioValue1 == 1) {
      List<Object> indicatorResults = [];
      _metaDataType = 'indicator';
      var results = await _dhisManager.searchIndicators(search);
      if (results.isNotEmpty && results.length > 0) {
        results.asMap().forEach((key, value) async {
          // Checking if this config exist in database
          bool configExists = await _configExists(value.uid, _metaDataType);

          if (configExists) {
            setState(() {
              results[key].isSupervisable = true;
            });
          }
        });
      }
      return results;
    }

    if (_radioValue1 == 2) {
      _metaDataType = 'data_element';
      var results = await _dhisManager.searchDataElements(search);
      if (results.isNotEmpty && results.length > 0) {
        results.asMap().forEach((key, value) async {
          // Checking if this config exist in database
          bool configExists = await _configExists(value.uid, _metaDataType);
          if (configExists) {
            setState(() {
              results[key].isSupervisable = true;
            });
          }
        });
      }
      return results;
    }

    return searchResults;
  }

  //Check if a config exist in the database. Return a row or false.
  dynamic _configExists(String uid, String configType) async {
    dynamic conf = await configManager.getConfigRow(uid, configType);
    return conf;
  }

  // Check if is from package
  Future<Facility> _isFromPackage(String uid) async {
    Facility fac = new Facility();
    if (_facilities != null) fac = _facilities.firstWhere((element) => element.uid == uid, orElse: () => null);

    return fac;
  }

  // Get facility by uid
  Future<Facility> getFacilityByUid(String uid) async {
    Facility fac;
    await _supervisedFacilities.then((value) {
      fac = value.firstWhere((element) => element.uid == uid, orElse: () => null);
    });

    return fac;
  }

  Future<bool> areFacilitiesPulled(List<dynamic> facilitiesPlanning) async {
    List<Facility> facs = await configManager.getSupervisionConfig("facility");
    bool pulled = false;
    Facility fac;
    if (facs != null) {
      pulled = true;
      facilitiesPlanning.asMap().forEach((key, v) {
        fac = facs.firstWhere((element) => element.uid == v, orElse: () => null);
        if (fac == null) {
          pulled = false;
          print("This facility is not pulled: $v");
        }
      });
    }

    return pulled;
  }

  Future<Supervision> doesSupervisionExist(String uid) async {
    Supervision sup;
    if (_supervisions != null) {
      sup = _supervisions.firstWhere((element) => element.uid == uid, orElse: () => null);
    }

    return sup;
  }

  Supervision getSupervisionByUid(String uid) {
    Supervision sup;
    if (_supervisions != null) {
      sup = _supervisions.firstWhere((element) => element.uid == uid, orElse: () => null);
    }

    return sup;
  }

  //displays the save configuration toast
  _showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
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

    _configSaveToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  FutureBuilder<dynamic> _levelDropdown() {
    return new FutureBuilder<dynamic>(
        future: _orgUnitLevels,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            this._connectError = false;
            //_level = snapshot.data[0]['id'];
            return new DropDownFormField(
              titleText: 'Orgunit Level',
              hintText: 'Please choose one',
              value: _level == '' ? snapshot.data[0]['level'] : _level,
              //value: snapshot.data[0]['level'],
              onChanged: (value) {
                setState(() {
                  _level = value.toString();
                });
              },
              dataSource: snapshot.data,
              textField: 'name',
              valueField: 'level',
            );
          } else {
            //return new Center(child: new CircularProgressIndicator());
            this._connectError = true;
            return new Text("Configuration errors");
          }
        });
  }

  //Search Tab bar radio buttons
  List<Widget> _getSearchRadioButtons() {
    return [
      new Radio(
        value: 0,
        groupValue: _radioValue1,
        onChanged: _facilityRadioValueChange,
      ),
      new Text(
        'Facility',
        style: new TextStyle(fontSize: 16.0),
      ),
      new Radio(
        value: 1,
        groupValue: _radioValue1,
        onChanged: _indicatorRadioValueChange,
      ),
      new Text(
        'Indicator',
        style: new TextStyle(
          fontSize: 16.0,
        ),
      ),
      new Radio(
        value: 2,
        groupValue: _radioValue1,
        onChanged: _dataElementRadioValueChange,
      ),
      new Text(
        'Data Element',
        style: new TextStyle(
          fontSize: 16.0,
        ),
      )
    ];
  }

  //Creates Radio buttons to manage config items
  List<Widget> _getConfigRadioButtons() {
    return [
      new Radio(
        value: 0,
        groupValue: _configRadioValue,
        onChanged: _facilityConfigRadioValueChange,
      ),
      new Text(
        'Facility',
        style: new TextStyle(fontSize: 16.0),
      ),
      new Radio(
        value: 1,
        groupValue: _configRadioValue,
        onChanged: _indicatorConfigRadioValueChange,
      ),
      new Text(
        'Indicator',
        style: new TextStyle(
          fontSize: 16.0,
        ),
      )
    ];
  }

  void _facilityConfigRadioValueChange(int value) {
    setState(() {
      _configRadioValue = value;
      _supervisedFacilities = configManager.getSupervisionConfig("facility");
    });
  }

  //
  void _indicatorConfigRadioValueChange(int value) {
    setState(() {
      _configRadioValue = value;
      _supervisedFacilities = configManager.getSupervisionConfig("indicator");
    });
  }

  String _getConfigMetaDataType(int selectedValue) {
    String metaData = '';
    if (selectedValue == 0) {
      metaData = 'facility';
    } else if (selectedValue == 1) {
      metaData = 'indicator';
    } else if (selectedValue == 2) {
      metaData = 'data_element';
    } else {
      metaData = 'facility';
    }
    return metaData;
  }

  _showHelpTextDialog(String helpText) {
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

  Widget _informationWidget(String tab, int configRadioValue) {
    return GestureDetector(
        child: Icon(
          Icons.info_outline,
          color: Colors.teal,
          size: 50,
        ),
        onDoubleTap: () {
          var helpText = '';
          switch (tab) {
            case 'config_tab':
              helpText = ConfigHelp.config_help;
              break;
            case 'metadata_tab':
              if (configRadioValue == 0)
                helpText = ConfigHelp.metadata_help_facility;
              else
                helpText = ConfigHelp.metadata_help_indicator;
              break;
            case 'search_tab':
              helpText = ConfigHelp.search_help;
              break;
            case 'planning_tab':
              helpText = ConfigHelp.planning_help;
              break;
          }
          _showHelpTextDialog(helpText);
        });
  }

  Widget _remoteConfigurationWidget() {
    return _program == null
        ? Text("No Remote Config set")
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.note_add_sharp),
                  RichText(
                      text: TextSpan(style: Theme.of(context).textTheme.bodyText1, children: [
                    TextSpan(text: "$_programName "),
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(Icons.perm_identity_sharp),
                    )),
                    TextSpan(text: "UID: $_program")
                  ]))
                ],
              ),
            ],
          );
  }

  Widget _planningView() {
    if (_supervisionPlanning != null) _supervisionPlanning.sort((a, b) => b.period.compareTo(a.period));
    return Expanded(
      child: ListView(children: [
        _supervisionPlanning != null
            ? DataTable(
                columns: [
                  DataColumn(label: Text('Remote Plannings')),
                ],
                rows: _supervisionPlanning
                    .map((entry) => DataRow(cells: <DataCell>[
                          DataCell(GestureDetector(
                            onDoubleTap: () async {
                              if (!this._connectError) {
                                print("No error connexion");
                                Supervision existingSupervision = await doesSupervisionExist(entry.uid);
                                if (existingSupervision == null) {
                                  var val = await _dataStoreManager.getValue(entry.uid);
                                  bool facilitiesPulled = await areFacilitiesPulled(val['facilities']);
                                  if (facilitiesPulled) {
                                    Supervision sup = Supervision(
                                        description: val['name'], period: DateTime.parse(val["period"]), usePackage: true, uid: entry.uid);
                                    configManager.saveRowData('supervision', sup).then((value) async {
                                      if (value != null) {
                                        sup.setId(value);
                                        // Facilities and visits
                                        if (val['supervisions'] != null && val['supervisions'].length > 0) {
                                          val['supervisions'].asMap().forEach((key, v) async {
                                            Facility fac;
                                            SupervisionFacilities supervisionFacility;
                                            Visit visit;
                                            fac = await getFacilityByUid(v['facility_code']);
                                            supervisionFacility = new SupervisionFacilities(supervisionId: value, facilityId: fac.id);
                                            visit = new Visit(
                                                supervisionId: value,
                                                facilityId: fac.id,
                                                date: DateTime.parse(v['date_visit']),
                                                teamLead: v['team_lead']);
                                            // Selected facility
                                            configManager.saveRowData('supervisionfacility', supervisionFacility).then((value) {
                                              configManager.saveRowData('visit', visit);
                                            });
                                          });
                                        }
                                        // Data accuracy
                                        if (val['indicators']['data_accuracy'] != null) {
                                          SelectedIndicator accuracyPlaning;
                                          val['indicators']['data_accuracy'].forEach((key, v) async {
                                            accuracyPlaning = SelectedIndicator(indicatorId: v, number: int.parse(key), supervisionId: value);
                                            configManager.saveRowData('selectedindicator', accuracyPlaning);
                                          });
                                        }
                                        // Cross checks
                                        if (val['indicators']['cross_checks'] != null) {
                                          CrossCheck crossChecksPlanning;
                                          val['indicators']['cross_checks'].forEach((key, v) async {
                                            crossChecksPlanning = CrossCheck(
                                                primaryDataSourceId: v['primary'],
                                                secondaryDataSourceId: v['secondary'],
                                                type: key,
                                                supervisionId: value);
                                            configManager.saveRowData('crosscheck', crossChecksPlanning);
                                          });
                                        }
                                        // Consistency overtime
                                        if (val['indicators']['consistency'] != null) {
                                          ConsistencyOverTime consistencyPlanning =
                                              ConsistencyOverTime(indicatorId: val['indicators']['consistency'], supervisionId: value);
                                          configManager.saveRowData('consistencyovertime', consistencyPlanning);
                                        }
                                        // Completeness
                                        if (val['indicators']['completeness'] != null) {
                                          if (val['indicators']['completeness']['data_element'] != null) {
                                            DataElementCompleteness dataElementPlanning;
                                            val['indicators']['completeness']['data_element'].forEach((key, v) async {
                                              dataElementPlanning =
                                                  DataElementCompleteness(dataElementId: v, number: int.parse(key), supervisionId: value);
                                              configManager.saveRowData('dataelementcompleteness', dataElementPlanning);
                                            });
                                          }
                                          if (val['indicators']['completeness']['source_document'] != null) {
                                            SourceDocumentCompleteness sourceDocumentPlanning;
                                            val['indicators']['completeness']['source_document'].forEach((key, v) async {
                                              sourceDocumentPlanning =
                                                  SourceDocumentCompleteness(sourceDocumentId: v, number: int.parse(key), supervisionId: value);
                                              configManager.saveRowData('sourcedocumentcompleteness', sourceDocumentPlanning);
                                            });
                                          }
                                        }
                                        // Period planning
                                        if (val['supervisionsection'] != null && val['supervisionsection'].length > 0) {
                                          SupervisionSection supervisionSection;
                                          val['supervisionsection'].asMap().forEach((key, v) async {
                                            supervisionSection = new SupervisionSection(supervisionId: value, sectionNumber: v);
                                            configManager.saveRowData('supervisionsection', supervisionSection);
                                          });
                                        }
                                        // Section planning
                                        if (val['supervisionperiod'] != null && val['supervisionperiod'].length > 0) {
                                          SupervisionPeriod supervisionPeriod;
                                          val['supervisionperiod'].asMap().forEach((key, v) async {
                                            supervisionPeriod = new SupervisionPeriod(supervisionId: value, periodNumber: v);
                                            configManager.saveRowData('supervisionperiod', supervisionPeriod);
                                          });
                                        }
                                        setState(() {
                                          if (_supervisions != null) {
                                            _supervisions.add(sup);
                                          } else {
                                            _supervisions = [sup];
                                          }
                                          if (_supervisionPlanning != null) {
                                            _removePlanningByUid(sup.uid);
                                            _supervisionPlanning.add(sup);
                                          } else {
                                            _supervisionPlanning = [sup];
                                          }
                                        });
                                        _showToast("This supervision is added!");
                                      }
                                    });
                                  } else {
                                    print("Check that all your facilities are pulled");
                                    await _missingMetadata(context, "facility");
                                  }
                                } else {
                                  print("This supervision already exist: ${entry.uid}");
                                  await _missingMetadata(context, "supervision");
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  getSupervisionByUid(entry.uid) == null
                                      ? CircleAvatar(
                                          radius: 14.0,
                                          backgroundColor: Colors.amber,
                                        )
                                      : CircleAvatar(
                                          radius: 14.0,
                                          backgroundColor: Colors.blue,
                                        ),
                                  Expanded(child: Text("${entry.description} (${DateFormat.yMMM('en_US').format(entry.period)})")),
                                ],
                              ),
                            ),
                          )),
                        ]))
                    .toList(),
              )
            : Container(
                child: Center(
                  child: Text("Empty Remote Planning"),
                ),
              )
      ]),
    );
  }

  void _initPlanning() async {
    var res = await _dataStoreManager.get();
    if (res.isNotEmpty) {
      var val;
      Supervision sup;
      _supervisionPlanning = [];
      res.forEach((element) async {
        val = await _dataStoreManager.getValue(element);
        sup = Supervision(description: val["name"], period: DateTime.parse(val["period"]), uid: element);
        if (_supervisionPlanning != null) {
          _supervisionPlanning.add(sup);
        } else {
          _supervisionPlanning = [sup];
        }
        configManager.saveRowData('supervision_planning', sup);
      });
    }
  }

  void _pullMetadataMappingConfig() async {
    _dataSetConfig = await _remoteConfigManager.getDatasetConfig();
    _dataElementConfig = await _remoteConfigManager.getDataElementConfigs();
    String codes = metadataMapping.getSingleRemoteId('category_option_combos');
    _categoryOptionComboConfig = await _remoteConfigManager.getCategoryOptionComboConfigs(codes);
    configManager.metaDataMapping('METADATA_MAPPING', _dataSetConfig, _dataElementConfig, _categoryOptionComboConfig);
    _facilities = await _remoteConfigManager.getFacilityConfigs(code: "MRDQA_DATA_COLLECTION");
  }

  Future<void> _missingMetadata(BuildContext context, String type) {
    String title;
    String message;
    switch (type) {
      case 'facility':
        title = "Facility issue";
        message =
            "One or more remote facilities are missing in your local database, please make sure all the facilities used by this planning are pulled first.";
        break;

      case 'supervision':
        title = "Supervision issue";
        message =
            "The supervision you are trying to pull do already exist. If you want to replace it please remove it first in the supervision planning page then come back and push again.";
        break;
    }
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(title: Text(title), content: Text(message), actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Ok'),
            )
          ]);
        });
  }

  Future<void> _removePlanningByUid(String uid) {
    _supervisionPlanning.removeWhere((item) => item.uid == uid);
  }
}
