import 'package:mrdqa_tool/Constants/IndicatorPageHelp.dart';
import 'package:mrdqa_tool/models/Config.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/EntryConsistencyOverTimeDiscrepancies.dart';
import 'package:mrdqa_tool/models/EntrySystemAssessment.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/MetadataMapping.dart';
import 'package:mrdqa_tool/models/Sections.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/models/SupervisionSection.dart';
import 'package:mrdqa_tool/services/CsvManager.dart';
import 'package:mrdqa_tool/services/SecurityManager.dart';
import 'package:uuid/uuid.dart';
import '../models/ConsistencyOverTime.dart';
import '../models/CrossCheck.dart';
import '../models/DataElementCompleteness.dart';
import '../models/EntryCompletenessMonthlyReport.dart';
import '../models/EntryConsistencyOverTime.dart';
import '../models/EntryCrossCheckAb.dart';
import '../models/EntryCrossCheckC.dart';
import '../models/EntryCrossCheckCDiscrepancies.dart';
import '../models/EntryDataAccuracy.dart';
import '../models/EntryDataAccuracyDiscrepancy.dart';
import '../models/EntryDataElementCompleteness.dart';
import '../models/EntryDiscrepancies.dart';
import '../models/EntryDqImprovementPlan.dart';
import '../models/EntrySourceDocumentCompleteness.dart';
import '../models/EntryTimelinessMonthlyReport.dart';
import '../models/Periods.dart';
import '../models/SelectedIndicator.dart';
import '../models/SourceDocumentCompleteness.dart';
import '../models/SupervisionFacilities.dart';
import '../models/SupervisionIndicators.dart';
import '../models/SupervisionPeriod.dart';
import '../models/Visit.dart';
import 'SqliteDatabaseManager.dart';
import 'package:mrdqa_tool/models/Visit.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';

/// Configuration Manager service handles saving and retrieval of configs from
/// SQLite.
class ConfigManager {
  final _sqliteDb = SqliteDatabaseManager.instance;
  Facility facility = new Facility();
  Indicator indicator = new Indicator();
  DataElement dataElement = new DataElement();
  Supervision supervision = new Supervision();
  final CsvManager _csvManager = new CsvManager();
  final SecurityManager _securityManager = new SecurityManager();
  Map<String, dynamic> _planningObject = {};

  Future<Config> getConfig() async {
    List<Map> configurations = await _sqliteDb.queryAllRows('configuration');
    Config config = new Config();
    List<Config> configs = [];
    //handles if no initial config exists in SQLite
    if (configurations.isEmpty) {
      print("DEFAULT CONFIG");
      configs.add(config);
      return configs.first;
    }

    for (var i = 0; i < configurations.length; i++) {
      config.setBaseUrl(configurations[i]["base_url"]);
      config.setUsername(configurations[i]["dhis_username"]);
      config.setPassword(configurations[i]["dhis_password"]);
      config.setLevel(configurations[i]['level']);
      config.setProgram(configurations[i]['program']);
      config.setProgramName(configurations[i]['program_name']);
      config.setProgramPeriodType(configurations[i]['program_period_type']);
      configs.add(config);
    }
    return configs.first;
  }

  Future<void> saveConfig(Config config) async {
    var data = {
      'base_url': config.getBaseUrl(),
      'dhis_username': config.getUsername(),
      'dhis_password': _securityManager.encrypt(config.getPassword()).base16,
      'level': config.getLevel(),
      'program': config.getProgram(),
      'program_name': config.getProgramName(),
      'program_period_type': config.getProgramPeriodType()
    };
    return _sqliteDb.insert('configuration', data);
  }

  Future<int> updateRowById(String configType, dynamic object) async {
    var data;
    var table;
    switch (configType) {
      case 'supervision':
        data = {
          'id': object.id,
          'description': object.description,
          'period': object.period.toString(),
          'usepackage': object.usePackage.toString(),
          'uid': object.uid
        };
        table = 'SUPERVISIONS';
        break;

      case 'visit':
        data = {
          'id': object.id,
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'date': object.date.toString(),
          'teamlead': object.teamLead,
        };
        table = 'VISITS';
        break;

      case 'entrycompletenessmonthlyreport':
        data = {
          'id': object.id,
          'expectedcells': object.expectedCells,
          'completedcells': object.completedCells,
          'percent': object.percent,
          'comment': object.comment
        };
        table = 'ENTRY_COMPLETENESS_MONTHLY_REPORT';
        break;

      case 'entrytimelinessmonthlyreport':
        data = {
          'id': object.id,
          'submittedmonth1': object.submittedMonth1,
          'submittedmonth2': object.submittedMonth2,
          'submittedmonth3': object.submittedMonth3,
          'percent': object.percent,
          'comment': object.comment
        };
        table = 'ENTRY_TIMELINESS_MONTHLY_REPORT';
        break;

      case 'entrydataelementcompleteness':
        data = {'id': object.id, 'missingcasesdata': object.missingCasesData, 'percent': object.percent, 'type': object.type};
        table = 'ENTRY_DATA_ELEMENT_COMPLETENESS';
        break;

      case 'entrysourcedocumentcompleteness':
        data = {
          'id': object.id,
          'availabe': object.available,
          'uptodate': object.upToDate,
          'standardform': object.standardForm,
          'availaberesult': object.availableResult,
          'uptodateresult': object.upToDateResult,
          'standardformresult': object.standardFormResult,
          'comment': object.comment,
          'type': object.type
        };
        table = 'ENTRY_SOURCE_DOCUMENT_COMPLETENESS';
        break;

      case 'entrydataaccuracy':
        data = {
          'id': object.id,
          'sourcedocumentrecount1': object.sourceDocumentRecount1,
          'sourcedocumentrecount2': object.sourceDocumentRecount2,
          'sourcedocumentrecount3': object.sourceDocumentRecount3,
          'sourcedocumentrecounttotal': object.sourceDocumentRecountTotal,
          'sourcedocumentrecountcomment': object.sourceDocumentRecountComment,
          'hmismonthlyreportvalue1': object.hmisMonthlyReportValue1,
          'hmismonthlyreportValue2': object.hmisMonthlyReportValue2,
          'hmismonthlyreportvalue3': object.hmisMonthlyReportValue3,
          'hmismonthlyreportvaluetotal': object.hmisMonthlyReportValueTotal,
          'hmismonthlyreportvaluecomment': object.hmisMonthlyReportValueComment,
          'dhismonthlyvalue1': object.dhisMonthlyValue1,
          'dhismonthlyvalue2': object.dhisMonthlyValue2,
          'dhismonthlyvalue3': object.dhisMonthlyValue3,
          'dhismonthlyvaluetotal': object.dhisMonthlyValueTotal,
          'dhismonthlyvaluecomment': object.dhisMonthlyValueComment,
          'monthlyreportvf1': object.monthlyReportVf1,
          'monthlyreportvf2': object.monthlyReportVf2,
          'monthlyreportvf3': object.monthlyReportVf2,
          'monthlyreportvftotal': object.monthlyReportVfTotal,
          'monthlyreportvfcomment': object.monthlyReportVfComment,
          'dhisvf1': object.dhisVf1,
          'dhisvf2': object.dhisVf2,
          'dhisvf3': object.dhisVf3,
          'dhisvftotal': object.dhisVfTotal,
          'dhisvfcomment': object.dhisVfTotal,
          'reasonfordiscrepancycomment': object.dhisVfComment,
          'otherreasonfordiscrepancy1': object.otherReasonForDiscrepancy1,
          'otherreasonfordiscrepancy2': object.otherReasonForDiscrepancy2,
          'otherreasonfordiscrepancy3': object.otherReasonForDiscrepancy3,
          'otherreasonfordiscrepancycomment': object.otherReasonForDiscrepancyComment,
          'type': object.type
        };
        table = 'ENTRY_DATA_ACCURACY';
        break;

      case 'entrycrosscheckab':
        data = {
          'id': object.id,
          'casessimpledfromprimary': object.casesSimpledFromPrimary,
          'primarycomment': object.primaryComment,
          'correspondingmachinginsecondary': object.correspondingMachingInSecondary,
          'secondarycomment': object.secondaryComment,
          'secondaryreliabilityrate': object.secondaryReliabilityRate,
          'reliabilitycomment': object.reliabilityComment,
          'type': object.type,
        };
        table = 'ENTRY_CROSS_CHECK_AB';
        break;

      case 'entrycrosscheckc':
        data = {
          'id': object.id,
          'initialstock': object.initialStock,
          'initialstockcomment': object.initialStockComment,
          'receivedstock': object.receivedStock,
          'receivedstockcomment': object.receivedStockComment,
          'closingstock': object.closingStock,
          'closingstockcomment': object.closingStockComment,
          'usedstock': object.usedStock,
          'usedstockcomment': object.usedStockComment,
          'ratio': object.ratio,
          'ratiocomment': object.ratioComment,
          'reasonfordiscrepancycomment': object.reasonForDiscrepancyComment,
          'otherreasonfordiscrepancy': object.otherReasonForDiscrepancy,
          'otherreasonfordiscrepancycomment': object.otherReasonForDiscrepancyComment,
        };
        table = 'ENTRY_CROSS_CHECK_C';
        break;

      case 'entryconsistencyovertime':
        data = {
          'id': object.id,
          'currentmonthValue': object.currentMonthValue,
          'currentmonthvaluecomment': object.currentMonthValueComment,
          'currentmonthyearagovalue': object.currentMonthYearAgoValue,
          'currentmonthyearagovaluecomment': object.currentMonthYearAgoValueComment,
          'annualratio': object.annualRatio,
          'annualratiocomment': object.annualRatioComment,
          'monthtomonthvalue1': object.monthToMonthValue1,
          'monthtomonthvalue2': object.monthToMonthValue2,
          'monthtomonthvalue3': object.monthToMonthValue3,
          'monthtomonthvaluelastmonth': object.monthToMonthValueLastMonth,
          'monthtomonthratio': object.monthToMonthRatio,
          'monthtomonthratiocomment': object.monthToMonthRatioComment,
          'reasonfordiscrepancycomment': object.reasonForDiscrepancyComment,
          'otherreasonfordiscrepancy': object.otherReasonForDiscrepancy,
          'otherreasonfordiscrepancycomment': object.otherReasonForDiscrepancyComment,
        };
        table = 'ENTRY_CONSISTENCY_OVER_TIME';
        break;

      case 'entrysystemassessment':
        data = {
          'id': object.id,
          'questionv1': object.questionV1,
          'questionv1comment': object.questionV1Comment,
          'questionv2': object.questionV2,
          'questionv2comment': object.questionV2Comment,
          'questionv3': object.questionV3,
          'questionv3comment': object.questionV3Comment,
          'questionv4': object.questionV4,
          'questionv4comment': object.questionV4Comment,
          'questionv5': object.questionV5,
          'questionv5comment': object.questionV5Comment,
          'questionv6': object.questionV6,
          'questionv6comment': object.questionV6Comment,
          'questionv7': object.questionV7,
          'questionv7comment': object.questionV7Comment,
          'questionv8': object.questionV8,
          'questionv8comment': object.questionV8Comment,
          'questionv9': object.questionV9,
          'questionv9comment': object.questionV9Comment,
          'questionv10': object.questionV10,
          'questionv10comment': object.questionV10Comment,
          'questionv11': object.questionV11,
          'questionv11comment': object.questionV11Comment,
          'questionv12': object.questionV12,
          'questionv12comment': object.questionV12Comment,
          'systemreadiness': object.systemReadiness,
        };
        table = 'ENTRY_SYSTEM_ASSESSMENT';
        break;

      case 'entrydataqualityimprovement':
        data = {
          'id': object.id,
          'weaknesses': object.weaknesses,
          'actionpointdescription': object.actionPointDescription,
          'responsibles': object.responsibles,
          'timeline': object.timeLine.toString(),
          'comment': object.comment,
          'type': object.type,
        };
        table = 'ENTRY_DQ_IMPROVEMENT';
        break;
    }

    return _sqliteDb.update(table, data);
  }

  Future<void> clearConfigs() {
    return _sqliteDb.clearTable('configuration');
  }

  Future<void> clearTable(String table) {
    return _sqliteDb.clearTable(table);
  }

  Future<int> saveSupervisionConfig(String uid, String name, String isDhis, String configType) async {
    var data;
    var table;
    switch (configType) {
      case 'facility':
        data = {'uid': uid, 'name': name, 'is_dhis_facility': isDhis};
        table = 'FACILITIES';
        break;

      case 'indicator':
        data = {'uid': uid, 'name': name, 'is_dhis_data_element': isDhis};
        table = 'INDICATORS';
        break;

      case 'data_element':
        data = {'uid': uid, 'name': name, 'is_dhis_data_element': isDhis};
        //table = 'DATA_ELEMENTS';
        table = 'INDICATORS';
        break;
    }
    return _sqliteDb.insert(table, data);
  }

  Future<int> saveRowData(String configType, dynamic object) async {
    var data;
    var table;
    switch (configType) {
      case 'supervisionfacility':
        data = {'supervisionid': object.supervisionId, 'facilityid': object.facilityId};
        table = 'SUPERVISION_FACILITIES';
        break;

      case 'supervision':
        data = {'description': object.description, 'period': object.period.toString(), 'usepackage': object.usePackage.toString(), 'uid': object.uid};
        table = 'SUPERVISIONS';
        break;

      case 'data_element':
        data = {'name': object.name, 'uid': object.uid, 'type_de': 0};
        table = 'DATA_ELEMENTS';
        break;

      case 'facility':
        data = {'uid': object.uid, 'name': object.name, 'is_dhis_facility': object.isDhisFacility.toString()};
        table = 'FACILITIES';
        break;

      case 'source_document':
        data = {'name': object.name, 'uid': object.uid};
        table = 'SOURCE_DOCUMENT';
        break;

      case 'selectedindicator':
        data = {'indicatorid': object.indicatorId, 'number': object.number, 'supervisionid': object.supervisionId};
        table = 'SELECTED_INDICATORS';
        break;

      case 'crosscheck':
        data = {
          'primarydatasourceid': object.primaryDataSourceId,
          'secondarydatasourceid': object.secondaryDataSourceId,
          'type': object.type,
          'supervisionid': object.supervisionId
        };
        table = 'CROSS_CHECK';
        break;

      case 'consistencyovertime':
        data = {'indicatorid': object.indicatorId, 'supervisionid': object.supervisionId};
        table = 'CONSISTENCY_OVER_TIME';
        break;

      case 'dataelementcompleteness':
        data = {'dataelementid': object.dataElementId, 'number': object.number, 'supervisionid': object.supervisionId};
        table = 'DATA_ELEMENT_COMPLETENESS';
        break;

      case 'sourcedocumentcompleteness':
        data = {'sourcedocumentid': object.sourceDocumentId, 'number': object.number, 'supervisionid': object.supervisionId};
        table = 'SOURCE_DOCUMENT_COMPLETENESS';
        break;

      case 'supervisionperiod':
        data = {'supervisionid': object.supervisionId, 'periodnumber': object.periodNumber};
        table = 'SUPERVISION_PERIODS';
        break;

      case 'supervisionsection':
        data = {'supervisionid': object.supervisionId, 'sectionnumber': object.sectionNumber};
        table = 'SUPERVISION_SECTIONS';
        break;

      case 'visit':
        data = {'supervisionid': object.supervisionId, 'facilityid': object.facilityId, 'date': object.date.toString(), 'teamlead': object.teamLead};
        table = 'VISITS';
        break;

      case 'entrycompletenessmonthlyreport':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'expectedcells': object.expectedCells,
          'completedcells': object.completedCells,
          'percent': object.percent,
          'comment': object.comment
        };
        table = 'ENTRY_COMPLETENESS_MONTHLY_REPORT';
        break;

      case 'entrytimelinessmonthlyreport':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'submittedmonth1': object.submittedMonth1,
          'submittedmonth2': object.submittedMonth2,
          'submittedmonth3': object.submittedMonth3,
          'percent': object.percent,
          'comment': object.comment
        };
        table = 'ENTRY_TIMELINESS_MONTHLY_REPORT';
        break;

      case 'entrydataelementcompleteness':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'dataelementid': object.dataElementId,
          'missingcasesdata': object.missingCasesData,
          'percent': object.percent,
          'type': object.type
        };
        table = 'ENTRY_DATA_ELEMENT_COMPLETENESS';
        break;

      case 'entrysourcedocumentcompleteness':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'sourcedocumentid': object.sourceDocumentId,
          'availabe': object.available,
          'uptodate': object.upToDate,
          'standardform': object.standardForm,
          'availaberesult': object.availableResult,
          'uptodateresult': object.upToDateResult,
          'standardformresult': object.standardFormResult,
          'comment': object.comment,
          'type': object.type
        };
        table = 'ENTRY_SOURCE_DOCUMENT_COMPLETENESS';
        break;

      case 'entrydataaccuracy':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'indicatorid': object.indicatorId,
          'sourcedocumentrecount1': object.sourceDocumentRecount1,
          'sourcedocumentrecount2': object.sourceDocumentRecount2,
          'sourcedocumentrecount3': object.sourceDocumentRecount3,
          'sourcedocumentrecounttotal': object.sourceDocumentRecountTotal,
          'sourcedocumentrecountcomment': object.sourceDocumentRecountComment,
          'hmismonthlyreportvalue1': object.hmisMonthlyReportValue1,
          'hmismonthlyreportValue2': object.hmisMonthlyReportValue2,
          'hmismonthlyreportvalue3': object.hmisMonthlyReportValue3,
          'hmismonthlyreportvaluetotal': object.hmisMonthlyReportValueTotal,
          'hmismonthlyreportvaluecomment': object.hmisMonthlyReportValueComment,
          'dhismonthlyvalue1': object.dhisMonthlyValue1,
          'dhismonthlyvalue2': object.dhisMonthlyValue2,
          'dhismonthlyvalue3': object.dhisMonthlyValue3,
          'dhismonthlyvaluetotal': object.dhisMonthlyValueTotal,
          'dhismonthlyvaluecomment': object.dhisMonthlyValueComment,
          'monthlyreportvf1': object.monthlyReportVf1,
          'monthlyreportvf2': object.monthlyReportVf2,
          'monthlyreportvf3': object.monthlyReportVf2,
          'monthlyreportvftotal': object.monthlyReportVfTotal,
          'monthlyreportvfcomment': object.monthlyReportVfComment,
          'dhisvf1': object.dhisVf1,
          'dhisvf2': object.dhisVf2,
          'dhisvf3': object.dhisVf3,
          'dhisvftotal': object.dhisVfTotal,
          'dhisvfcomment': object.dhisVfTotal,
          'reasonfordiscrepancycomment': object.dhisVfComment,
          'otherreasonfordiscrepancy1': object.otherReasonForDiscrepancy1,
          'otherreasonfordiscrepancy2': object.otherReasonForDiscrepancy2,
          'otherreasonfordiscrepancy3': object.otherReasonForDiscrepancy3,
          'otherreasonfordiscrepancycomment': object.otherReasonForDiscrepancyComment,
          'type': object.type
        };
        table = 'ENTRY_DATA_ACCURACY';
        break;

      case 'entrydataaccuracydiscrepancy':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'indicatorid': object.indicatorId,
          'entrydiscrepancyid': object.entryDiscrepancyId,
          'month': object.month
        };
        table = 'ENTRY_DATA_ACCURACY_DISCREPANCIES';
        break;

      case 'entrycrosscheckab':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'primarydatasourceid': object.primaryDataSourceId,
          'secondarydatasourceid': object.secondaryDataSourceId,
          'casessimpledfromprimary': object.casesSimpledFromPrimary,
          'primarycomment': object.primaryComment,
          'correspondingmachinginsecondary': object.correspondingMachingInSecondary,
          'secondarycomment': object.secondaryComment,
          'secondaryreliabilityrate': object.secondaryReliabilityRate,
          'reliabilitycomment': object.reliabilityComment,
          'type': object.type,
        };
        table = 'ENTRY_CROSS_CHECK_AB';
        break;

      case 'entrycrosscheckc':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'primarydatasourceid': object.primaryDataSourceId,
          'secondarydatasourceid': object.secondaryDataSourceId,
          'initialstock': object.initialStock,
          'initialstockcomment': object.initialStockComment,
          'receivedstock': object.receivedStock,
          'receivedstockcomment': object.receivedStockComment,
          'closingstock': object.closingStock,
          'closingstockcomment': object.closingStockComment,
          'usedstock': object.usedStock,
          'usedstockcomment': object.usedStockComment,
          'ratio': object.ratio,
          'ratiocomment': object.ratioComment,
          'reasonfordiscrepancycomment': object.reasonForDiscrepancyComment,
          'otherreasonfordiscrepancy': object.otherReasonForDiscrepancy,
          'otherreasonfordiscrepancycomment': object.otherReasonForDiscrepancyComment,
        };
        table = 'ENTRY_CROSS_CHECK_C';
        break;

      case 'entrycrosscheckcdiscrepancy':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'primarydatasourceid': object.primaryDataSourceId,
          'secondarydatasourceid': object.secondaryDataSourceId,
          'entrydiscrepanciesid': object.entryDiscrepanciesId,
        };
        table = 'ENTRY_CROSS_CHECK_C_DISCREPANCIES';
        break;

      case 'entryconsistencyovertime':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'indicatorid': object.indicatorId,
          'currentmonthValue': object.currentMonthValue,
          'currentmonthvaluecomment': object.currentMonthValueComment,
          'currentmonthyearagovalue': object.currentMonthYearAgoValue,
          'currentmonthyearagovaluecomment': object.currentMonthYearAgoValueComment,
          'annualratio': object.annualRatio,
          'annualratiocomment': object.annualRatioComment,
          'monthtomonthvalue1': object.monthToMonthValue1,
          'monthtomonthvalue2': object.monthToMonthValue2,
          'monthtomonthvalue3': object.monthToMonthValue3,
          'monthtomonthvaluelastmonth': object.monthToMonthValueLastMonth,
          'monthtomonthratio': object.monthToMonthRatio,
          'monthtomonthratiocomment': object.monthToMonthRatioComment,
          'reasonfordiscrepancycomment': object.reasonForDiscrepancyComment,
          'otherreasonfordiscrepancy': object.otherReasonForDiscrepancy,
          'otherreasonfordiscrepancycomment': object.otherReasonForDiscrepancyComment,
        };
        table = 'ENTRY_CONSISTENCY_OVER_TIME';
        break;

      case 'entryconsistencyovertimediscrepancy':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'entrydiscrepanciesid': object.entryDiscrepanciesId,
        };
        table = 'ENTRY_CONSISTENCY_OVER_TIME_DISCREPANCIES';
        break;

      case 'entrysystemassessment':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'questionv1': object.questionV1,
          'questionv1comment': object.questionV1Comment,
          'questionv2': object.questionV2,
          'questionv2comment': object.questionV2Comment,
          'questionv3': object.questionV3,
          'questionv3comment': object.questionV3Comment,
          'questionv4': object.questionV4,
          'questionv4comment': object.questionV4Comment,
          'questionv5': object.questionV5,
          'questionv5comment': object.questionV5Comment,
          'questionv6': object.questionV6,
          'questionv6comment': object.questionV6Comment,
          'questionv7': object.questionV7,
          'questionv7comment': object.questionV7Comment,
          'questionv8': object.questionV8,
          'questionv8comment': object.questionV8Comment,
          'questionv9': object.questionV9,
          'questionv9comment': object.questionV9Comment,
          'questionv10': object.questionV10,
          'questionv10comment': object.questionV10Comment,
          'questionv11': object.questionV11,
          'questionv11comment': object.questionV11Comment,
          'questionv12': object.questionV12,
          'questionv12comment': object.questionV12Comment,
          'systemreadiness': object.systemReadiness,
        };
        table = 'ENTRY_SYSTEM_ASSESSMENT';
        break;

      case 'entrydataqualityimprovement':
        data = {
          'supervisionid': object.supervisionId,
          'facilityid': object.facilityId,
          'weaknesses': object.weaknesses,
          'actionpointdescription': object.actionPointDescription,
          'responsibles': object.responsibles,
          'timeline': object.timeLine.toString(),
          'comment': object.comment,
          'type': object.type,
        };
        table = 'ENTRY_DQ_IMPROVEMENT';
        break;

      case 'supervision_planning':
        data = {'name': object.description, 'period': object.period.toString(), 'sup_uid': object.uid};
        table = 'PLANNING';
        break;
    }
    return _sqliteDb.insert(table, data);
  }

  Future<void> clearRowOfSupervisionFacility(String configType, int supervisionId, int facilityId) async {
    var table;
    switch (configType) {
      case 'supervisionfacility':
        table = 'SUPERVISION_FACILITIES';
        break;

      case 'visit':
        table = 'VISITS';
        break;

      case 'entrydataaccuracydiscrepancy':
        table = 'ENTRY_DATA_ACCURACY_DISCREPANCIES';
        break;

      case 'entrycrosscheckcdiscrepancy':
        table = 'ENTRY_CROSS_CHECK_C_DISCREPANCIES';
        break;

      case 'entryconsistencyovertimediscrepancy':
        table = 'ENTRY_CONSISTENCY_OVER_TIME_DISCREPANCIES';
        break;
    }
    return _sqliteDb.clearRowOfSupervisionFacility(table, supervisionId, facilityId);
  }

  Future<void> clearSupervisionConfig(String uid, String configType) async {
    var table;
    switch (configType) {
      case 'facility':
        table = 'facilities';
        break;

      case 'indicator':
        table = 'indicators';
        break;

      case 'data_element':
        table = 'data_elements';
        break;

      case 'source_document':
        table = 'SOURCE_DOCUMENT';
        break;
    }
    return _sqliteDb.clearConfig(table, uid);
  }

  Future<void> clearRowsOfSupervision(String configType, int supervisionId) async {
    var table;
    switch (configType) {
      case 'consistencyovertime':
        table = 'CONSISTENCY_OVER_TIME';
        break;

      case 'supervisionperiod':
        table = 'SUPERVISION_PERIODS';
        break;

      case 'supervisionsection':
        table = 'SUPERVISION_SECTIONS';
        break;
    }
    return _sqliteDb.clearRowsOfSupervision(table, supervisionId);
  }

  Future<List> getSupervisionConfig(String configType) async {
    var table;
    List<Map> configurations;
    List<dynamic> results;

    switch (configType) {
      case 'facility':
        List<Facility> facilityConfig = new List<Facility>();
        table = 'FACILITIES';
        configurations = await _sqliteDb.queryAllRows(table);

        for (int i = 0; i < configurations.length; i++) {
          bool isDhis;
          if (configurations[i]['is_dhis_facility'] == 'false') {
            isDhis = false;
          } else {
            isDhis = true;
          }
          facilityConfig.add(new Facility(
              id: configurations[i]['id'],
              uid: configurations[i]['uid'],
              name: configurations[i]['name'],
              isSupervisable: true,
              isDhisFacility: isDhis));
        }

        return facilityConfig;

      case 'indicator':
        List<Indicator> indicatorConfig = [];
        table = 'INDICATORS';
        bool isDhisIndicator = false;
        configurations = await _sqliteDb.queryAllRows(table);
        for (int i = 0; i < configurations.length; i++) {
          isDhisIndicator = true;
          if (configurations[i]['is_dhis_data_element'] != null) {
            if (configurations[i]['is_dhis_data_element'].toLowerCase() == 'true') {
              isDhisIndicator = true;
            } else {
              isDhisIndicator = false;
            }
          }
          var indicatorName = "";
          if (configurations[i]['cat_opt_combo_name'] != null) {
            indicatorName = "${configurations[i]['name']} ${configurations[i]['cat_opt_combo_name']}";
          } else {
            indicatorName = "${configurations[i]['name']}";
          }
          indicatorConfig.add(new Indicator(
              id: configurations[i]['id'],
              uid: configurations[i]['uid'],
              name: indicatorName,
              isSupervisable: true,
              isDhisDataElement: isDhisIndicator));
        }
        return indicatorConfig;

      case 'data_element':
        List<DataElement> dataElementConfig = [];
        table = 'DATA_ELEMENTS';
        bool isDhisDataElement = false;
        configurations = await _sqliteDb.queryAllRows(table);
        for (int i = 0; i < configurations.length; i++) {
          isDhisDataElement = true;
          if (configurations[i]['is_dhis_data_element'] != null) {
            if (configurations[i]['is_dhis_data_element'].toLowerCase() == 'true') {
              isDhisDataElement = true;
            } else {
              isDhisDataElement = false;
            }
          }
          dataElementConfig.add(new DataElement(
              id: configurations[i]['id'],
              uid: configurations[i]['uid'],
              name: configurations[i]['name'],
              isSupervisable: true,
              isDhisDataElement: isDhisDataElement));
        }
        return dataElementConfig;

      case 'source_document':
        List<SourceDocument> sourceDocument = [];
        table = 'SOURCE_DOCUMENT';
        configurations = await _sqliteDb.queryAllRows(table);
        for (int i = 0; i < configurations.length; i++) {
          sourceDocument.add(
              new SourceDocument(id: configurations[i]['id'], uid: configurations[i]['uid'], name: configurations[i]['name'], isSupervisable: true));
        }
        return sourceDocument;

      case 'supervision':
        List<Supervision> supervisionConfig = [];
        table = 'SUPERVISIONS';
        configurations = await _sqliteDb.queryAllRows(table);
        bool usepackage = false;
        for (int i = 0; i < configurations.length; i++) {
          if (configurations[i]['usepackage'].toLowerCase() == 'true') {
            usepackage = true;
          } else {
            usepackage = false;
          }
          supervisionConfig.add(new Supervision(
              id: configurations[i]['id'],
              description: configurations[i]['description'],
              usePackage: usepackage,
              period: DateTime.parse(configurations[i]['period']),
              uid: configurations[i]['uid']));
        }
        return supervisionConfig;

      case 'period':
        List<Periods> periodConfig = [];
        table = 'PERIODS';
        configurations = await _sqliteDb.queryAllRows(table);

        for (int i = 0; i < configurations.length; i++) {
          periodConfig
              .add(new Periods(id: configurations[i]['id'], number: configurations[i]['number'], description: configurations[i]['description']));
        }
        return periodConfig;

      case 'entrydiscrepancy':
        List<EntryDiscrepancies> entryDiscrepanciesConfig = [];
        table = 'ENTRY_DISCREPANCIES';
        configurations = await _sqliteDb.queryAllRows(table);

        for (int i = 0; i < configurations.length; i++) {
          entryDiscrepanciesConfig.add(new EntryDiscrepancies(id: configurations[i]['id'], description: configurations[i]['description']));
        }
        return entryDiscrepanciesConfig;

      case 'section':
        List<Sections> sectionConfig = [];
        table = 'SECTIONS';
        configurations = await _sqliteDb.queryAllRows(table);

        for (int i = 0; i < configurations.length; i++) {
          sectionConfig
              .add(new Sections(id: configurations[i]['id'], number: configurations[i]['number'], description: configurations[i]['descriptionn']));
        }
        return sectionConfig;

      case 'supervision_planning':
        List<Supervision> supervisionPlanning = [];
        table = 'PLANNING';
        configurations = await _sqliteDb.queryAllRows(table);
        for (int i = 0; i < configurations.length; i++) {
          supervisionPlanning.add(new Supervision(
              id: configurations[i]['id'],
              description: configurations[i]['name'],
              period: DateTime.parse(configurations[i]['period']),
              uid: configurations[i]['sup_uid']));
        }
        return supervisionPlanning;

      case 'metadata_mapping':
        List<MetadataMapping> metadataMappingConfig = [];
        table = 'METADATA_MAPPING';
        configurations = await _sqliteDb.queryAllRows(table);
        for (int i = 0; i < configurations.length; i++) {
          metadataMappingConfig.add(new MetadataMapping(
              id: configurations[i]['id'],
              uid: configurations[i]['uid'],
              code: configurations[i]['code']));
        }
        return metadataMappingConfig;
    }

    return results;
  }

  Future<dynamic> getConfigRow(String uid, String configType) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'facility':
        table = 'FACILITIES';
        configurations = await _sqliteDb.queryRow(table, uid);
        if (configurations.length == 1) {
          return true;
        }
        return false;

      case 'indicator':
        table = 'INDICATORS';
        configurations = await _sqliteDb.queryRow(table, uid);
        if (configurations.length == 1) {
          return true;
        }
        return false;

      case 'data_element':
        table = 'DATA_ELEMENTS';
        configurations = await _sqliteDb.queryRow(table, uid);
        if (configurations.length == 1) {
          return true;
        }
        return false;
    }

    return configurations;
  }

  Future<dynamic> getConfigRowById(String configType, int id) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'supervision':
        table = 'SUPERVISIONS';
        configurations = await _sqliteDb.queryRowById(table, id);
        if (configurations.length == 1) {
          bool usePackage = false;
          if (configurations[0]['usepackage'].toLowerCase() == 'true') {
            usePackage = true;
          } else {
            usePackage = false;
          }
          supervision = new Supervision(
              id: configurations[0]['id'],
              description: configurations[0]['description'],
              period: DateTime.parse(configurations[0]['period']),
              usePackage: usePackage,
              uid: configurations[0]['uid']);

          return supervision;
        }
        return false;

      case 'facility':
        table = 'FACILITIES';
        configurations = await _sqliteDb.queryRowById(table, id);
        if (configurations.length == 1) {
          bool isDhis;
          if (configurations[0]['is_dhis_facility'] == 'false')
            isDhis = false;
          else
            isDhis = true;
          facility =
              new Facility(id: configurations[0]['id'], uid: configurations[0]['uid'], name: configurations[0]['name'], isDhisFacility: isDhis);

          return facility;
        }
        return false;
    }

    return configurations;
  }

  // Data rows.
  Future<List> getDataRowsByFacilityAndSupervision(String configType, int supervisionId, facilityId) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'entrydqimprovementplan':
        List<EntryDqImprovementPlan> entryDqImprovementPlan = new List<EntryDqImprovementPlan>();
        table = 'ENTRY_DQ_IMPROVEMENT';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entryDqImprovementPlan.add(new EntryDqImprovementPlan(
              id: configurations[i]['id'],
              supervisionId: configurations[i]['supervisionid'],
              facilityId: configurations[i]['facilityid'],
              weaknesses: configurations[i]['weaknesses'],
              actionPointDescription: configurations[i]['actionpointdescription'],
              responsibles: configurations[i]['responsibles'],
              timeLine: DateTime.parse(configurations[i]['timeline']),
              comment: configurations[i]['comment'],
              type: configurations[i]['type']));
        }
        return entryDqImprovementPlan;

      case 'entryconsistencyovertimediscrepancy':
        List<EntryConsistencyOverTimeDiscrepancies> entryConsistencyOverTimeDiscrepancies = new List<EntryConsistencyOverTimeDiscrepancies>();
        table = 'ENTRY_CONSISTENCY_OVER_TIME_DISCREPANCIES';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entryConsistencyOverTimeDiscrepancies.add(new EntryConsistencyOverTimeDiscrepancies(
              id: configurations[i]['id'],
              supervisionId: configurations[i]['supervisionid'],
              facilityId: configurations[i]['facilityid'],
              entryDiscrepanciesId: configurations[i]['entrydiscrepanciesid']));
        }
        return entryConsistencyOverTimeDiscrepancies;

      case 'entrysourcedocumentcompleteness':
        List<EntrySourceDocumentCompleteness> entrySourceDocumentCompleteness = new List<EntrySourceDocumentCompleteness>();
        table = 'ENTRY_SOURCE_DOCUMENT_COMPLETENESS';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entrySourceDocumentCompleteness.add(new EntrySourceDocumentCompleteness(
              id: configurations[i]['id'],
              supervisionId: configurations[i]['supervisionid'],
              facilityId: configurations[i]['facilityid'],
              sourceDocumentId: configurations[i]['sourcedocumentid'],
              available: configurations[i]['availabe'],
              upToDate: configurations[i]['uptodate'],
              standardForm: configurations[i]['standardform'],
              availableResult: configurations[i]['availaberesult'],
              upToDateResult: configurations[i]['uptodateresult'],
              standardFormResult: configurations[i]['standardformresult'],
              comment: configurations[i]['comment'],
              type: configurations[i]['type']));
        }
        return entrySourceDocumentCompleteness;

      case 'entrydataelementcompleteness':
        List<EntryDataElementCompleteness> entryDataElementCompleteness = new List<EntryDataElementCompleteness>();
        table = 'ENTRY_DATA_ELEMENT_COMPLETENESS';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entryDataElementCompleteness.add(new EntryDataElementCompleteness(
            id: configurations[i]['id'],
            supervisionId: configurations[i]['supervisionid'],
            facilityId: configurations[i]['facilityid'],
            dataElementId: configurations[i]['dataelementid'],
            missingCasesData: configurations[i]['missingcasesdata'],
            percent: configurations[i]['percent'],
            type: configurations[i]['type'],
          ));
        }
        return entryDataElementCompleteness;

      case 'entrycrosscheckab':
        List<EntryCrossCheckAb> entryCrossCheckAb = new List<EntryCrossCheckAb>();
        table = 'ENTRY_CROSS_CHECK_AB';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entryCrossCheckAb.add(new EntryCrossCheckAb(
            id: configurations[i]['id'],
            supervisionId: configurations[i]['supervisionid'],
            facilityId: configurations[i]['facilityid'],
            primaryDataSourceId: configurations[i]['primarydatasourceid'],
            secondaryDataSourceId: configurations[i]['secondarydatasourceid'],
            casesSimpledFromPrimary: configurations[i]['casessimpledfromprimary'],
            primaryComment: configurations[i]['primarycomment'],
            correspondingMachingInSecondary: configurations[i]['correspondingmachinginsecondary'],
            secondaryComment: configurations[i]['secondarycomment'],
            secondaryReliabilityRate: configurations[i]['secondaryreliabilityrate'],
            reliabilityComment: configurations[i]['reliabilitycomment'],
            type: configurations[i]['type'],
          ));
        }
        return entryCrossCheckAb;

      case 'entrycrosscheckcdiscrepancies':
        List<EntryCrossCheckCDiscrepancies> entryCrossCheckCDiscrepancies = new List<EntryCrossCheckCDiscrepancies>();
        table = 'ENTRY_CROSS_CHECK_C_DISCREPANCIES';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entryCrossCheckCDiscrepancies.add(new EntryCrossCheckCDiscrepancies(
            id: configurations[i]['id'],
            supervisionId: configurations[i]['supervisionid'],
            facilityId: configurations[i]['facilityid'],
            primaryDataSourceId: configurations[i]['primarydatasourceid'],
            secondaryDataSourceId: configurations[i]['secondarydatasourceid'],
            entryDiscrepanciesId: configurations[i]['entrydiscrepanciesid'],
          ));
        }
        return entryCrossCheckCDiscrepancies;

      case 'entrydataaccuracy':
        List<EntryDataAccuracy> entryDataAccuracy = new List<EntryDataAccuracy>();
        table = 'ENTRY_DATA_ACCURACY';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);

        for (int i = 0; i < configurations.length; i++) {
          entryDataAccuracy.add(new EntryDataAccuracy(
            id: configurations[i]['id'],
            supervisionId: configurations[i]['supervisionid'],
            facilityId: configurations[i]['facilityid'],
            indicatorId: configurations[i]['indicatorid'],
            sourceDocumentRecount1: configurations[i]['sourcedocumentrecount1'],
            sourceDocumentRecount2: configurations[i]['sourcedocumentrecount2'],
            sourceDocumentRecount3: configurations[i]['sourcedocumentrecount3'],
            sourceDocumentRecountTotal: configurations[i]['sourcedocumentrecounttotal'],
            sourceDocumentRecountComment: configurations[i]['sourcedocumentrecountcomment'],
            hmisMonthlyReportValue1: configurations[i]['hmismonthlyreportvalue1'],
            hmisMonthlyReportValue2: configurations[i]['hmismonthlyreportvalue2'],
            hmisMonthlyReportValue3: configurations[i]['hmismonthlyreportvalue3'],
            hmisMonthlyReportValueTotal: configurations[i]['hmismonthlyreportvaluetotal'],
            hmisMonthlyReportValueComment: configurations[i]['hmismonthlyreportvaluecomment'],
            dhisMonthlyValue1: configurations[i]['dhismonthlyvalue1'],
            dhisMonthlyValue2: configurations[i]['dhismonthlyvalue2'],
            dhisMonthlyValue3: configurations[i]['dhismonthlyvalue3'],
            dhisMonthlyValueTotal: configurations[i]['dhismonthlyvaluetotal'],
            dhisMonthlyValueComment: configurations[i]['dhismonthlyvaluecomment'],
            monthlyReportVf1: configurations[i]['monthlyreportvf1'],
            monthlyReportVf2: configurations[i]['monthlyreportvf2'],
            monthlyReportVf3: configurations[i]['monthlyreportvf3'],
            monthlyReportVfTotal: configurations[i]['monthlyreportvftotal'],
            monthlyReportVfComment: configurations[i]['monthlyreportvfcomment'],
            dhisVf1: configurations[i]['dhisvf1'],
            dhisVf2: configurations[i]['dhisvf2'],
            dhisVf3: configurations[i]['dhisvf3'],
            dhisVfTotal: configurations[i]['dhisvftotal'],
            dhisVfComment: configurations[i]['dhisvfcomment'],
            reasonForDiscrepancyComment: configurations[i]['reasonfordiscrepancycomment'],
            otherReasonForDiscrepancy1: configurations[i]['otherreasonfordiscrepancy1'],
            otherReasonForDiscrepancy2: configurations[i]['otherreasonfordiscrepancy2'],
            otherReasonForDiscrepancy3: configurations[i]['otherreasonfordiscrepancy3'],
            otherReasonForDiscrepancyComment: configurations[i]['otherreasonfordiscrepancycomment'],
            type: configurations[i]['type'],
          ));
        }
        return entryDataAccuracy;
    }
  }

  Future<dynamic> checkDataEntryStatus(String configType, int supervisionId) async {
    var table;
    List<Map> result;
    int count;

    switch (configType) {
      case 'entrycompletenessmonthlyreport':
        table = 'ENTRY_COMPLETENESS_MONTHLY_REPORT';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entrytimelinessmonthlyreport':
        table = 'ENTRY_TIMELINESS_MONTHLY_REPORT';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entrydataelementcompleteness':
        table = 'ENTRY_DATA_ELEMENT_COMPLETENESS';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entrysourcedocumentcompleteness':
        table = 'ENTRY_SOURCE_DOCUMENT_COMPLETENESS';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entrydataaccuracy':
        table = 'ENTRY_DATA_ACCURACY';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entrycrosscheckab':
        table = 'ENTRY_CROSS_CHECK_AB';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entryconsistencyovertime':
        table = 'ENTRY_CONSISTENCY_OVER_TIME';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;

      case 'entrysystemassessment':
        table = 'ENTRY_SYSTEM_ASSESSMENT';
        result = await _sqliteDb.countRows(table, supervisionId);
        count = result[0]['count'];
        return count;
    }
  }

  Future<dynamic> checkFacilityDataEntryStatus(String configType, int supervisionId, int facilityId) async {
    var table;
    List<Map> result;
    int count;

    switch (configType) {
      case 'entrycompletenessmonthlyreport':
        table = 'ENTRY_COMPLETENESS_MONTHLY_REPORT';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entrytimelinessmonthlyreport':
        table = 'ENTRY_TIMELINESS_MONTHLY_REPORT';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entrydataelementcompleteness':
        table = 'ENTRY_DATA_ELEMENT_COMPLETENESS';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entrysourcedocumentcompleteness':
        table = 'ENTRY_SOURCE_DOCUMENT_COMPLETENESS';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entrydataaccuracy':
        table = 'ENTRY_DATA_ACCURACY';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entrycrosscheckab':
        table = 'ENTRY_CROSS_CHECK_AB';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entryconsistencyovertime':
        table = 'ENTRY_CONSISTENCY_OVER_TIME';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;

      case 'entrysystemassessment':
        table = 'ENTRY_SYSTEM_ASSESSMENT';
        result = await _sqliteDb.countFacilityRows(table, supervisionId, facilityId);
        count = result[0]['count'];
        return count;
    }
  }

  // Data object
  Future<dynamic> getDataRowByFacilityAndSupervision(String configType, int supervisionId, int facilityId) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'entrycompletenessmonthlyreport':
        EntryCompletenessMonthlyReport entryCompletenessMonthlyReport = new EntryCompletenessMonthlyReport();
        table = 'ENTRY_COMPLETENESS_MONTHLY_REPORT';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);
        if (configurations.length == 1) {
          entryCompletenessMonthlyReport = new EntryCompletenessMonthlyReport(
              id: configurations[0]['id'],
              supervisionId: configurations[0]['supervisionid'],
              facilityId: configurations[0]['facilityid'],
              expectedCells: configurations[0]['expectedcells'],
              completedCells: configurations[0]['completedcells'],
              percent: configurations[0]['percent'],
              comment: configurations[0]['comment']);

          return entryCompletenessMonthlyReport;
        }
        return entryCompletenessMonthlyReport;

      case 'entrytimelinessmonthlyreport':
        EntryTimelinessMonthlyReport entryTimelinessMonthlyReport = new EntryTimelinessMonthlyReport();
        table = 'ENTRY_TIMELINESS_MONTHLY_REPORT';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);
        if (configurations.length == 1) {
          entryTimelinessMonthlyReport = new EntryTimelinessMonthlyReport(
              id: configurations[0]['id'],
              supervisionId: configurations[0]['supervisionid'],
              facilityId: configurations[0]['facilityid'],
              submittedMonth1: configurations[0]['submittedmonth1'],
              submittedMonth2: configurations[0]['submittedmonth2'],
              submittedMonth3: configurations[0]['submittedmonth3'],
              percent: configurations[0]['percent'],
              comment: configurations[0]['comment']);

          return entryTimelinessMonthlyReport;
        }
        return entryTimelinessMonthlyReport;

      case 'entryconsistencyovertime':
        EntryConsistencyOverTime entryConsistencyOverTime = new EntryConsistencyOverTime();
        table = 'ENTRY_CONSISTENCY_OVER_TIME';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);
        if (configurations.length == 1) {
          entryConsistencyOverTime = new EntryConsistencyOverTime(
              id: configurations[0]['id'],
              supervisionId: configurations[0]['supervisionid'],
              facilityId: configurations[0]['facilityid'],
              indicatorId: configurations[0]['indicatorid'],
              currentMonthValue: configurations[0]['currentmonthValue'],
              currentMonthValueComment: configurations[0]['currentmonthvaluecomment'],
              currentMonthYearAgoValue: configurations[0]['currentmonthyearagovalue'],
              currentMonthYearAgoValueComment: configurations[0]['currentmonthyearagovaluecomment'],
              annualRatio: configurations[0]['annualratio'],
              annualRatioComment: configurations[0]['annualratiocomment'],
              monthToMonthValue1: configurations[0]['monthtomonthvalue1'],
              monthToMonthValue2: configurations[0]['monthtomonthvalue2'],
              monthToMonthValue3: configurations[0]['monthtomonthvalue3'],
              monthToMonthValueLastMonth: configurations[0]['monthtomonthvaluelastmonth'],
              monthToMonthRatio: configurations[0]['monthtomonthratio'],
              monthToMonthRatioComment: configurations[0]['monthtomonthratiocomment'],
              reasonForDiscrepancyComment: configurations[0]['reasonfordiscrepancycomment'],
              otherReasonForDiscrepancy: configurations[0]['otherreasonfordiscrepancy'],
              otherReasonForDiscrepancyComment: configurations[0]['otherreasonfordiscrepancycomment']);

          return entryConsistencyOverTime;
        }
        return entryConsistencyOverTime;

      case 'entrycrosscheckc':
        EntryCrossCheckC entryCrossCheckC = new EntryCrossCheckC();
        table = 'ENTRY_CROSS_CHECK_C';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);
        if (configurations.length == 1) {
          entryCrossCheckC = new EntryCrossCheckC(
              id: configurations[0]['id'],
              supervisionId: configurations[0]['supervisionid'],
              facilityId: configurations[0]['facilityid'],
              primaryDataSourceId: configurations[0]['primarydatasourceid'],
              secondaryDataSourceId: configurations[0]['secondarydatasourceid'],
              initialStock: configurations[0]['initialstock'],
              initialStockComment: configurations[0]['initialstockcomment'],
              receivedStock: configurations[0]['receivedstock'],
              receivedStockComment: configurations[0]['receivedstockcomment'],
              closingStock: configurations[0]['closingstock'],
              closingStockComment: configurations[0]['closingstockcomment'],
              usedStock: configurations[0]['usedstock'],
              usedStockComment: configurations[0]['usedstockcomment'],
              ratio: configurations[0]['ratio'],
              ratioComment: configurations[0]['ratiocomment'],
              reasonForDiscrepancyComment: configurations[0]['reasonfordiscrepancycomment'],
              otherReasonForDiscrepancy: configurations[0]['otherreasonfordiscrepancy'],
              otherReasonForDiscrepancyComment: configurations[0]['otherreasonfordiscrepancycomment']);

          return entryCrossCheckC;
        }
        return entryCrossCheckC;

      case 'entrysystemassessment':
        EntrySystemAssessment entrySystemAssessment = new EntrySystemAssessment();
        table = 'ENTRY_SYSTEM_ASSESSMENT';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);
        if (configurations.length == 1) {
          entrySystemAssessment = new EntrySystemAssessment(
              id: configurations[0]['id'],
              supervisionId: configurations[0]['supervisionid'],
              facilityId: configurations[0]['facilityid'],
              questionV1: configurations[0]['questionv1'],
              questionV1Comment: configurations[0]['questionv1comment'],
              questionV2: configurations[0]['questionv2'],
              questionV2Comment: configurations[0]['questionv2comment'],
              questionV3: configurations[0]['questionv3'],
              questionV3Comment: configurations[0]['questionv3comment'],
              questionV4: configurations[0]['questionv4'],
              questionV4Comment: configurations[0]['questionv4comment'],
              questionV5: configurations[0]['questionv5'],
              questionV5Comment: configurations[0]['questionv5comment'],
              questionV6: configurations[0]['questionv6'],
              questionV6Comment: configurations[0]['questionv6comment'],
              questionV7: configurations[0]['questionv7'],
              questionV7Comment: configurations[0]['questionv7comment'],
              questionV8: configurations[0]['questionv8'],
              questionV8Comment: configurations[0]['questionv8comment'],
              questionV9: configurations[0]['questionv9'],
              questionV9Comment: configurations[0]['questionv9comment'],
              questionV10: configurations[0]['questionv10'],
              questionV10Comment: configurations[0]['questionv10comment'],
              questionV11: configurations[0]['questionv11'],
              questionV11Comment: configurations[0]['questionv11comment'],
              questionV12: configurations[0]['questionv12'],
              questionV12Comment: configurations[0]['questionv12comment'],
              systemReadiness: configurations[0]['systemreadiness']);

          return entrySystemAssessment;
        }
        return entrySystemAssessment;

      case 'visit':
        Visit visit = new Visit();
        table = 'VISITS';
        configurations = await _sqliteDb.queryRowsBySupervisionAndFacility(table, supervisionId, facilityId);
        if (configurations.length == 1) {
          visit = new Visit(
              id: configurations[0]['id'],
              supervisionId: configurations[0]['supervisionid'],
              facilityId: configurations[0]['facilityid'],
              teamLead: configurations[0]['teamlead'],
              date: DateTime.parse(configurations[0]['date']));

          return visit;
        }
        return null;
    }
  }

// Data rows.
  Future<List> getDataRowsBySupervision(String configType, int supervisionId) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'crosscheck':
        List<CrossCheck> crossCheckConfig = new List<CrossCheck>();
        table = 'CROSS_CHECK';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          crossCheckConfig.add(new CrossCheck(
              id: configurations[i]['id'],
              primaryDataSourceId: configurations[i]['primarydatasourceid'],
              secondaryDataSourceId: configurations[i]['secondarydatasourceid'],
              supervisionId: configurations[i]['supervisionid'],
              type: configurations[i]['type']));
        }
        return crossCheckConfig;

      case 'supervisionfacilities':
        List<SupervisionFacilities> supervisionFacilitiesConfig = new List<SupervisionFacilities>();
        table = 'SUPERVISION_FACILITIES';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          supervisionFacilitiesConfig.add(new SupervisionFacilities(
              id: configurations[i]['id'], supervisionId: configurations[i]['supervisionid'], facilityId: configurations[i]['facilityid']));
        }
        return supervisionFacilitiesConfig;

      case 'dataelementcompleteness':
        List<DataElementCompleteness> dataElementCompletenessConfig = new List<DataElementCompleteness>();
        table = 'DATA_ELEMENT_COMPLETENESS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          dataElementCompletenessConfig.add(new DataElementCompleteness(
              id: configurations[i]['id'],
              dataElementId: configurations[i]['dataelementid'],
              number: configurations[i]['number'],
              supervisionId: configurations[i]['supervisionid']));
        }
        return dataElementCompletenessConfig;

      case 'selectedindicator':
        List<SelectedIndicator> selectedIndicatorsConfig = new List<SelectedIndicator>();
        table = 'SELECTED_INDICATORS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          selectedIndicatorsConfig.add(new SelectedIndicator(
              id: configurations[i]['id'],
              indicatorId: configurations[i]['indicatorid'],
              number: configurations[i]['number'],
              supervisionId: configurations[i]['supervisionid']));
        }
        return selectedIndicatorsConfig;

      case 'sourcedocumentcompleteness':
        List<SourceDocumentCompleteness> SourceDocumentCompletenessConfig = new List<SourceDocumentCompleteness>();
        table = 'SOURCE_DOCUMENT_COMPLETENESS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          SourceDocumentCompletenessConfig.add(new SourceDocumentCompleteness(
              id: configurations[i]['id'],
              sourceDocumentId: configurations[i]['sourcedocumentid'],
              number: configurations[i]['number'],
              supervisionId: configurations[i]['supervisionid']));
        }
        return SourceDocumentCompletenessConfig;

      case 'supervisionindicator':
        List<SupervisionIndicators> supervisionIndicatorsConfig = new List<SupervisionIndicators>();
        table = 'SUPERVISION_INDICATORS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          supervisionIndicatorsConfig.add(new SupervisionIndicators(
              id: configurations[i]['id'],
              supervisionId: configurations[i]['supervisionid'],
              indicatorId: configurations[i]['indicatorid'],
              type: configurations[i]['type']));
        }
        return supervisionIndicatorsConfig;

      case 'supervisionperiod':
        List<SupervisionPeriod> supervisionPeriodConfig = new List<SupervisionPeriod>();
        table = 'SUPERVISION_PERIODS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          supervisionPeriodConfig.add(new SupervisionPeriod(
              id: configurations[i]['id'], supervisionId: configurations[i]['supervisionid'], periodNumber: configurations[i]['periodnumber']));
        }
        return supervisionPeriodConfig;

      case 'visits':
        List<Visit> visitConfig = new List<Visit>();
        table = 'VISITS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          visitConfig.add(new Visit(
              id: configurations[i]['id'],
              supervisionId: configurations[i]['supervisionid'],
              facilityId: configurations[i]['facilityid'],
              date: DateTime.parse(configurations[i]['date']),
              teamLead: configurations[i]['teamlead']));
        }
        return visitConfig;

      case 'supervisionsection':
        List<SupervisionSection> sectionConfig = new List<SupervisionSection>();
        table = 'SUPERVISION_SECTIONS';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);

        for (int i = 0; i < configurations.length; i++) {
          sectionConfig.add(new SupervisionSection(
              id: configurations[i]['id'], supervisionId: configurations[i]['supervisionid'], sectionNumber: configurations[i]['sectionnumber']));
        }
        return sectionConfig;
    }
  }

  Future<List> getDataRowsByCountry(String configType, int countryId) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'supervision':
        List<Supervision> supervisionConfig = new List<Supervision>();
        table = 'SUPERVISIONS';
        bool usePackage = false;
        configurations = await _sqliteDb.queryRowsByCountry(table, countryId);

        for (int i = 0; i < configurations.length; i++) {
          if (configurations[i]['usepackage'].toLowerCase() == 'true') {
            usePackage = true;
          } else {
            usePackage = false;
          }
          supervisionConfig.add(new Supervision(
              id: configurations[i]['id'],
              description: configurations[i]['designation'],
              period: DateTime.parse(configurations[i]['period']),
              countryId: configurations[i]['countryid'],
              usePackage: usePackage,
              uid: configurations[i]['uid']));
        }
        return supervisionConfig;
    }
  }

  Future<List> getDataRowsBySupervisionCountryAndId(String configType, int supervisionId, int facilityId, int id) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'entrydataaccuracydiscrepancy':
        List<EntryDataAccuracyDiscrepancy> entryDataAccuracyDiscrepancy = new List<EntryDataAccuracyDiscrepancy>();
        table = 'ENTRY_DATA_ACCURACY_DISCREPANCIES';
        configurations = await _sqliteDb.queryRowsBySupervisionFacilityAndId(table, supervisionId, facilityId, id);

        for (int i = 0; i < configurations.length; i++) {
          entryDataAccuracyDiscrepancy.add(new EntryDataAccuracyDiscrepancy(
              id: configurations[i]['id'],
              supervisionId: configurations[i]['supervisionid'],
              facilityId: configurations[i]['facilityid'],
              indicatorId: configurations[i]['indicatorid'],
              entryDiscrepancyId: configurations[i]['entrydiscrepancyid'],
              month: configurations[i]['month']));
        }
        return entryDataAccuracyDiscrepancy;
    }
  }

  // Data object.
  Future<dynamic> getDataRowBySupervision(String configType, int supervisionId) async {
    var table;
    List<Map> configurations;

    switch (configType) {
      case 'consistencyovertime':
        ConsistencyOverTime consistencyOverTime = new ConsistencyOverTime();
        table = 'CONSISTENCY_OVER_TIME';
        configurations = await _sqliteDb.queryRowsBySupervision(table, supervisionId);
        if (configurations.length == 1) {
          consistencyOverTime = new ConsistencyOverTime(
              id: configurations[0]['id'], indicatorId: configurations[0]['indicatorid'], supervisionId: configurations[0]['supervisionid']);

          return consistencyOverTime;
        }

        return null;
    }
  }

  Future<void> configureDefaultSettings(String settingType) async {
    List<Map> configs = await _sqliteDb.queryAllRows(settingType);

    switch (settingType) {
      case 'SOURCE_DOCUMENT':
        if (configs.isEmpty) {
          List<dynamic> deData = await _csvManager.loadCSV("SOURCE_DOCUMENT.csv");
          for (var i = 0; i < deData.length; i++) {
            for (var j = 0; j < deData[i].length - 1; j++) {
              var uuid = Uuid();
              String name = deData[i][j];
              var data = {
                'uid': uuid.v1(),
                'name': name.replaceAll("\n", ""),
              };
              await _sqliteDb.insert('SOURCE_DOCUMENT', data);
            }
          }
        }
        break;
      case 'PERIODS':
        if (configs.isEmpty) {
          List<dynamic> deData = await _csvManager.loadCSV("PERIODS.csv");
          for (var i = 0; i < deData.length; i++) {
            for (var j = 0; j < deData[i].length - 1; j++) {
              var uuid = Uuid();
              String description = deData[i][j];
              var data = {
                'number': j + 1,
                'uid': uuid.v1(),
                'description': description.replaceAll("\n", ""),
              };
              await _sqliteDb.insert('PERIODS', data);
            }
          }
        }
        break;

      case 'SECTIONS':
        if (configs.isEmpty) {
          List<dynamic> deData = await _csvManager.loadCSV("SECTIONS.csv");
          for (var i = 0; i < deData.length; i++) {
            for (var j = 0; j < deData[i].length - 1; j++) {
              var uuid = Uuid();
              String uid = uuid.v1();
              String description = deData[i][j];
              var data = {
                'uid': uid,
                'number': j,
                'description': description.replaceAll("\n", ""),
              };
              _sqliteDb.insert('SECTIONS', data);
            }
          }
        }
        break;

      case 'DATA_ELEMENTS':
        if (configs.isEmpty) {
          List<dynamic> deData = await _csvManager.loadCSV("DATA_ELEMENTS.csv");
          for (var i = 0; i < deData.length; i++) {
            for (var j = 0; j < deData[i].length - 1; j++) {
              var uuid = Uuid();
              String uid = uuid.v1();
              String name = deData[i][j];
              var data = {'uid': uid, 'name': name.replaceAll("\n", ""), 'type_de': 0};
              _sqliteDb.insert('DATA_ELEMENTS', data);
            }
          }
        }
        break;

      case 'ENTRY_DISCREPANCIES':
        if (configs.isEmpty) {
          List<dynamic> deData = await _csvManager.loadCSV("ENTRY_DISCREPANCIES.csv");
          for (var i = 0; i < deData.length; i++) {
            for (var j = 0; j < deData[i].length - 1; j++) {
              String description = deData[i][j];
              var data = {'description': description.replaceAll("\n", "")};
              _sqliteDb.insert('ENTRY_DISCREPANCIES', data);
            }
          }
        }
        break;

      case 'INDICATORS':
        if (configs.isEmpty) {
          List<dynamic> deData = await _csvManager.loadCSV("INDICATORS.csv");
          for (var i = 0; i < deData.length; i++) {
            for (var j = 0; j < deData[i].length - 1; j++) {
              var uuid = Uuid();
              String uid = uuid.v1();
              String name = deData[i][j];
              var data = {'uid': uid, 'name': name.replaceAll("\n", ""), 'is_dhis_data_element': 'false'};
              _sqliteDb.insert('INDICATORS', data);
            }
          }
        }
        break;

      default:
    }
  }

  Future<int> saveRemoteConfig(
      String uid, String name, String catOptComboUid, String catOptComboName, bool isDhisDataElement, String configType) async {
    var data;
    var table;
    switch (configType) {
      case 'data_element':
        data = {
          'uid': uid,
          'name': name,
          'cat_opt_combo': catOptComboUid,
          'cat_opt_combo_name': catOptComboName,
          'is_dhis_data_element': isDhisDataElement.toString()
        };
        //table = 'DATA_ELEMENTS';
        table = 'INDICATORS';
        break;

      case 'facility':
        data = {'uid': uid, 'name': name, 'is_dhis_facility': isDhisDataElement.toString()};
        table = 'FACILITIES';
        break;
    }
    return _sqliteDb.insert(table, data);
  }

  Future<void> metaDataMapping(String settingType, List<dynamic> dataSetObject, List<dynamic> dataElementObject, List<dynamic> categoryOptionComboObject) async {
    List<Map> mapping = await _sqliteDb.queryAllRows(settingType);
    print("In metadata mapping service");

    if (mapping.isEmpty) {
      print("METADATA_MAPPING is ampty");
      for (var k = 0; k < dataSetObject.length; k++) {
        var data = {
          'uid': dataSetObject[k].uid,
          'code': dataSetObject[k].code,
        };
        await _sqliteDb.insert('METADATA_MAPPING', data);
      }
      for (var i = 0; i < dataElementObject.length; i++) {
        var data = {
          'uid': dataElementObject[i].uid,
          'code': dataElementObject[i].code,
        };
        await _sqliteDb.insert('METADATA_MAPPING', data);
      }
      for (var j = 0; j < categoryOptionComboObject.length; j++) {
        var data = {
          'uid': categoryOptionComboObject[j].uid,
          'code': categoryOptionComboObject[j].code,
        };
        await _sqliteDb.insert('METADATA_MAPPING', data);
      }
    }
  }

}
