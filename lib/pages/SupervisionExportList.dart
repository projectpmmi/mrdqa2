import 'package:flutter/material.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/EntryCompletenessMonthlyReport.dart';
import 'package:mrdqa_tool/models/EntryConsistencyOverTime.dart';
import 'package:mrdqa_tool/models/EntryCrossCheckAb.dart';
import 'package:mrdqa_tool/models/EntryCrossCheckC.dart';
import 'package:mrdqa_tool/models/EntryDataAccuracy.dart';
import 'package:mrdqa_tool/models/EntryDataElementCompleteness.dart';
import 'package:mrdqa_tool/models/EntrySourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/EntrySystemAssessment.dart';
import 'package:mrdqa_tool/models/EntryTimelinessMonthlyReport.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/MetadataMapping.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import '../menus/MenuManager.dart';
import '../routes/Routes.dart';
import 'package:intl/intl.dart';
import 'package:mrdqa_tool/services/CsvManager.dart';
import 'package:mrdqa_tool/services/EmailManager.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/models/Visit.dart';
import 'package:mrdqa_tool/models/Config.dart';
import 'package:mrdqa_tool/services/MetadataMappingService.dart';
import 'package:mrdqa_tool/models/DataValue.dart';
import 'package:mrdqa_tool/models/Payload.dart';
import 'package:mrdqa_tool/services/DhisExport.dart';
import 'package:mrdqa_tool/models/EntryDataAccuracyDiscrepancy.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SupervisionExportList extends StatefulWidget {
  static const String routeName = '/supervisions_export_list';
  final ConfigManager configManager;

  SupervisionExportList(this.configManager);

  _SupervisionExportListState createState() => _SupervisionExportListState(this.configManager);
}

class _SupervisionExportListState extends State<SupervisionExportList> {
  final ConfigManager configManager;
  Routes routes;
  List<Supervision> _supervisions;
  List<Facility> _facilities;
  List<Facility> _supervisionFacilities;
  List<String> _header1 = null;
  List<String> _header2 = null;
  List<Indicator> _indicators;
  List<DataElement> _dataElements;
  List<SourceDocument> _sourceDocuments;
  List<Visit> _visits;
  Map<int, Visit> _visitMap;
  EntryCompletenessMonthlyReport _entryCompletenessMonthlyReport;
  EntryTimelinessMonthlyReport _entryTimelinessMonthlyReport;
  List<EntryDataElementCompleteness> _entryDataElementCompleteness;
  List<EntrySourceDocumentCompleteness> _entrySourceDocumentCompleteness;
  List<EntryDataAccuracy> _entryDataAccuracy;
  List<EntryDataAccuracyDiscrepancy> _discrepanciesList;
  List<dynamic> discrepanciesMonth1 = [];
  List<dynamic> discrepanciesMonth2 = [];
  List<dynamic> discrepanciesMonth3 = [];
  List<EntryCrossCheckAb> _entryCrossCheckAb;
  EntryCrossCheckC _entryCrossCheckC;
  EntryConsistencyOverTime _entryConsistencyOverTime;
  EntrySystemAssessment _entrySystemAssessment;
  String _programPeriodType;
  final MetadataMappingService _metadataMapping = new MetadataMappingService();
  DhisExport _dhisExport;
  FToast _configSaveToast;

  _SupervisionExportListState(this.configManager);

  @override
  void initState() {
    Future<Config> config = configManager.getConfig();
    config.then((data) {
      setState(() {
        print(data);
        print("Config data from export page");
        _programPeriodType = data.getProgramPeriodType();
        Map<String, String> configs = new Map();
        configs['baseUrl'] = data.getBaseUrl();
        configs['username'] = data.getUsername();
        configs['password'] = data.getPassword();
        _dhisExport = new DhisExport(configs);
      });
    });
    configManager.getSupervisionConfig('supervision').then((value) {
      if (value != null && value.length > 0) {
        setState(() => _supervisions = value);
        _getConfig();
        _buildFileHeader();
        _visitMap = {};
      } else {
        setState(() {
          _supervisions = null;
        });
      }
    });
    _configSaveToast = FToast();
    _configSaveToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervision data export'),
      ),
      drawer: Drawer(
        child: new MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: _supervisions != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200, childAspectRatio: 3 / 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
                  itemCount: _supervisions.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return InkWell(
                        onTap: () async {
                          await _setSupervisionConfig(_supervisions[index].id);
                          if (!_supervisions[index].usePackage) {
                            print("Supervision DHIS2!");
                            List<List<dynamic>> data = List<List<dynamic>>();
                            data.add(_header1);
                            data.add(_header2);
                            List<String> row = [];
                            for (int i = 0; i < _supervisionFacilities.length; i++) {
                              await _setFacilityData(_supervisions[index].id, _supervisionFacilities[i].id);
                              row = _buildFacilityData(_supervisions[index].id, _supervisionFacilities[i]);
                              data.add(row);
                            }
                            CsvManager csvMan = CsvManager();
                            csvMan.createCsv(data);
                            var pathe = csvMan.getFilePath();
                            pathe.then((data) {
                              EmailManager(configManager: this.configManager).sendEmail(_supervisions[index].description,
                                  'Hi! please find attached data export for supervision: ${_supervisions[index].description}', [], [data]);
                            });
                          } else {
                            print("Supervision package!");
                            bool packageMode = await _onChooseExportMode(context);
                            if (packageMode) {
                              print("Export to DHIS2");
                              List<MetadataMapping> idCodes = await configManager.getSupervisionConfig('metadata_mapping');
                              Map<String, String> mappedCodeId = _codeIdMapping(idCodes);
                              String period = _getSumissionPeriod(_supervisions[index].period, _programPeriodType);
                              final Map<String, String> verificationFactors = _metadataMapping.getKeyValueMap('verification_factors');
                              final Map<String, String> consistencyMonths = _metadataMapping.getKeyValueMap('consistency_months');
                              final Map<String, String> sourceDocumentStatus = _metadataMapping.getKeyValueMap('source_document_status');
                              final Map<String, String> sourceDocumentCompleteness = _metadataMapping.getKeyValueMap('source_document_completeness');
                              final Map<String, String> systemAssessment = _metadataMapping.getKeyValueMap('system_assessment');
                              final DateTime now = DateTime.now();
                              final DateFormat formatter = DateFormat('yyyy-MM-dd');
                              final String formatted = formatter.format(now);
                              String consistencyDataElement = "";
                              Map<int, int> discrepenciesMap;
                              EntryDataAccuracy entryDataAccuracy = new EntryDataAccuracy();
                              int available;
                              int upToDate;
                              int standard;

                              for (int i = 0; i < _supervisionFacilities.length; i++) {
                                await _setFacilityData(_supervisions[index].id, _supervisionFacilities[i].id);
                                // todo Check if the section is used and see if its data are present.
                                // todo in configuration pull just your facilities and fill data for them
                                if (_entryCompletenessMonthlyReport.id != null) {
                                  List<DataValue> dataValues = [];
                                  // Completeness of monthly report
                                  dataValues.add(DataValue(
                                      dataElement: mappedCodeId[_metadataMapping.getSingleRemoteId('completeness_monthly_report')],
                                      value: _entryCompletenessMonthlyReport.percent.toString()));
                                  // Timeliness of monthly report
                                  dataValues.add(DataValue(
                                      dataElement: mappedCodeId[_metadataMapping.getSingleRemoteId('timeliness_monthly_report')],
                                      value: _entryTimelinessMonthlyReport.percent.toString()));
                                  // Data element completeness
                                  for (int p = 0; p < _entryDataElementCompleteness.length; p++) {
                                    if (_entryDataElementCompleteness[p].type != "missing" && _entryDataElementCompleteness[p].type != "total") {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(
                                              _entryDataElementCompleteness[p].dataElementId, "data_element_completeness")],
                                          value: _entryDataElementCompleteness[p].percent.toString()));
                                    }
                                    if (_entryDataElementCompleteness[p].type == "missing") {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[_metadataMapping.getSingleRemoteId("data_element_completeness")],
                                          value: _entryDataElementCompleteness[p].percent.toString()));
                                    }
                                  }
                                  // Source documents completeness
                                  for (int g = 0; g < _entrySourceDocumentCompleteness.length; g++) {
                                    available = 0;
                                    upToDate = 0;
                                    standard = 0;
                                    if (_entrySourceDocumentCompleteness[g].type != "result") {
                                      if (_entrySourceDocumentCompleteness[g].available == 1) {
                                        available = 100;
                                      }
                                      if (_entrySourceDocumentCompleteness[g].upToDate == 1) {
                                        upToDate = 100;
                                      }
                                      if (_entrySourceDocumentCompleteness[g].standardForm == 1) {
                                        standard = 100;
                                      }
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(
                                              _entrySourceDocumentCompleteness[g].sourceDocumentId, "source_document_completeness")],
                                          categoryOpCombo: mappedCodeId[sourceDocumentStatus['available']],
                                          value: available.toString()));
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(
                                              _entrySourceDocumentCompleteness[g].sourceDocumentId, "source_document_completeness")],
                                          categoryOpCombo: mappedCodeId[sourceDocumentStatus['uptodate']],
                                          value: upToDate.toString()));
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(
                                              _entrySourceDocumentCompleteness[g].sourceDocumentId, "source_document_completeness")],
                                          categoryOpCombo: mappedCodeId[sourceDocumentStatus['standard']],
                                          value: standard.toString()));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[sourceDocumentCompleteness['standard']],
                                          value: _entrySourceDocumentCompleteness[g].standardFormResult.toString()));
                                      // Source documents Up-to-date
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[sourceDocumentCompleteness['uptodate']],
                                          value: _entrySourceDocumentCompleteness[g].upToDateResult.toString()));
                                      // Source documents available
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[sourceDocumentCompleteness['available']],
                                          value: _entrySourceDocumentCompleteness[g].availableResult.toString()));
                                    }
                                  }
                                  // Cross checks
                                  EntryCrossCheckAb crossCheckA = _getCrossCheckAbFromType('a');
                                  if (crossCheckA != null) {
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getCrossChecksRemote(
                                            'A', crossCheckA.primaryDataSourceId, crossCheckA.secondaryDataSourceId)],
                                        value: crossCheckA.secondaryReliabilityRate.toString()));
                                  }
                                  EntryCrossCheckAb crossCheckB = _getCrossCheckAbFromType('b');
                                  if (crossCheckB != null) {
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getCrossChecksRemote(
                                            'B', crossCheckB.primaryDataSourceId, crossCheckB.secondaryDataSourceId)],
                                        value: crossCheckB.secondaryReliabilityRate.toString()));
                                  }
                                  if (_entryCrossCheckC != null) {
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getCrossChecksRemote(
                                            'C', _entryCrossCheckC.primaryDataSourceId, _entryCrossCheckC.secondaryDataSourceId)],
                                        value: _entryCrossCheckC.ratio.toString()));
                                  }
                                  // Data accuracy (verification factors)
                                  if (_getDataAccuracyFromType('entry1') != null) {
                                    entryDataAccuracy = _getDataAccuracyFromType('entry1');
                                    discrepenciesMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0};
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['monthly_report']],
                                        value: entryDataAccuracy.monthlyReportVfTotal.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['hmis']],
                                        value: entryDataAccuracy.dhisVfTotal.toString()));
                                    _discrepanciesList = await configManager.getDataRowsBySupervisionCountryAndId('entrydataaccuracydiscrepancy',
                                        _supervisions[index].id, _supervisionFacilities[i].id, entryDataAccuracy.indicatorId);
                                    if (_discrepanciesList != null) {
                                      for (var k = 0; k < _discrepanciesList.length; k++) {
                                        discrepenciesMap[_discrepanciesList[k].entryDiscrepancyId] =
                                            discrepenciesMap[_discrepanciesList[k].entryDiscrepancyId] + 1;
                                      }
                                    }
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['no_discrepency']],
                                        value: discrepenciesMap[1].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['arithmetic_errors']],
                                        value: discrepenciesMap[2].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['transcription_errors']],
                                        value: discrepenciesMap[3].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['documents_were_missing']],
                                        value: discrepenciesMap[4].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['documents_are_missing']],
                                        value: discrepenciesMap[5].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['forms_not_up-to-date']],
                                        value: discrepenciesMap[6].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['commodity_forms_not_up-to-date']],
                                        value: discrepenciesMap[7].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_treatment_drugs']],
                                        value: discrepenciesMap[8].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_drugs']],
                                        value: discrepenciesMap[9].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_vaccine']],
                                        value: discrepenciesMap[10].toString()));
                                  }
                                  if (_getDataAccuracyFromType('entry2') != null) {
                                    entryDataAccuracy = _getDataAccuracyFromType('entry2');
                                    discrepenciesMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0};
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['monthly_report']],
                                        value: entryDataAccuracy.monthlyReportVfTotal.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['hmis']],
                                        value: entryDataAccuracy.dhisVfTotal.toString()));
                                    _discrepanciesList = await configManager.getDataRowsBySupervisionCountryAndId('entrydataaccuracydiscrepancy',
                                        _supervisions[index].id, _supervisionFacilities[i].id, entryDataAccuracy.indicatorId);
                                    if (_discrepanciesList != null) {
                                      for (var k = 0; k < _discrepanciesList.length; k++) {
                                        discrepenciesMap[_discrepanciesList[k].entryDiscrepancyId] =
                                            discrepenciesMap[_discrepanciesList[k].entryDiscrepancyId] + 1;
                                      }
                                    }
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['no_discrepency']],
                                        value: discrepenciesMap[1].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['arithmetic_errors']],
                                        value: discrepenciesMap[2].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['transcription_errors']],
                                        value: discrepenciesMap[3].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['documents_were_missing']],
                                        value: discrepenciesMap[4].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['documents_are_missing']],
                                        value: discrepenciesMap[5].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['forms_not_up-to-date']],
                                        value: discrepenciesMap[6].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['commodity_forms_not_up-to-date']],
                                        value: discrepenciesMap[7].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_treatment_drugs']],
                                        value: discrepenciesMap[8].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_drugs']],
                                        value: discrepenciesMap[9].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_vaccine']],
                                        value: discrepenciesMap[10].toString()));
                                  }
                                  if (_getDataAccuracyFromType('entry3') != null) {
                                    entryDataAccuracy = _getDataAccuracyFromType('entry3');
                                    discrepenciesMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0};
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['monthly_report']],
                                        value: entryDataAccuracy.monthlyReportVfTotal.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['hmis']],
                                        value: entryDataAccuracy.dhisVfTotal.toString()));
                                    _discrepanciesList = await configManager.getDataRowsBySupervisionCountryAndId('entrydataaccuracydiscrepancy',
                                        _supervisions[index].id, _supervisionFacilities[i].id, entryDataAccuracy.indicatorId);
                                    if (_discrepanciesList != null) {
                                      for (var k = 0; k < _discrepanciesList.length; k++) {
                                        discrepenciesMap[_discrepanciesList[k].entryDiscrepancyId] =
                                            discrepenciesMap[_discrepanciesList[k].entryDiscrepancyId] + 1;
                                      }
                                    }
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['no_discrepency']],
                                        value: discrepenciesMap[1].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['arithmetic_errors']],
                                        value: discrepenciesMap[2].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['transcription_errors']],
                                        value: discrepenciesMap[3].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['documents_were_missing']],
                                        value: discrepenciesMap[4].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['documents_are_missing']],
                                        value: discrepenciesMap[5].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['forms_not_up-to-date']],
                                        value: discrepenciesMap[6].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['commodity_forms_not_up-to-date']],
                                        value: discrepenciesMap[7].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_treatment_drugs']],
                                        value: discrepenciesMap[8].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_drugs']],
                                        value: discrepenciesMap[9].toString()));
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[_metadataMapping.getRemoteFromId(entryDataAccuracy.indicatorId, 'data_accuracy')],
                                        categoryOpCombo: mappedCodeId[verificationFactors['stock_out_vaccine']],
                                        value: discrepenciesMap[10].toString()));
                                  }
                                  // Consistency checks (Consistency months)
                                  if (_entryConsistencyOverTime != null) {
                                    consistencyDataElement =
                                        mappedCodeId[_metadataMapping.getRemoteFromId(_entryConsistencyOverTime.indicatorId, 'consistency_checks')];
                                    dataValues.add(DataValue(
                                        dataElement: consistencyDataElement,
                                        categoryOpCombo: mappedCodeId[consistencyMonths['month_1']],
                                        value: _entryConsistencyOverTime.monthToMonthValue1.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: consistencyDataElement,
                                        categoryOpCombo: mappedCodeId[consistencyMonths['month_2']],
                                        value: _entryConsistencyOverTime.monthToMonthValue2.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: consistencyDataElement,
                                        categoryOpCombo: mappedCodeId[consistencyMonths['month_3']],
                                        value: _entryConsistencyOverTime.monthToMonthValue3.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: consistencyDataElement,
                                        categoryOpCombo: mappedCodeId[consistencyMonths['last_month']],
                                        value: _entryConsistencyOverTime.monthToMonthValueLastMonth.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: consistencyDataElement,
                                        categoryOpCombo: mappedCodeId[consistencyMonths['annual_consistency_ratio']],
                                        value: _entryConsistencyOverTime.annualRatio.toString()));
                                    dataValues.add(DataValue(
                                        dataElement: consistencyDataElement,
                                        categoryOpCombo: mappedCodeId[consistencyMonths['month-to-month_consistency_ratio']],
                                        value: _entryConsistencyOverTime.monthToMonthRatio.toString()));
                                  }
                                  // System assessment (readiness)
                                  if (_entrySystemAssessment != null) {
                                    dataValues.add(DataValue(
                                        dataElement: mappedCodeId[systemAssessment['readiness']],
                                        value: _entrySystemAssessment.systemReadiness.toString()));
                                    if (_entrySystemAssessment.questionV1 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['enter_compile']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['enter_compile']], value: _entrySystemAssessment.questionV1));
                                    }
                                    if (_entrySystemAssessment.questionV2 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['review_quality']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['review_quality']], value: _entrySystemAssessment.questionV2));
                                    }
                                    if (_entrySystemAssessment.questionV3 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['guidelines']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['guidelines']], value: _entrySystemAssessment.questionV3));
                                    }
                                    if (_entrySystemAssessment.questionV4 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['blank_form']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['blank_form']], value: _entrySystemAssessment.questionV4));
                                    }
                                    if (_entrySystemAssessment.questionV5 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['stock_out_forms']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['stock_out_forms']], value: _entrySystemAssessment.questionV5));
                                    }
                                    if (_entrySystemAssessment.questionV6 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['standard_register']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['standard_register']],
                                          value: _entrySystemAssessment.questionV6));
                                    }
                                    if (_entrySystemAssessment.questionV7 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['history_easily_found']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['history_easily_found']],
                                          value: _entrySystemAssessment.questionV7));
                                    }
                                    if (_entrySystemAssessment.questionV8 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['archives_maintained']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['archives_maintained']],
                                          value: _entrySystemAssessment.questionV8));
                                    }
                                    if (_entrySystemAssessment.questionV9 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['demographic']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['demographic']], value: _entrySystemAssessment.questionV9));
                                    }
                                    if (_entrySystemAssessment.questionV10 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['target_to_monitor']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['target_to_monitor']],
                                          value: _entrySystemAssessment.questionV10));
                                    }
                                    if (_entrySystemAssessment.questionV11 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['display']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['display']], value: _entrySystemAssessment.questionV11));
                                    }
                                    if (_entrySystemAssessment.questionV12 == "1") {
                                      dataValues.add(DataValue(dataElement: mappedCodeId[systemAssessment['chart_of_disease']], value: "100"));
                                    } else {
                                      dataValues.add(DataValue(
                                          dataElement: mappedCodeId[systemAssessment['chart_of_disease']],
                                          value: _entrySystemAssessment.questionV12));
                                    }
                                  }
                                  Payload payload = Payload(
                                      dataset: mappedCodeId[_metadataMapping.getSingleRemoteId('data_set')],
                                      orgUnit: _supervisionFacilities[i].uid,
                                      period: period,
                                      attOpCombo: "",
                                      completedDate: formatted,
                                      dataValue: dataValues);
                                  var export = await _dhisExport.postRequest(payload, 'dataset');
                                  if (export.statusCode == 200) {
                                    _showToast("Successfully pushed for: ${_supervisionFacilities[i].name}", true);
                                  } else {
                                    _showToast("Fail to push for: ${_supervisionFacilities[i].name}", false);
                                  }
                                }
                              }
                            } else {
                              print("Export to csv");
                              List<List<dynamic>> data = List<List<dynamic>>();
                              data.add(_header1);
                              data.add(_header2);
                              List<String> row = [];
                              for (int i = 0; i < _supervisionFacilities.length; i++) {
                                await _setFacilityData(_supervisions[index].id, _supervisionFacilities[i].id);
                                row = _buildFacilityData(_supervisions[index].id, _supervisionFacilities[i]);
                                data.add(row);
                              }
                              CsvManager csvMan = CsvManager();
                              csvMan.createCsv(data);
                              var pathe = csvMan.getFilePath();
                              pathe.then((data) {
                                EmailManager(configManager: this.configManager).sendEmail(_supervisions[index].description,
                                    'Hi! please find attached data export for supervision: ${_supervisions[index].description}', [], [data]);
                              });
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: ListTile(
                            title: _supervisions[index].description != null ? Text(_supervisions[index].description) : Text('Empty'),
                            subtitle: _supervisions[index].period != null
                                ? Text(' ${DateFormat.yMMM('en_US').format(_supervisions[index].period)}')
                                : Text('Empty'),
                          ),
                          decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(15)),
                        ));
                  }),
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
                    Text('Empty, make sure that you have configured the supervision and finished the data entry'),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _buildFileHeader() async {
    _header1 = [
      "",
      "",
      "",
      "",
      "",
      "",
      "Data element completeness",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "Source Document Completeness",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "Data accuracy",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "Cross check",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "Consistency checks",
      "",
      "",
      ""
    ];
    _header2 = [
      "VisitID",
      "Facility Name",
      "Facility ID",
      "Visit date",
      "COMPLETENESS_CALC_1",
      "TIMELINESS_CALC_1",
      "Data element #1",
      "DATAELEMENT_CALC_1",
      "Data element #2",
      "DATAELEMENT_CALC_1",
      "Data element #3",
      "DATAELEMENT_CALC_1",
      "Data element #4",
      "DATAELEMENT_CALC_1",
      "Data element #5",
      "DATAELEMENT_CALC_1",
      "Data element #6",
      "DATAELEMENT_CALC_1",
      "DATAELEMENT_CALC_2",
      "Source document 1",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "Source document 2",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "Source document 3",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "Source document 4",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "Source document 5",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "Source document 6",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "Source document 7",
      "Available?",
      "Up-to-date?",
      "Standard form?",
      "SOURCEDOC_CALC_1",
      "SOURCEDOC_CALC_2",
      "SOURCEDOC_CALC_3",
      "Indicator 1",
      "ACCURACY_CALC_1",
      "ACCURACY_CALC_2",
      "Indicator 2",
      "ACCURACY_CALC_1",
      "ACCURACY_CALC_2",
      "Indicator 3",
      "ACCURACY_CALC_1",
      "ACCURACY_CALC_2",
      "Cross check 1  document 1",
      "Cross check 1 document 2",
      "CROSSCHECKA_CALC_1",
      "Cross check 2  document 1",
      "Cross check 2  document 2",
      "CROSSCHECKB_CALC_1",
      "Cross check 3  document 1",
      "Cross check 3  document 2",
      "CROSSCHECKC_CALC_1",
      "CoIndicator",
      "ANNUAL_CONSIST_CALC_1",
      "MONTH_CONSIST_CALC_1",
      "SYS_ASSESS_CALC_1"
    ];
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

  Future<void> _setSupervisionConfig(int supervisionId) async {
    configManager.getDataRowsBySupervision('supervisionfacilities', supervisionId).then((supervisionFacilities) {
      _supervisionFacilities = _getSelectedFacilities(_facilities, supervisionFacilities);
    });
    _visits = await configManager.getDataRowsBySupervision('visits', supervisionId);
    for (int i = 0; i < _visits.length; i++) {
      _visitMap[_visits[i].facilityId] = _visits[i];
    }
  }

  Future<void> _getConfig() async {
    _facilities = await configManager.getSupervisionConfig('facility');
    _indicators = await configManager.getSupervisionConfig('indicator');
    _dataElements = await configManager.getSupervisionConfig('data_element');
    _sourceDocuments = await configManager.getSupervisionConfig('source_document');
  }

  Future<void> _setFacilityData(int supervisionId, int facilityId) async {
    _entryCompletenessMonthlyReport = new EntryCompletenessMonthlyReport();
    _entryTimelinessMonthlyReport = new EntryTimelinessMonthlyReport();
    _entryDataElementCompleteness = [];
    _entrySourceDocumentCompleteness = [];
    _entryDataAccuracy = [];
    _entryCrossCheckAb = [];
    _entryCrossCheckC = EntryCrossCheckC();
    _entryConsistencyOverTime = EntryConsistencyOverTime();
    _entrySystemAssessment = EntrySystemAssessment();
    _entryCompletenessMonthlyReport =
        await configManager.getDataRowByFacilityAndSupervision('entrycompletenessmonthlyreport', supervisionId, facilityId);
    _entryTimelinessMonthlyReport = await configManager.getDataRowByFacilityAndSupervision('entrytimelinessmonthlyreport', supervisionId, facilityId);
    _entryDataElementCompleteness =
        await configManager.getDataRowsByFacilityAndSupervision('entrydataelementcompleteness', supervisionId, facilityId);
    _entrySourceDocumentCompleteness =
        await configManager.getDataRowsByFacilityAndSupervision('entrysourcedocumentcompleteness', supervisionId, facilityId);
    _entryDataAccuracy = await configManager.getDataRowsByFacilityAndSupervision('entrydataaccuracy', supervisionId, facilityId);
    _entryCrossCheckAb = await configManager.getDataRowsByFacilityAndSupervision('entrycrosscheckab', supervisionId, facilityId);
    _entryCrossCheckC = await configManager.getDataRowByFacilityAndSupervision('entrycrosscheckc', supervisionId, facilityId);
    _entryConsistencyOverTime = await configManager.getDataRowByFacilityAndSupervision('entryconsistencyovertime', supervisionId, facilityId);
    _entrySystemAssessment = await configManager.getDataRowByFacilityAndSupervision('entrysystemassessment', supervisionId, facilityId);
  }

  DataElement _getDataElementById(int id) {
    DataElement result = new DataElement();
    for (int i = 0; i < _dataElements.length; i++) {
      if (_dataElements[i].id == id) {
        return _dataElements[i];
      }
    }

    return result;
  }

  SourceDocument _getSourceDocumentById(int id) {
    SourceDocument result = new SourceDocument();
    for (int i = 0; i < _sourceDocuments.length; i++) {
      if (_sourceDocuments[i].id == id) {
        return _sourceDocuments[i];
      }
    }

    return result;
  }

  Indicator _getIndicatorById(int id) {
    Indicator result = new Indicator();
    for (int i = 0; i < _indicators.length; i++) {
      if (_indicators[i].id == id) {
        return _indicators[i];
      }
    }

    return result;
  }

  EntryDataElementCompleteness _getDataElementCompletenessFromType(String type) {
    EntryDataElementCompleteness result = new EntryDataElementCompleteness();
    for (int i = 0; i < _entryDataElementCompleteness.length; i++) {
      if (_entryDataElementCompleteness[i].type == type) {
        return _entryDataElementCompleteness[i];
      }
    }

    return result;
  }

  EntrySourceDocumentCompleteness _getSourceDocumentCompletenessFromType(String type) {
    EntrySourceDocumentCompleteness result = new EntrySourceDocumentCompleteness();
    for (int i = 0; i < _entrySourceDocumentCompleteness.length; i++) {
      if (_entrySourceDocumentCompleteness[i].type == type) {
        return _entrySourceDocumentCompleteness[i];
      }
    }

    return result;
  }

  EntryDataAccuracy _getDataAccuracyFromType(String type) {
    EntryDataAccuracy result = new EntryDataAccuracy();
    for (int i = 0; i < _entryDataAccuracy.length; i++) {
      if (_entryDataAccuracy[i].type == type) {
        return _entryDataAccuracy[i];
      }
    }

    return result;
  }

  EntryCrossCheckAb _getCrossCheckAbFromType(String type) {
    EntryCrossCheckAb result = new EntryCrossCheckAb();
    for (int i = 0; i < _entryCrossCheckAb.length; i++) {
      if (_entryCrossCheckAb[i].type == type) {
        return _entryCrossCheckAb[i];
      }
    }

    return result;
  }

  List<String> _buildFacilityData(int supervisionId, Facility facility) {
    List<String> result = [];
    result.add(_visitMap[facility.id].id.toString());
    result.add(facility.name);
    result.add(facility.uid);
    result.add(
        _visitMap[facility.id].date != null ? DateFormat.yMMMd('en_US').format(_visitMap[facility.id].date) : _visitMap[facility.id].date.toString());
    result.add(_entryCompletenessMonthlyReport.percent.toString());
    result.add(_entryTimelinessMonthlyReport.percent.toString());
    result.add(_getDataElementById(_getDataElementCompletenessFromType('entry1').dataElementId).name);
    result.add(_getDataElementCompletenessFromType('entry1').percent.toString());
    result.add(_getDataElementById(_getDataElementCompletenessFromType('entry2').dataElementId).name);
    result.add(_getDataElementCompletenessFromType('entry2').percent.toString());
    result.add(_getDataElementById(_getDataElementCompletenessFromType('entry3').dataElementId).name);
    result.add(_getDataElementCompletenessFromType('entry3').percent.toString());
    result.add(_getDataElementById(_getDataElementCompletenessFromType('entry4').dataElementId).name);
    result.add(_getDataElementCompletenessFromType('entry4').percent.toString());
    result.add(_getDataElementById(_getDataElementCompletenessFromType('entry5').dataElementId).name);
    result.add(_getDataElementCompletenessFromType('entry5').percent.toString());
    result.add(_getDataElementById(_getDataElementCompletenessFromType('entry6').dataElementId).name);
    result.add(_getDataElementCompletenessFromType('entry6').percent.toString());
    result.add(_getDataElementCompletenessFromType('missing').percent.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry1').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry1').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry1').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry1').standardForm.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry2').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry2').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry2').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry2').standardForm.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry3').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry3').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry3').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry3').standardForm.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry4').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry4').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry4').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry4').standardForm.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry5').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry5').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry5').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry5').standardForm.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry6').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry6').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry6').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry6').standardForm.toString());
    result.add(_getSourceDocumentById(_getSourceDocumentCompletenessFromType('entry7').sourceDocumentId).name);
    result.add(_getSourceDocumentCompletenessFromType('entry7').available.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry7').upToDate.toString());
    result.add(_getSourceDocumentCompletenessFromType('entry7').standardForm.toString());
    result.add(_getSourceDocumentCompletenessFromType('result').availableResult.toString());
    result.add(_getSourceDocumentCompletenessFromType('result').upToDateResult.toString());
    result.add(_getSourceDocumentCompletenessFromType('result').standardFormResult.toString());
    result.add(_getIndicatorById(_getDataAccuracyFromType('entry1').indicatorId).name);
    result.add(_getDataAccuracyFromType('entry1').monthlyReportVfTotal.toString());
    result.add(_getDataAccuracyFromType('entry1').dhisVfTotal.toString());
    result.add(_getIndicatorById(_getDataAccuracyFromType('entry2').indicatorId).name);
    result.add(_getDataAccuracyFromType('entry2').monthlyReportVfTotal.toString());
    result.add(_getDataAccuracyFromType('entry2').dhisVfTotal.toString());
    result.add(_getIndicatorById(_getDataAccuracyFromType('entry3').indicatorId).name);
    result.add(_getDataAccuracyFromType('entry3').monthlyReportVfTotal.toString());
    result.add(_getDataAccuracyFromType('entry3').dhisVfTotal.toString());
    result.add(_getSourceDocumentById(_getCrossCheckAbFromType('a').primaryDataSourceId).name);
    result.add(_getSourceDocumentById(_getCrossCheckAbFromType('a').secondaryDataSourceId).name);
    result.add(_getCrossCheckAbFromType('a').secondaryReliabilityRate.toString());
    result.add(_getSourceDocumentById(_getCrossCheckAbFromType('b').primaryDataSourceId).name);
    result.add(_getSourceDocumentById(_getCrossCheckAbFromType('b').secondaryDataSourceId).name);
    result.add(_getCrossCheckAbFromType('b').secondaryReliabilityRate.toString());
    result.add(_getSourceDocumentById(_entryCrossCheckC.primaryDataSourceId).name);
    result.add(_getSourceDocumentById(_entryCrossCheckC.secondaryDataSourceId).name);
    result.add(_entryCrossCheckC.ratio.toString());
    result.add(_getIndicatorById(_entryConsistencyOverTime.indicatorId).name);
    result.add(_entryConsistencyOverTime.annualRatio.toString());
    result.add(_entryConsistencyOverTime.monthToMonthRatio.toString());
    result.add(_entrySystemAssessment.systemReadiness.toString());

    return result;
  }

  Future<dynamic> _onChooseExportMode(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(title: Text('Export mode'), content: Text('Please choose the export mode'), actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('DHIS2 Package'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('CSV File'))
          ]);
        });
  }

  String _getSumissionPeriod(DateTime period, String type) {
    String submissionPeriod = "";
    final year = period.year;
    switch (type) {
      case 'Yearly':
        submissionPeriod = year.toString();
        break;

      case 'SixMonthly':
        int month = period.month;
        if (month < 7) {
          submissionPeriod = year.toString() + "S1";
        } else {
          submissionPeriod = year.toString() + "S2";
        }

        break;

      case 'Quarterly':
        int month = period.month;
        if (month < 4) {
          submissionPeriod = year.toString() + "Q1";
        } else if (month >= 4 && month < 7) {
          submissionPeriod = year.toString() + "Q2";
        } else if (month >= 7 && month < 10) {
          submissionPeriod = year.toString() + "Q3";
        } else if (month >= 10) {
          submissionPeriod = year.toString() + "Q4";
        }

        break;

      case 'Monthly':
        int month = period.month;
        if (month < 10) {
          submissionPeriod = year.toString() + "0" + month.toString();
        } else {
          submissionPeriod = year.toString() + month.toString();
        }

        break;
    }

    return submissionPeriod;
  }

  Map<String, String> _codeIdMapping(List<MetadataMapping> idCodesList) {
    Map<String, String> codeIdMap;

    for (int i = 0; i < idCodesList.length; i++) {
      if (codeIdMap != null) {
        codeIdMap[idCodesList[i].code] = idCodesList[i].uid;
      } else {
        codeIdMap = {idCodesList[i].code: idCodesList[i].uid};
      }
    }

    return codeIdMap;
  }

  //displays the save configuration toast
  _showToast(String message, bool success) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: success == true
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.greenAccent,
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.redAccent,
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
}
