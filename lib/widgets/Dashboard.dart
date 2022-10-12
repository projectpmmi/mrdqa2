import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mrdqa_tool/Vizdata/Data.dart';
import 'package:mrdqa_tool/Vizdata/SeriesData.dart';
import 'package:mrdqa_tool/models/EntryDataAccuracyDiscrepancy.dart';
import 'package:mrdqa_tool/models/EntryDiscrepancies.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/models/Periods.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/SupervisionPeriod.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:select_form_field/select_form_field.dart';

class Dashboard extends StatefulWidget {
  final ConfigManager configManager;
  Supervision selectedSupervision;
  List<Facility> selectedFacilities;

  Dashboard(this.configManager, this.selectedSupervision, this.selectedFacilities);

  @override
  _DashboardState createState() => _DashboardState(this.configManager, this.selectedSupervision, this.selectedFacilities);
}

class _DashboardState extends State<Dashboard> {
  final ConfigManager configManager;
  Supervision selectedSupervision;
  List<Facility> selectedFacilities;
  List<DataElement> _dataElements;
  List<SourceDocument> _sourceDocuments;
  List<Indicator> _indicators;
  List<Periods> _periods;
  List<SupervisionPeriod> _supervisionPeriods;
  List<SeriesData> consistancyOverTime;
  List<Data> crossCheckData;
  List<Data> performanceReadinessData;
  List<charts.Series<Data, String>> verificationFactorsData;
  List<charts.Series<Data, String>> indicatorDiscrepencyData;
  List<Map<String, dynamic>> _dropItems = [];
  TextEditingController _facilityController = TextEditingController();
  List<SelectedIndicator> _selectedIndicators;
  List<EntryDiscrepancies> _discrepancies;
  Map<int, charts.Color> _discrepancyColors;
  Map<int, Color> _legendColors;
  Map<int, charts.Color> _verificationFactorColors;
  Map<int, Color> _verificationFactorLegendColors;
  String _consistencyIndicatorName;
  String _crossCheck1;
  String _crossCheck2;
  String _crossCheck3;

  _DashboardState(this.configManager, this.selectedSupervision, this.selectedFacilities);

  @override
  void initState() {
    _selectedIndicators = [];
    _discrepancies = [];
    _discrepancyColors = {
      1: charts.MaterialPalette.blue.shadeDefault,
      2: charts.MaterialPalette.purple.shadeDefault,
      3: charts.MaterialPalette.cyan.shadeDefault,
      4: charts.MaterialPalette.indigo.shadeDefault,
      5: charts.MaterialPalette.lime.shadeDefault,
      6: charts.MaterialPalette.teal.shadeDefault,
      7: charts.MaterialPalette.gray.shadeDefault,
      8: charts.MaterialPalette.yellow.shadeDefault,
      9: charts.MaterialPalette.red.shadeDefault,
      10: charts.MaterialPalette.green.shadeDefault,
    };
    _legendColors = {
      1: Colors.blue,
      2: Colors.purple,
      3: Colors.cyan,
      4: Colors.indigo,
      5: Colors.lime,
      6: Colors.teal,
      7: Colors.black26,
      8: Colors.yellow,
      9: Colors.red,
      10: Colors.green,
    };
    _verificationFactorColors = {
      1: charts.MaterialPalette.blue.shadeDefault,
      2: charts.MaterialPalette.deepOrange.shadeDefault,
    };
    _verificationFactorLegendColors = {
      1: Colors.blue,
      2: Colors.deepOrange,
    };
    this.crossCheckData = [];
    this.performanceReadinessData = [];
    this.consistancyOverTime = [];
    this.indicatorDiscrepencyData = [];
    this.verificationFactorsData = [];
    this._consistencyIndicatorName = '';
    _buildDropDown();
    _getConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectFormField(
              controller: _facilityController,
              type: SelectFormFieldType.dropdown,
              // or can be dialog
              icon: Icon(Icons.local_hospital),
              labelText: 'Facility',
              items: _dropItems,
              onChanged: (value) async {
                _getCrossCheckData(widget.selectedSupervision.id, int.parse(value));
                _getVerificationFactorsData(widget.selectedSupervision.id, int.parse(value));
                _getReasonForDiscrepenciesData(widget.selectedSupervision.id, int.parse(value));
                _getPerformanceReadinessData(widget.selectedSupervision.id, int.parse(value));
                _getConsistancyOverTimeData(widget.selectedSupervision.id, int.parse(value));
              },
            ),
          ],
        ),
        _facilityController.text != ''
            ? Flexible(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return GridView.count(
                      crossAxisCount: orientation == Orientation.portrait ? 1 : 3,
                      children: [
                        _createBarChart(this.crossCheckData, true, "Cross check 1, 2 & 3"), //Cross check
                        _createGroupedBarChart(this.verificationFactorsData, true, "Verification factors"), //Data accuracy
                        _createStackedChart(this.indicatorDiscrepencyData, true, "Reasons for discrepancy by indicator"),
                        this.indicatorDiscrepencyData.isNotEmpty ? _callLegendItems() : SizedBox.shrink(),
                        _createBarChart(this.performanceReadinessData, false, "Reporting performance & Readiness to provide quality data"),
                        _createLineChart(this.consistancyOverTime, "Consistency over time: $_consistencyIndicatorName"),
                      ],
                    );
                  },
                ),
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
                      Text('Please select a facility!'),
                    ],
                  ),
                ),
              )
      ],
    ));
  }

  _buildDropDown() {
    if (widget.selectedFacilities.isNotEmpty) {
      widget.selectedFacilities.asMap().forEach((index, value) {
        Map<String, dynamic> dropDownItemsMap = {'value': value.id.toString(), 'label': value.name};
        _dropItems.add(dropDownItemsMap);
      });
    }
  }

  Future<void> _getConfig() async {
    _selectedIndicators = await configManager.getDataRowsBySupervision('selectedindicator', widget.selectedSupervision.id);
    _discrepancies = await configManager.getSupervisionConfig('entrydiscrepancy');
    _periods = await configManager.getSupervisionConfig('period');
    _dataElements = await configManager.getSupervisionConfig('data_element');
    _indicators = await configManager.getSupervisionConfig('indicator');
    _sourceDocuments = await configManager.getSupervisionConfig('source_document');
    _supervisionPeriods = await configManager.getDataRowsBySupervision('supervisionperiod', widget.selectedSupervision.id);
  }

  Widget _createBarChart(List<Data> data, bool isVertical, String chartTitle) {
    List<charts.Series<Data, String>> seriesList = [
      new charts.Series<Data, String>(
        id: 'CrossChecks',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Data data, _) => data.name,
        measureFn: (Data data, _) => data.value,
        data: data,
      )
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                chartTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                  child: new charts.BarChart(
                seriesList,
                vertical: isVertical,
              )),
              SizedBox(
                height: 15,
              ),
              isVertical == true ? _buildAlegendForCrossCheck() : Container(), // Make sure it's cross check which is a vertical for now
            ],
          ),
        ),
      ),
    );
  }

  Widget _createGroupedBarChart(List<charts.Series<Data, String>> data, bool isVertical, String title) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: new charts.BarChart(
                  data,
                  vertical: isVertical,
                  barGroupingType: charts.BarGroupingType.grouped,
                )),
                SizedBox(
                  height: 15,
                ),
                _buildAlegendForVerificationFactor()
              ],
            )),
      ),
    );
  }

  Widget _createStackedChart(List<charts.Series<Data, String>> data, bool isVertical, String title) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: new charts.BarChart(
                    data,
                    vertical: isVertical,
                    barGroupingType: charts.BarGroupingType.stacked,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _createLineChart(List<SeriesData> data, String chartTitle) {
    List<charts.Series<SeriesData, int>> seriesList = [
      new charts.Series<SeriesData, int>(
        id: 'CrossChecks',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (SeriesData data, _) => data.period,
        measureFn: (SeriesData data, _) => data.value,
        data: data,
      )
    ];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                chartTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(child: new charts.LineChart(seriesList, defaultRenderer: new charts.LineRendererConfig(includePoints: true))),
              SizedBox(
                height: 15,
              ),
              _buildAlegendForMonth(),
            ],
          ),
        ),
      ),
    );
  }

  _getCrossCheckData(int supervisionId, int facilityId) {
    String primaryDataSourceName = '';
    String secondaryDataSourceName = '';
    configManager.getDataRowsByFacilityAndSupervision('entrycrosscheckab', supervisionId, facilityId).then((value) {
      if (value != null && value.isNotEmpty) {
        for (var i = 0; i < value.length; i++) {
          primaryDataSourceName =
              _getSourceDocumentById(value[i].primaryDataSourceId) != null ? _getSourceDocumentById(value[i].primaryDataSourceId).name : 'Null';
          secondaryDataSourceName =
              _getSourceDocumentById(value[i].secondaryDataSourceId) != null ? _getSourceDocumentById(value[i].secondaryDataSourceId).name : 'Null';
          if (value[i].type == 'a') {
            this.crossCheckData.add(new Data('Cross check 1', value[i].secondaryReliabilityRate));
            _crossCheck1 = '$primaryDataSourceName - $secondaryDataSourceName';
            setState(() {});
          } else if (value[i].type == 'b') {
            this.crossCheckData.add(new Data('Cross check 2', value[i].secondaryReliabilityRate));
            _crossCheck2 = '$primaryDataSourceName - $secondaryDataSourceName';
            setState(() {});
          }
        }
      }
    });

    configManager.getDataRowByFacilityAndSupervision('entrycrosscheckc', supervisionId, facilityId).then((value) {
      if (value != null && value.id != null) {
        primaryDataSourceName =
            _getSourceDocumentById(value.primaryDataSourceId) != null ? _getSourceDocumentById(value.primaryDataSourceId).name : 'Null';
        secondaryDataSourceName =
            _getSourceDocumentById(value.secondaryDataSourceId) != null ? _getSourceDocumentById(value.secondaryDataSourceId).name : 'Null';
        this.crossCheckData.add(new Data('Cross check 3', value.ratio));
        _crossCheck3 = '$primaryDataSourceName - $secondaryDataSourceName';
        setState(() {});
      }
    });
  }

  _getVerificationFactorsData(int supervisionId, int facilityId) {
    List<Data> data = [];
    List<Data> dataTwo = [];
    configManager.getDataRowsByFacilityAndSupervision('entrydataaccuracy', supervisionId, facilityId).then((value) {
      if (value != null && value.isNotEmpty) {
        String indicatorName = '';
        for (var i = 0; i < value.length; i++) {
          indicatorName = _getIndicatorById(value[i].indicatorId) != null ? _getIndicatorById(value[i].indicatorId).name : 'Null';
          if (value[i].type == 'entry1') {
            data.add(new Data(indicatorName, value[i].monthlyReportVfTotal));
            dataTwo.add(new Data(indicatorName, value[i].dhisVfTotal));
          } else if (value[i].type == 'entry2') {
            data.add(new Data(indicatorName, value[i].monthlyReportVfTotal));
            dataTwo.add(new Data(indicatorName, value[i].dhisVfTotal));
          } else if (value[i].type == 'entry3') {
            data.add(new Data(indicatorName, value[i].monthlyReportVfTotal));
            dataTwo.add(new Data(indicatorName, value[i].dhisVfTotal));
          }
        }
        setState(() {
          this.verificationFactorsData = [
            new charts.Series<Data, String>(
              id: 'data1',
              colorFn: (_, __) => _verificationFactorColors[1],
              domainFn: (Data data, _) => data.name,
              measureFn: (Data data, _) => data.value,
              data: data,
            ),
            new charts.Series<Data, String>(
              id: 'data2',
              colorFn: (_, __) => _verificationFactorColors[2],
              domainFn: (Data data, _) => data.name,
              measureFn: (Data data, _) => data.value,
              data: dataTwo,
            )
          ];
        });
      }
    });
  }

  _getReasonForDiscrepenciesData(int supervisionId, int facilityId) {
    List ids = [];
    List<Data> data1 = [];
    List<Data> data2 = [];
    List<Data> data3 = [];
    List<Data> data4 = [];
    List<Data> data5 = [];
    List<Data> data6 = [];
    List<Data> data7 = [];
    List<Data> data8 = [];
    List<Data> data9 = [];
    List<Data> data10 = [];

    for (int i = 0; i < _selectedIndicators.length; i++) {
      configManager
          .getDataRowsBySupervisionCountryAndId('entrydataaccuracydiscrepancy', supervisionId, facilityId, _selectedIndicators[i].indicatorId)
          .then((val) {
        if (val != null && val.isNotEmpty) {
          ids = _getDiscrepencyIds(val);
          String indicatorName =
              _getIndicatorById(_selectedIndicators[i].indicatorId) != null ? _getIndicatorById(_selectedIndicators[i].indicatorId).name : "Null";
          data1.add(new Data(indicatorName, ids.contains(1) ? 1 : 0));
          data2.add(new Data(indicatorName, ids.contains(2) ? 1 : 0));
          data3.add(new Data(indicatorName, ids.contains(3) ? 1 : 0));
          data4.add(new Data(indicatorName, ids.contains(4) ? 1 : 0));
          data5.add(new Data(indicatorName, ids.contains(5) ? 1 : 0));
          data6.add(new Data(indicatorName, ids.contains(6) ? 1 : 0));
          data7.add(new Data(indicatorName, ids.contains(7) ? 1 : 0));
          data8.add(new Data(indicatorName, ids.contains(8) ? 1 : 0));
          data9.add(new Data(indicatorName, ids.contains(9) ? 1 : 0));
          data10.add(new Data(indicatorName, ids.contains(10) ? 1 : 0));

          setState(() {
            this.indicatorDiscrepencyData = [
              new charts.Series<Data, String>(
                id: 'data1',
                colorFn: (_, __) => _discrepancyColors[1],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data1,
              ),
              new charts.Series<Data, String>(
                id: 'data2',
                colorFn: (_, __) => _discrepancyColors[2],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data2,
              ),
              new charts.Series<Data, String>(
                id: 'data3',
                colorFn: (_, __) => _discrepancyColors[3],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data3,
              ),
              new charts.Series<Data, String>(
                id: 'data4',
                colorFn: (_, __) => _discrepancyColors[4],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data4,
              ),
              new charts.Series<Data, String>(
                id: 'data5',
                colorFn: (_, __) => _discrepancyColors[5],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data5,
              ),
              new charts.Series<Data, String>(
                id: 'data6',
                colorFn: (_, __) => _discrepancyColors[6],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data6,
              ),
              new charts.Series<Data, String>(
                id: 'data7',
                colorFn: (_, __) => _discrepancyColors[7],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data7,
              ),
              new charts.Series<Data, String>(
                id: 'data8',
                colorFn: (_, __) => _discrepancyColors[8],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data8,
              ),
              new charts.Series<Data, String>(
                id: 'data9',
                colorFn: (_, __) => _discrepancyColors[9],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data9,
              ),
              new charts.Series<Data, String>(
                id: 'data10',
                colorFn: (_, __) => _discrepancyColors[10],
                domainFn: (Data data, _) => data.name,
                measureFn: (Data data, _) => data.value,
                data: data10,
              )
            ];
          });
        }
      });
    }
  }

  _getPerformanceReadinessData(int supervisionId, int facilityId) {
    // System assessment (% readiness)
    configManager.getDataRowByFacilityAndSupervision('entrysystemassessment', supervisionId, facilityId).then((val) {
      if (val != null) {
        setState(() {
          this.performanceReadinessData.add(new Data('System assessment (% readiness)', val.systemReadiness));
        });
      }
    });
    // Standard, Up-to-date and Available
    configManager.getDataRowsByFacilityAndSupervision('entrysourcedocumentcompleteness', supervisionId, facilityId).then((val) {
      if (val != null && val.isNotEmpty) {
        for (int i = 0; i < val.length; i++) {
          if (val[i].type == 'result') {
            setState(() {
              this.performanceReadinessData.add(new Data('Source documents standard issue', val[i].standardFormResult));
              this.performanceReadinessData.add(new Data('Source documents Up-to-date', val[i].upToDateResult));
              this.performanceReadinessData.add(new Data('Source documents available', val[i].availableResult));
            });
          }
        }
      }
    });
    // Timeliness
    configManager.getDataRowByFacilityAndSupervision('entrytimelinessmonthlyreport', supervisionId, facilityId).then((val) {
      if (val != null) {
        setState(() {
          this.performanceReadinessData.add(new Data('Timeliness of reporting', val.percent));
        });
      }
    });
    // % Cases with missing data
    configManager.getDataRowsByFacilityAndSupervision('entrydataelementcompleteness', supervisionId, facilityId).then((val) {
      if (val != null && val.isNotEmpty) {
        for (int i = 0; i < val.length; i++) {
          if (val[i].type == 'missing') {
            setState(() {
              this.performanceReadinessData.add(new Data('% Cases with missing data', val[i].percent));
            });
          }
        }
      }
    });
    // Completeness
    configManager.getDataRowByFacilityAndSupervision('entrycompletenessmonthlyreport', supervisionId, facilityId).then((val) {
      if (val != null) {
        setState(() {
          this.performanceReadinessData.add(new Data('Completeness of Monthly report', val.percent));
        });
      }
    });
  }

  _getConsistancyOverTimeData(int supervisionId, int facilityId) {
    this.consistancyOverTime = [];
    configManager.getDataRowByFacilityAndSupervision('entryconsistencyovertime', supervisionId, facilityId).then((val) {
      if (val != null && val.id != null) {
        setState(() {
          this._consistencyIndicatorName = _getIndicatorById(val.indicatorId).name;
          this.consistancyOverTime.add(new SeriesData(0, val.monthToMonthValue1.round()));
          this.consistancyOverTime.add(new SeriesData(1, val.monthToMonthValue2.round()));
          this.consistancyOverTime.add(new SeriesData(2, val.monthToMonthValue3.round()));
          this.consistancyOverTime.add(new SeriesData(3, val.monthToMonthValueLastMonth.round()));
        });
      }
    });
  }

  _getDiscrepencyIds(List<EntryDataAccuracyDiscrepancy> val) {
    List ids = [];
    for (int i = 0; i < val.length; i++) {
      ids.add(val[i].entryDiscrepancyId);
    }
    return ids;
  }

  Widget _buildAlegendForDiscrepancy(int index, String description) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: _legendColors[index],
          radius: 8,
        ),
        Flexible(child: Text(' $description')),
      ],
    );
  }

  Widget _buildAlegendForVerificationFactor() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _verificationFactorLegendColors[1],
              radius: 8,
            ),
            Flexible(child: Text(' VF Monthly report')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _verificationFactorLegendColors[2],
              radius: 8,
            ),
            Flexible(child: Text(' VF DHIS2')),
          ],
        ),
      ],
    );
  }

  Widget _buildAlegendForCrossCheck() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: RichText(
              text: new TextSpan(
                style: new TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  new TextSpan(text: 'Cross check 1: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                  new TextSpan(text: '$_crossCheck1'),
                ],
              ),
            ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: RichText(
              text: new TextSpan(
                style: new TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  new TextSpan(text: 'Cross check 2: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                  new TextSpan(text: '$_crossCheck2'),
                ],
              ),
            ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: RichText(
              text: new TextSpan(
                style: new TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  new TextSpan(text: 'Cross check 3: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                  new TextSpan(text: '$_crossCheck3'),
                ],
              ),
            ))
          ],
        ),
      ],
    );
  }

  Widget _buildAlegendForMonth() {
    String month1 = _getPeriodByNumber(widget.selectedSupervision.period.month - 3) != null
        ? _getPeriodByNumber(widget.selectedSupervision.period.month - 3).description
        : 'Null';
    String month2 = _getPeriodByNumber(widget.selectedSupervision.period.month - 2) != null
        ? _getPeriodByNumber(widget.selectedSupervision.period.month - 2).description
        : 'Null';
    String month3 = _getPeriodByNumber(widget.selectedSupervision.period.month - 1) != null
        ? _getPeriodByNumber(widget.selectedSupervision.period.month - 1).description
        : 'Null';
    String currentMonth = _getPeriodByNumber(widget.selectedSupervision.period.month) != null
        ? _getPeriodByNumber(widget.selectedSupervision.period.month).description
        : 'Null';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(flex: 1, child: Text('0 - ${month1.substring(0, 3)}', style: TextStyle(fontWeight: FontWeight.bold))),
        Flexible(flex: 1, child: Text('1 - ${month2.substring(0, 3)}', style: TextStyle(fontWeight: FontWeight.bold))),
        Flexible(flex: 1, child: Text('2 - ${month3.substring(0, 3)}', style: TextStyle(fontWeight: FontWeight.bold))),
        Flexible(flex: 1, child: Text('3 - ${currentMonth.substring(0, 3)}', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _callLegendItems() {
    List<Widget> rows = [];
    for (int i = 0; i < _discrepancies.length; i++) {
      rows.add(_buildAlegendForDiscrepancy(i + 1, _discrepancies[i].description));
    }
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              children: [
                Text(
                  'Legend',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Column(
              children: rows,
            ),
          ]),
        ));
  }

  Indicator _getIndicatorById(indicatorId) {
    Indicator indicator = new Indicator();
    indicator = _indicators.firstWhere((element) => element.id == indicatorId, orElse: () => null);

    return indicator;
  }

  SourceDocument _getSourceDocumentById(sourceDocumentId) {
    SourceDocument sourceDocument = new SourceDocument();
    sourceDocument = _sourceDocuments.firstWhere((element) => element.id == sourceDocumentId, orElse: () => null);

    return sourceDocument;
  }

  Periods _getPeriodByNumber(number) {
    Periods period = new Periods();
    if(number == 0)
      number = 12;
    else if (number == -1)
      number = 11;
    else if (number == -2)
      number = 10;
    period = _periods.firstWhere((element) => element.number == number, orElse: () => null);

    return period;
  }
}
