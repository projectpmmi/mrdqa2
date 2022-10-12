import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/models/ConsistencyOverTime.dart';
import 'package:mrdqa_tool/models/CrossCheck.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:mrdqa_tool/models/EntrySourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/Periods.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/SourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:mrdqa_tool/models/SupervisionSection.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import '../models/Supervision.dart';
import '../models/EntryCompletenessMonthlyReport.dart';
import '../models/EntryTimelinessMonthlyReport.dart';
import '../models/EntryDataElementCompleteness.dart';
import '../models/EntryDataAccuracy.dart';
import '../models/EntryDataAccuracyDiscrepancy.dart';
import '../models/EntryDataAccuracyTuple2.dart';
import '../models/EntryCrossCheckAb.dart';
import '../models/EntryCrossCheckC.dart';
import '../models/EntryCrossCheckCDiscrepancies.dart';
import '../models/EntryCrossCheckCTuple2.dart';
import '../models/EntryDiscrepancies.dart';
import '../models/EntryConsistencyOverTime.dart';
import '../models/EntryConsistencyOverTimeDiscrepancies.dart';
import '../models/EntrySystemAssessment.dart';
import '../models/SupervisionPeriod.dart';
import 'package:mrdqa_tool/models/EntryConsistencyOverTimeTuple2.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:mrdqa_tool/models/Sections.dart';
import 'package:mrdqa_tool/helpers/MrdqaHelpers.dart';

class DataEntryPage extends StatefulWidget {
  static const String routeName = '/data_entry';
  final ConfigManager configManager;
  Supervision selectedSupervision;

  DataEntryPage(this.configManager, this.selectedSupervision);

  @override
  _DataEntryPageState createState() => _DataEntryPageState(this.configManager, this.selectedSupervision);
}

class _DataEntryPageState extends State<DataEntryPage> {
  int currentStep;
  bool complete;
  final ConfigManager configManager;
  Supervision selectedSupervision;
  final _completenesstimelinessformkey = GlobalKey<FormState>();
  final _crosscheckformkey = GlobalKey<FormState>();
  final _dataaccuracyformkey = GlobalKey<FormState>();
  final _consistencyovertimeformkey = GlobalKey<FormState>();
  final _systemassessmentformkey = GlobalKey<FormState>();
  Map<String, dynamic> supervisionData = {}; // keys: 'supervision' and facility ids.
  Map<String, dynamic> facilityData = {}; // Keys: 'completeness' ...
  Facility _currentFacility;
  EntryCompletenessMonthlyReport _entryCompletenessMonthlyReport; // completeness:
  EntryTimelinessMonthlyReport _entryTimelinessMonthlyReport; // timeliness:
  Map<String, EntryDataElementCompleteness> _entryDataElementCompletenessMap;
  Map<String, EntrySourceDocumentCompleteness> _entrySourceDocumentCompletenessMap;
  List<DataElementCompleteness> _dataElementCompletenesses;
  List<SourceDocumentCompleteness> _sourceDocumentCompletenesses;
  List<CrossCheck> _crossChecks;
  List<EntryDiscrepancies> _discrepancies;
  EntryDiscrepancies _discrepancy;
  List<EntryDataAccuracy> _entryDataAccuraciesList;
  EntryDataAccuracy __entryDataAccuracy;
  List<EntryDataAccuracyDiscrepancy> _entryDataAccuracyDiscrepancies;
  EntryDataAccuracyTuple2 _dataAccuracyTuple2;
  List<EntryDataAccuracyTuple2>
      _dataAccuracies; // data_accuracy. ex: supervisionData['facilityId']['data_accuracy'][0-2].entryDataAccuracy.selectedIndicatorId
  EntryCrossCheckC _entryCrossCheckC;
  EntryCrossCheckAb _entryCrossCheckAb;
  List<EntryCrossCheckAb> _entryCrossCheckAbList;
  List<EntryCrossCheckCDiscrepancies> _entryCrossCheckCDiscrepancies;
  EntryConsistencyOverTime _entryConsistencyOverTime;
  List<EntryConsistencyOverTimeDiscrepancies> _entryConsistencyOverTimeDiscrepancies;
  ConsistencyOverTime _consistencyOverTime;
  EntrySystemAssessment _entrySystemAssessment;
  List<Facility> _selectedFacilities;
  List<SelectedIndicator> _selectedIndicators;
  List<DataElement> _dataElements;
  List<SourceDocument> _sourceDocuments;
  List<Indicator> _indicators;
  List<Periods> _periods;
  List<Sections> _sections;
  List<SupervisionPeriod> _supervisionPeriods;
  List<SupervisionSection> _supervisionSections = [];
  List<Facility> _facilities;
  int _facilityId;
  String _facilityName = '';
  String _facilityUid = '';
  List<Map<String, dynamic>> _discrepancyItems = [];

  // Completeness and timeliness
  TextEditingController iaExpectedCells = new TextEditingController(); // int
  TextEditingController iaCompletedCells = new TextEditingController(); // int
  TextEditingController iaPercent = new TextEditingController(); // double
  TextEditingController iaComment = new TextEditingController(); // text

  TextEditingController ibSubmittedMonth1 = new TextEditingController(); // int
  TextEditingController ibSubmittedMonth2 = new TextEditingController(); // int
  TextEditingController ibSubmittedMonth3 = new TextEditingController(); // int
  TextEditingController ibPercent = new TextEditingController(); // double
  TextEditingController ibComment = new TextEditingController(); // String

  TextEditingController ic1missingCasesData = new TextEditingController(); // int
  TextEditingController ic1Percent = new TextEditingController(); // double
  TextEditingController ic2missingCasesData = new TextEditingController(); // int
  TextEditingController ic2Percent = new TextEditingController(); // double
  TextEditingController ic3missingCasesData = new TextEditingController(); // int
  TextEditingController ic3Percent = new TextEditingController(); // double
  TextEditingController ic4missingCasesData = new TextEditingController(); // int
  TextEditingController ic4Percent = new TextEditingController(); // double
  TextEditingController ic5missingCasesData = new TextEditingController(); // int
  TextEditingController ic5Percent = new TextEditingController(); // double
  TextEditingController ic6missingCasesData = new TextEditingController(); // int
  TextEditingController ic6Percent = new TextEditingController(); // double
  TextEditingController ic7missingCasesData = new TextEditingController(); // int
  TextEditingController ic7Percent = new TextEditingController(); // double
  TextEditingController ic8missingCasesData = new TextEditingController(); // int
  TextEditingController ic8Percent = new TextEditingController(); // double

  TextEditingController id1Availabe = new TextEditingController(); // int
  TextEditingController id1UpToDate = new TextEditingController(); // int
  TextEditingController id1StandardForm = new TextEditingController(); // int
  TextEditingController id1Comment = new TextEditingController(); // String
  TextEditingController id2Availabe = new TextEditingController(); // int
  TextEditingController id2UpToDate = new TextEditingController(); // int
  TextEditingController id2StandardForm = new TextEditingController(); // int
  TextEditingController id2Comment = new TextEditingController(); // String
  TextEditingController id3Availabe = new TextEditingController(); // int
  TextEditingController id3UpToDate = new TextEditingController(); // int
  TextEditingController id3StandardForm = new TextEditingController(); // int
  TextEditingController id3Comment = new TextEditingController(); // String
  TextEditingController id4Availabe = new TextEditingController(); // int
  TextEditingController id4UpToDate = new TextEditingController(); // int
  TextEditingController id4StandardForm = new TextEditingController(); // int
  TextEditingController id4Comment = new TextEditingController(); // String
  TextEditingController id5Availabe = new TextEditingController(); // int
  TextEditingController id5UpToDate = new TextEditingController(); // int
  TextEditingController id5StandardForm = new TextEditingController(); // int
  TextEditingController id5Comment = new TextEditingController(); // String
  TextEditingController id6Availabe = new TextEditingController(); // int
  TextEditingController id6UpToDate = new TextEditingController(); // int
  TextEditingController id6StandardForm = new TextEditingController(); // int
  TextEditingController id6Comment = new TextEditingController(); // String
  TextEditingController id7Availabe = new TextEditingController(); // int
  TextEditingController id7UpToDate = new TextEditingController(); // int
  TextEditingController id7StandardForm = new TextEditingController(); // int
  TextEditingController id7Comment = new TextEditingController(); // String
  TextEditingController id8Availabe = new TextEditingController(); // int
  TextEditingController id8UpToDate = new TextEditingController(); // int
  TextEditingController id8StandardForm = new TextEditingController(); // int
  TextEditingController id8Comment = new TextEditingController(); // String

  //Data accuracy
  TextEditingController ii1SourceDocumentRecount1 = new TextEditingController(); // int
  TextEditingController ii1SourceDocumentRecount2 = new TextEditingController(); // int
  TextEditingController ii1SourceDocumentRecount3 = new TextEditingController(); // int
  TextEditingController ii1SourceDocumentRecountTotal = new TextEditingController(); // int
  TextEditingController ii1SourceDocumentRecountComment = new TextEditingController(); // String
  TextEditingController ii1HmisMonthlyReportValue1 = new TextEditingController(); // int
  TextEditingController ii1HmisMonthlyReportValue2 = new TextEditingController(); // int
  TextEditingController ii1HmisMonthlyReportValue3 = new TextEditingController(); // int
  TextEditingController ii1HmisMonthlyReportValueTotal = new TextEditingController(); // int
  TextEditingController ii1HmisMonthlyReportValueComment = new TextEditingController(); // String
  TextEditingController ii1DhisMonthlyValue1 = new TextEditingController(); // int
  TextEditingController ii1DhisMonthlyValue2 = new TextEditingController(); // int
  TextEditingController ii1DhisMonthlyValue3 = new TextEditingController(); // int
  TextEditingController ii1DhisMonthlyValueTotal = new TextEditingController(); // int
  TextEditingController ii1DhisMonthlyValueComment = new TextEditingController(); // String
  TextEditingController ii1MonthlyReportVf1 = new TextEditingController(); // int
  TextEditingController ii1MonthlyReportVf2 = new TextEditingController(); // int
  TextEditingController ii1MonthlyReportVf3 = new TextEditingController(); // int
  TextEditingController ii1MonthlyReportVfTotal = new TextEditingController(); // int
  TextEditingController ii1MonthlyReportVfComment = new TextEditingController(); // String
  TextEditingController ii1DhisVf1 = new TextEditingController(); // int
  TextEditingController ii1DhisVf2 = new TextEditingController(); // int
  TextEditingController ii1DhisVf3 = new TextEditingController(); // int
  TextEditingController ii1DhisVfTotal = new TextEditingController(); // int
  TextEditingController ii1DhisVfComment = new TextEditingController(); // String
  List<dynamic> ii1DiscrepanciesMonth1 = [];
  List<dynamic> ii1DiscrepanciesMonth2 = [];
  List<dynamic> ii1DiscrepanciesMonth3 = [];
  TextEditingController ii1ReasonForDiscrepancyComment = new TextEditingController(); // String
  TextEditingController ii1OtherReasonForDiscrepancy1 = new TextEditingController(); // String
  TextEditingController ii1OtherReasonForDiscrepancy2 = new TextEditingController(); // String
  TextEditingController ii1OtherReasonForDiscrepancy3 = new TextEditingController(); // String
  TextEditingController ii1OtherReasonForDiscrepancyComment = new TextEditingController(); // String

  TextEditingController ii2SourceDocumentRecount1 = new TextEditingController(); // int
  TextEditingController ii2SourceDocumentRecount2 = new TextEditingController(); // int
  TextEditingController ii2SourceDocumentRecount3 = new TextEditingController(); // int
  TextEditingController ii2SourceDocumentRecountTotal = new TextEditingController(); // int
  TextEditingController ii2SourceDocumentRecountComment = new TextEditingController(); // String
  TextEditingController ii2HmisMonthlyReportValue1 = new TextEditingController(); // int
  TextEditingController ii2HmisMonthlyReportValue2 = new TextEditingController(); // int
  TextEditingController ii2HmisMonthlyReportValue3 = new TextEditingController(); // int
  TextEditingController ii2HmisMonthlyReportValueTotal = new TextEditingController(); // int
  TextEditingController ii2HmisMonthlyReportValueComment = new TextEditingController(); // String
  TextEditingController ii2DhisMonthlyValue1 = new TextEditingController(); // int
  TextEditingController ii2DhisMonthlyValue2 = new TextEditingController(); // int
  TextEditingController ii2DhisMonthlyValue3 = new TextEditingController(); // int
  TextEditingController ii2DhisMonthlyValueTotal = new TextEditingController(); // int
  TextEditingController ii2DhisMonthlyValueComment = new TextEditingController(); // String
  TextEditingController ii2MonthlyReportVf1 = new TextEditingController(); // int
  TextEditingController ii2MonthlyReportVf2 = new TextEditingController(); // int
  TextEditingController ii2MonthlyReportVf3 = new TextEditingController(); // int
  TextEditingController ii2MonthlyReportVfTotal = new TextEditingController(); // int
  TextEditingController ii2MonthlyReportVfComment = new TextEditingController(); // String
  TextEditingController ii2DhisVf1 = new TextEditingController(); // int
  TextEditingController ii2DhisVf2 = new TextEditingController(); // int
  TextEditingController ii2DhisVf3 = new TextEditingController(); // int
  TextEditingController ii2DhisVfTotal = new TextEditingController(); // int
  TextEditingController ii2DhisVfComment = new TextEditingController(); // String
  List<dynamic> ii2DiscrepanciesMonth1 = [];
  List<dynamic> ii2DiscrepanciesMonth2 = [];
  List<dynamic> ii2DiscrepanciesMonth3 = [];
  TextEditingController ii2ReasonForDiscrepancyComment = new TextEditingController(); // String
  TextEditingController ii2OtherReasonForDiscrepancy1 = new TextEditingController(); // String
  TextEditingController ii2OtherReasonForDiscrepancy2 = new TextEditingController(); // String
  TextEditingController ii2OtherReasonForDiscrepancy3 = new TextEditingController(); // String
  TextEditingController ii2OtherReasonForDiscrepancyComment = new TextEditingController(); // String

  TextEditingController ii3SourceDocumentRecount1 = new TextEditingController(); // int
  TextEditingController ii3SourceDocumentRecount2 = new TextEditingController(); // int
  TextEditingController ii3SourceDocumentRecount3 = new TextEditingController(); // int
  TextEditingController ii3SourceDocumentRecountTotal = new TextEditingController(); // int
  TextEditingController ii3SourceDocumentRecountComment = new TextEditingController(); // String
  TextEditingController ii3HmisMonthlyReportValue1 = new TextEditingController(); // int
  TextEditingController ii3HmisMonthlyReportValue2 = new TextEditingController(); // int
  TextEditingController ii3HmisMonthlyReportValue3 = new TextEditingController(); // int
  TextEditingController ii3HmisMonthlyReportValueTotal = new TextEditingController(); // int
  TextEditingController ii3HmisMonthlyReportValueComment = new TextEditingController(); // String
  TextEditingController ii3DhisMonthlyValue1 = new TextEditingController(); // int
  TextEditingController ii3DhisMonthlyValue2 = new TextEditingController(); // int
  TextEditingController ii3DhisMonthlyValue3 = new TextEditingController(); // int
  TextEditingController ii3DhisMonthlyValueTotal = new TextEditingController(); // int
  TextEditingController ii3DhisMonthlyValueComment = new TextEditingController(); // String
  TextEditingController ii3MonthlyReportVf1 = new TextEditingController(); // int
  TextEditingController ii3MonthlyReportVf2 = new TextEditingController(); // int
  TextEditingController ii3MonthlyReportVf3 = new TextEditingController(); // int
  TextEditingController ii3MonthlyReportVfTotal = new TextEditingController(); // int
  TextEditingController ii3MonthlyReportVfComment = new TextEditingController(); // String
  TextEditingController ii3DhisVf1 = new TextEditingController(); // int
  TextEditingController ii3DhisVf2 = new TextEditingController(); // int
  TextEditingController ii3DhisVf3 = new TextEditingController(); // int
  TextEditingController ii3DhisVfTotal = new TextEditingController(); // int
  TextEditingController ii3DhisVfComment = new TextEditingController(); // String
  List<dynamic> ii3DiscrepanciesMonth1 = [];
  List<dynamic> ii3DiscrepanciesMonth2 = [];
  List<dynamic> ii3DiscrepanciesMonth3 = [];
  TextEditingController ii3ReasonForDiscrepancyComment = new TextEditingController(); // String
  TextEditingController ii3OtherReasonForDiscrepancy1 = new TextEditingController(); // String
  TextEditingController ii3OtherReasonForDiscrepancy2 = new TextEditingController(); // String
  TextEditingController ii3OtherReasonForDiscrepancy3 = new TextEditingController(); // String
  TextEditingController ii3OtherReasonForDiscrepancyComment = new TextEditingController(); // String

  // Cross check.
  TextEditingController iiiaCasesSimpledFromPrimary = new TextEditingController(); // int
  TextEditingController iiiaPrimaryComment = new TextEditingController(); // String
  TextEditingController iiiaCorrespondingMachingInSecondary = new TextEditingController(); // int
  TextEditingController iiiaSecondaryComment = new TextEditingController(); // String
  TextEditingController iiiaSecondaryReliabilityRate = new TextEditingController(); // int
  TextEditingController iiiaReliabilityComment = new TextEditingController(); // String

  TextEditingController iiibCasesSimpledFromPrimary = new TextEditingController(); // int
  TextEditingController iiibPrimaryComment = new TextEditingController(); // String
  TextEditingController iiibCorrespondingMachingInSecondary = new TextEditingController(); // int
  TextEditingController iiibSecondaryComment = new TextEditingController(); // String
  TextEditingController iiibSecondaryReliabilityRate = new TextEditingController(); // int
  TextEditingController iiibReliabilityComment = new TextEditingController(); // String

  TextEditingController iiicInitialStock = new TextEditingController(); // Int
  TextEditingController iiicInitialStockComment = new TextEditingController(); // String
  TextEditingController iiicReceivedStock = new TextEditingController(); // Int
  TextEditingController iiicReceivedStockComment = new TextEditingController(); // String
  TextEditingController iiicClosingStock = new TextEditingController(); // Int
  TextEditingController iiicClosingStockComment = new TextEditingController(); // String
  TextEditingController iiicUsedStock = new TextEditingController(); // Int
  TextEditingController iiicUsedStockComment = new TextEditingController(); // String
  TextEditingController iiicRatio = new TextEditingController(); // Double
  TextEditingController iiicRatioComment = new TextEditingController(); // String
  List<dynamic> iiicReasonForDiscrepancy = [];
  TextEditingController iiicReasonForDiscrepancyComment = new TextEditingController(); // String
  TextEditingController iiicOtherReasonForDiscrepancy = new TextEditingController(); // String
  TextEditingController iiicOtherReasonForDiscrepancyComment = new TextEditingController(); // String

  // Consistency over time
  TextEditingController ivCurrentMonthValue = new TextEditingController(); // Double
  TextEditingController ivCurrentMonthValueComment = new TextEditingController(); // String
  TextEditingController ivCurrentMonthYearAgoValue = new TextEditingController(); // Double
  TextEditingController ivCurrentMonthYearAgoValueComment = new TextEditingController(); // String
  TextEditingController ivAnnualRatio = new TextEditingController(); // Double
  TextEditingController ivAnnualRatioComment = new TextEditingController(); // String
  TextEditingController ivMonthToMonthValue1 = new TextEditingController(); // Double
  TextEditingController ivMonthToMonthValue2 = new TextEditingController(); // Double
  TextEditingController ivMonthToMonthValue3 = new TextEditingController(); // Double
  TextEditingController ivMonthToMonthValueLastMonth = new TextEditingController(); // Double
  TextEditingController ivMonthToMonthRatio = new TextEditingController(); // Double
  TextEditingController ivMonthToMonthRatioComment = new TextEditingController(); // Double
  List<dynamic> ivReasonForDiscrepancy = [];
  TextEditingController ivReasonForDiscrepancyComment = new TextEditingController(); // String
  TextEditingController ivOtherReasonForDiscrepancy = new TextEditingController(); // String
  TextEditingController ivOtherReasonForDiscrepancyComment = new TextEditingController(); // String

  // System assessment
  TextEditingController vQuestionV1 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV1Comment = new TextEditingController(); // String
  TextEditingController vQuestionV2 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV2Comment = new TextEditingController(); // String
  TextEditingController vQuestionV3 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV3Comment = new TextEditingController(); // String
  TextEditingController vQuestionV4 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV4Comment = new TextEditingController(); // String
  TextEditingController vQuestionV5 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV5Comment = new TextEditingController(); // String
  TextEditingController vQuestionV6 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV6Comment = new TextEditingController(); // String
  TextEditingController vQuestionV7 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV7Comment = new TextEditingController(); // String
  TextEditingController vQuestionV8 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV8Comment = new TextEditingController(); // String
  TextEditingController vQuestionV9 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV9Comment = new TextEditingController(); // String
  TextEditingController vQuestionV10 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV10Comment = new TextEditingController(); // String
  TextEditingController vQuestionV11 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV11Comment = new TextEditingController(); // String
  TextEditingController vQuestionV12 = new TextEditingController(); // String YES/NO
  TextEditingController vQuestionV12Comment = new TextEditingController(); // String
  TextEditingController systemReadiness = new TextEditingController(); // Float

  List<StepState> _listState;
  List<Step> _stepList;
  String _dataAccuracyMonth1 = "Null [Month 1 is not selected]";
  String _dataAccuracyMonth2 = "Null [Month 2 is not selected]";
  String _dataAccuracyMonth3 = "Null [Month 3 is not selected]";
  String _consistencyMonth1 = "Null [Select current Month]";
  String _consistencyMonth2 = "Null [Select current Month]";
  String _consistencyMonth3 = "Null [Select current Month]";
  String _consistencyCurrentMonth = "Null [Select current Month]";
  String _dataElement1 = "Null [Data element 1 is not selected]";
  String _dataElement2 = "Null [Data element 2 is not selected]";
  String _dataElement3 = "Null [Data element 3 is not selected]";
  String _dataElement4 = "Null [Data element 4 is not selected]";
  String _dataElement5 = "Null [Data element 5 is not selected]";
  String _dataElement6 = "Null [Data element 6 is not selected]";
  String _dataElement7 = "Number of entries missing data in at least 1 of the 6 columns listed above";
  String _dataElement8 = "Total number of entries for the period";
  String _sourceDocument1 = "Null [Source document 1 is not selected]";
  String _sourceDocument2 = "Null [Source document 2 is not selected]";
  String _sourceDocument3 = "Null [Source document 3 is not selected]";
  String _sourceDocument4 = "Null [Source document 4 is not selected]";
  String _sourceDocument5 = "Null [Source document 5 is not selected]";
  String _sourceDocument6 = "Null [Source document 6 is not selected]";
  String _sourceDocument7 = "Null [Source document 7 is not selected]";
  String _sourceDocument8 = "% Complete";
  String _dataAccuracy1 = "Null [Data accuracy 1 is not configured]";
  String _dataAccuracy2 = "Null [Data accuracy 2 is not configured]";
  String _dataAccuracy3 = "Null [Data accuracy 3 is not configured]";
  String _crossCheckPrimary1 = "Null [Cross check 1 is not well configured]";
  String _crossCheckPrimary2 = "Null [Cross check 2 is not well configured]";
  String _crossCheckPrimary3 = "Null [Cross check 3 is not well configured]";
  String _crossCheckSecondary1 = "Null [Cross check 1 is not well configured]";
  String _crossCheckSecondary2 = "Null [Cross check 2 is not well configured]";
  String _crossCheckSecondary3 = "Null [Cross check 3 is not well configured]";
  String _consistencyLabel = "Null [Consistency over time is not selected]";
  var dropdownItems;
  List<Map<String, dynamic>> _dropItems;
  bool _isFillingPushing;
  List<Map<String, dynamic>> dropItems = [];
  List<int> _sectionsNumbers = [];

  _DataEntryPageState(this.configManager, this.selectedSupervision);

  @override
  void initState() {
    dropdownItems = [
      {"value": "0", "display": "No"},
      {"value": "1", "display": "Yes"}
    ];
    _dropItems = [
      {'value': "0", 'label': 'No'},
      {'value': "1", 'label': 'Yes'}
    ];
    currentStep = 0;
    complete = false;
    _listState = [
      StepState.indexed,
      StepState.editing,
      StepState.complete,
    ];
    _facilityId = null;
    _isFillingPushing = false;
    _getConfig().then((value) {
      _dataAccuracyMonth1 = MrdqaHelpers.getObjectByNumber(_periods, _supervisionPeriods[0].periodNumber, 'period').description;
      _dataAccuracyMonth2 = MrdqaHelpers.getObjectByNumber(_periods, _supervisionPeriods[1].periodNumber, 'period').description;
      _dataAccuracyMonth3 = MrdqaHelpers.getObjectByNumber(_periods, _supervisionPeriods[2].periodNumber, 'period').description;
      for (var i = 0; i < _dataElementCompletenesses.length; i++) {
        if (_dataElementCompletenesses[i].number == 1) {
          _dataElement1 = MrdqaHelpers.getObjectById(_dataElements, _dataElementCompletenesses[i].dataElementId, 'data_element').name;
        } else if (_dataElementCompletenesses[i].number == 2) {
          _dataElement2 = MrdqaHelpers.getObjectById(_dataElements, _dataElementCompletenesses[i].dataElementId, 'data_element').name;
        } else if (_dataElementCompletenesses[i].number == 3) {
          _dataElement3 = MrdqaHelpers.getObjectById(_dataElements, _dataElementCompletenesses[i].dataElementId, 'data_element').name;
        } else if (_dataElementCompletenesses[i].number == 4) {
          _dataElement4 = MrdqaHelpers.getObjectById(_dataElements, _dataElementCompletenesses[i].dataElementId, 'data_element').name;
        } else if (_dataElementCompletenesses[i].number == 5) {
          _dataElement5 = MrdqaHelpers.getObjectById(_dataElements, _dataElementCompletenesses[i].dataElementId, 'data_element').name;
        } else if (_dataElementCompletenesses[i].number == 6) {
          _dataElement6 = MrdqaHelpers.getObjectById(_dataElements, _dataElementCompletenesses[i].dataElementId, 'data_element').name;
        }
      }
      for (var i = 0; i < _sourceDocumentCompletenesses.length; i++) {
        if (_sourceDocumentCompletenesses[i].number == 1) {
          _sourceDocument1 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        } else if (_sourceDocumentCompletenesses[i].number == 2) {
          _sourceDocument2 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        } else if (_sourceDocumentCompletenesses[i].number == 3) {
          _sourceDocument3 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        } else if (_sourceDocumentCompletenesses[i].number == 4) {
          _sourceDocument4 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        } else if (_sourceDocumentCompletenesses[i].number == 5) {
          _sourceDocument5 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        } else if (_sourceDocumentCompletenesses[i].number == 6) {
          _sourceDocument6 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        } else if (_sourceDocumentCompletenesses[i].number == 7) {
          _sourceDocument7 = MrdqaHelpers.getObjectById(_sourceDocuments, _sourceDocumentCompletenesses[i].sourceDocumentId, 'source_document').name;
        }
      }
      for (var i = 0; i < _selectedIndicators.length; i++) {
        if (_selectedIndicators[i].number == 1) {
          _dataAccuracy1 = MrdqaHelpers.getObjectById(_indicators, _selectedIndicators[i].indicatorId, 'indicator').name;
        } else if (_selectedIndicators[i].number == 2) {
          _dataAccuracy2 = MrdqaHelpers.getObjectById(_indicators, _selectedIndicators[i].indicatorId, 'indicator').name;
        } else if (_selectedIndicators[i].number == 3) {
          _dataAccuracy3 = MrdqaHelpers.getObjectById(_indicators, _selectedIndicators[i].indicatorId, 'indicator').name;
        }
      }
      for (var i = 0; i < _crossChecks.length; i++) {
        if (_crossChecks[i].type == "a") {
          _crossCheckPrimary1 = MrdqaHelpers.getObjectById(_sourceDocuments, _crossChecks[i].primaryDataSourceId, 'source_document').name;
          _crossCheckSecondary1 = MrdqaHelpers.getObjectById(_sourceDocuments, _crossChecks[i].secondaryDataSourceId, 'source_document').name;
        } else if (_crossChecks[i].type == "b") {
          _crossCheckPrimary2 = MrdqaHelpers.getObjectById(_sourceDocuments, _crossChecks[i].primaryDataSourceId, 'source_document').name;
          _crossCheckSecondary2 = MrdqaHelpers.getObjectById(_sourceDocuments, _crossChecks[i].secondaryDataSourceId, 'source_document').name;
        } else if (_crossChecks[i].type == "c") {
          _crossCheckPrimary3 = MrdqaHelpers.getObjectById(_sourceDocuments, _crossChecks[i].primaryDataSourceId, 'source_document').name;
          _crossCheckSecondary3 = MrdqaHelpers.getObjectById(_sourceDocuments, _crossChecks[i].secondaryDataSourceId, 'source_document').name;
        }
      }
      if (_consistencyOverTime != null) {
        _consistencyLabel = MrdqaHelpers.getObjectById(_indicators, _consistencyOverTime.indicatorId, 'indicator').name;
      }
      for (var i = 0; i < _supervisionSections.length; i++) {
        _sectionsNumbers.add(_supervisionSections[i].sectionNumber);
      }
    });
    super.initState();
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
                      configManager.getConfigRowById('facility', int.parse(value.toString())).then((value) async {
                        setState(() {
                          _currentFacility = value;
                          _facilityId = value.id;
                          _facilityName = value.name;
                          _facilityUid = value.uid;
                          _isFillingPushing = !_isFillingPushing;
                        });
                        await _fillForms();
                        setState(() {
                          _isFillingPushing = !_isFillingPushing;
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
            Divider(),
            Container(
                height: MediaQuery.of(context).size.height / 7,
                //child: _buildSupervisionForm(),
                child: Card(
                    //semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      side: new BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(4),
                    child: _currentFacility != null
                        ? Column(children: [
                            Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_currentFacility.name),
                            Divider(),
                            Text('UID:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_currentFacility.uid)
                          ])
                        : Center(child: Text('No facility selected!')))),
          ],
        ),
      ),
      new Step(
        isActive: false,
        state: !_sectionsNumbers.contains(1)
            ? StepState.error
            : currentStep == 1
                ? _listState[1]
                : currentStep > 1
                    ? _listState[2]
                    : _listState[0],
        title: const Text('I. Completeness & Timeliness'),
        content: _sectionsNumbers.contains(1)
            ? Column(
                children: <Widget>[
                  _completnessTimelinessForm(),
                ],
              )
            : Container(
                child: Center(
                  child: Text('This section is not selected!'),
                ),
              ),
      ),
      new Step(
        isActive: false,
        state: !_sectionsNumbers.contains(2)
            ? StepState.error
            : currentStep == 2
                ? _listState[1]
                : currentStep > 2
                    ? _listState[2]
                    : _listState[0],
        title: const Text('II. Data Accuracy'),
        content: _sectionsNumbers.contains(2)
            ? Column(
                children: <Widget>[
                  _dataAccuracyForm(),
                ],
              )
            : Container(
                child: Center(
                  child: Text('This section is not selected!'),
                ),
              ),
      ),
      new Step(
        isActive: false,
        state: !_sectionsNumbers.contains(3)
            ? StepState.error
            : currentStep == 3
                ? _listState[1]
                : currentStep > 3
                    ? _listState[2]
                    : _listState[0],
        title: const Text('III. Cross check'),
        content: _sectionsNumbers.contains(3)
            ? Column(
                children: <Widget>[
                  _crossCheckForm(),
                ],
              )
            : Container(
                child: Center(
                  child: Text('This section is not selected!'),
                ),
              ),
      ),
      new Step(
        isActive: false,
        state: !_sectionsNumbers.contains(4)
            ? StepState.error
            : currentStep == 4
                ? _listState[1]
                : currentStep > 4
                    ? _listState[2]
                    : _listState[0],
        title: const Text('IV.Consistency Checks -Consistency of data elements over time'),
        content: _sectionsNumbers.contains(4)
            ? Column(
                children: <Widget>[_consistencyOverTimeForm()],
              )
            : Container(
                child: Center(
                  child: Text('This section is not selected!'),
                ),
              ),
      ),
      new Step(
        isActive: false,
        state: !_sectionsNumbers.contains(5)
            ? StepState.error
            : currentStep == 5
                ? _listState[1]
                : currentStep > 5
                    ? _listState[2]
                    : _listState[0],
        title: const Text('V.System Assessment - Respond Yes or No for the following questions'),
        content: _sectionsNumbers.contains(5)
            ? Column(
                children: <Widget>[
                  _systemAssessmentForm(),
                ],
              )
            : Container(
                child: Center(
                  child: Text('This section is not selected!'),
                ),
              ),
      )
    ];

    return _steps;
  }

  next(length) {
    currentStep + 1 != length ? goTo(currentStep + 1) : setState(() => complete = true);
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
    _stepList = _createSteps(context, _selectedFacilities);
    return Scaffold(
      appBar: AppBar(
        title: Text('Data entry form'),
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
                                if (currentStep == 1) {
                                  if (_sectionsNumbers.contains(1)) {
                                    if (!_completenesstimelinessformkey.currentState.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildPopupDialog(context, 'Fail validation', 'This form is not complete yet'),
                                      );
                                    }
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                    await _pushStepOne();
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                  }
                                } else if (currentStep == 2) {
                                  if (_sectionsNumbers.contains(2)) {
                                    if (!_dataaccuracyformkey.currentState.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildPopupDialog(context, 'Fail validation', 'This form is not complete yet'),
                                      );
                                    }
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                    await _pushStepTwo();
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                  }
                                } else if (currentStep == 3) {
                                  if (_sectionsNumbers.contains(3)) {
                                    if (!_crosscheckformkey.currentState.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildPopupDialog(context, 'Fail validation', 'This form is not complete yet'),
                                      );
                                    }
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                    await _pushStepThree();
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                  }
                                } else if (currentStep == 4) {
                                  if (_sectionsNumbers.contains(4)) {
                                    if (!_consistencyovertimeformkey.currentState.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildPopupDialog(context, 'Fail validation', 'This form is not complete yet'),
                                      );
                                    }
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                    await _pushStepFour();
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                  }
                                } else if (currentStep == 5) {
                                  if (_sectionsNumbers.contains(5)) {
                                    if (!_systemassessmentformkey.currentState.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildPopupDialog(context, 'Fail validation', 'This form is not complete yet'),
                                      );
                                    }
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                    await _pushStepFive();
                                    setState(() {
                                      _isFillingPushing = !_isFillingPushing;
                                    });
                                  }
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

  Widget _completnessTimelinessForm() {
    return Form(
      key: _completenesstimelinessformkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: Text("A. Completeness of Malaria Monthly Report", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              )
            ],
          ),
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: iaExpectedCells,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Expected Cells",
                        ),
                        onChanged: (val) {
                          calculateCompleteness();
                        },
                      ),
                    ),
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: iaCompletedCells,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Completed Cells",
                        ),
                        onChanged: (val) {
                          calculateCompleteness();
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: iaPercent,
                        decoration: const InputDecoration(
                          labelText: "Percent Complete",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: iaComment,
                        decoration: const InputDecoration(
                          labelText: "Comment",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: Text("B. Timeliness of Submission of Monthly Report", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              )
            ],
          ),
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: _yesNoSelectIb(1),
                    ),
                    Flexible(
                      flex: 1,
                      child: _yesNoSelectIb(2),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: _yesNoSelectIb(3),
                    ),
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: ibPercent,
                        decoration: const InputDecoration(
                          labelText: "Percent Complete",
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: ibComment,
                        decoration: const InputDecoration(
                          labelText: "Comment",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: Text("C. Data Element Completeness", style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text("Malaria data elements"),
                ),
              ) // Add trailing icon to detail
            ],
          ),
          Container(
            child: Column(
              children: [
                _dataElement1 != 'Null [Data element 1 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('$_dataElement1'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ic1missingCasesData,
                                  validator: (v) {
                                    if (v.trim().isEmpty) return 'Please fill this field';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    ic1Percent.text = (ic1missingCasesData.text != '' && ic8missingCasesData.text != '')
                                        ? ((int.parse(ic1missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                                        : '';
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  controller: ic1Percent,
                                  decoration: const InputDecoration(
                                    hintText: '%',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                _dataElement2 != 'Null [Data element 2 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('$_dataElement2'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ic2missingCasesData,
                                  validator: (v) {
                                    if (v.trim().isEmpty) return 'Please fill this field';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    ic2Percent.text = (ic2missingCasesData.text != '' && ic8missingCasesData.text != '')
                                        ? ((int.parse(ic2missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                                        : '';
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  controller: ic2Percent,
                                  decoration: const InputDecoration(
                                    hintText: "%",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                _dataElement3 != 'Null [Data element 3 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('$_dataElement3'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ic3missingCasesData,
                                  validator: (v) {
                                    if (v.trim().isEmpty) return 'Please fill this field';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    ic3Percent.text = (ic3missingCasesData.text != '' && ic8missingCasesData.text != '')
                                        ? ((int.parse(ic3missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                                        : '';
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  controller: ic3Percent,
                                  decoration: const InputDecoration(
                                    hintText: "%",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                _dataElement4 != 'Null [Data element 4 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('$_dataElement4'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ic4missingCasesData,
                                  validator: (v) {
                                    if (v.trim().isEmpty) return 'Please fill this field';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    ic4Percent.text = (ic4missingCasesData.text != '' && ic8missingCasesData.text != '')
                                        ? ((int.parse(ic4missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                                        : '';
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  controller: ic4Percent,
                                  decoration: const InputDecoration(
                                    hintText: "%",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                _dataElement5 != 'Null [Data element 5 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('$_dataElement5'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ic5missingCasesData,
                                  validator: (v) {
                                    if (v.trim().isEmpty) return 'Please fill this field';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    ic5Percent.text = (ic5missingCasesData.text != '' && ic8missingCasesData.text != '')
                                        ? ((int.parse(ic5missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                                        : '';
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: ic5Percent,
                                  enabled: false,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "%",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                _dataElement6 != 'Null [Data element 6 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('$_dataElement6'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ic6missingCasesData,
                                  validator: (v) {
                                    if (v.trim().isEmpty) return 'Please fill this field';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    ic6Percent.text = (ic6missingCasesData.text != '' && ic8missingCasesData.text != '')
                                        ? ((int.parse(ic6missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                                        : '';
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  controller: ic6Percent,
                                  decoration: const InputDecoration(
                                    hintText: "%",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Row(
                  children: [
                    Expanded(
                      child: Text('$_dataElement7'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 7,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: ic7missingCasesData,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        onChanged: (val) {
                          ic7Percent.text = (ic7missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic7missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                        },
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: ic7Percent,
                        decoration: const InputDecoration(
                          hintText: "%",
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('$_dataElement8'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 7,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: ic8missingCasesData,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        onChanged: (val) {
                          ic8Percent.text = (ic8missingCasesData.text != '')
                              ? ((int.parse(ic8missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic1Percent.text = (ic1missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic1missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic2Percent.text = (ic2missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic2missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic3Percent.text = (ic3missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic3missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic4Percent.text = (ic4missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic4missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic5Percent.text = (ic5missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic5missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic6Percent.text = (ic6missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic6missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                          ic7Percent.text = (ic7missingCasesData.text != '' && ic8missingCasesData.text != '')
                              ? ((int.parse(ic7missingCasesData.text) / int.parse(ic8missingCasesData.text)) * 100).toStringAsFixed(2)
                              : '';
                        },
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: ic8Percent,
                        decoration: const InputDecoration(
                          hintText: "%",
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: Text("D. Source Document Completeness", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ) // Add trailing icon to detail
            ],
          ),
          Container(
            child: Column(
              children: [
                _sourceDocument1 != 'Null [Source document 1 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument1, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(1),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(1),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(1),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id1Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                _sourceDocument2 != 'Null [Source document 2 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument2, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(2),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(2),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(2),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id2Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                _sourceDocument3 != 'Null [Source document 3 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument3, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(3),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(3),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(3),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id3Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                _sourceDocument4 != 'Null [Source document 4 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument4, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(4),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(4),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(4),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id4Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                _sourceDocument5 != 'Null [Source document 5 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument5, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(5),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(5),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(5),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id5Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                _sourceDocument6 != 'Null [Source document 6 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument6, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(6),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(6),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(6),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id6Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                _sourceDocument7 != 'Null [Source document 7 is not selected]'
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_sourceDocument7, style: TextStyle(fontWeight: FontWeight.w900)),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdAvailable(7),
                              ),
                              Flexible(
                                flex: 2,
                                child: _yesNoSelectIdUpToDate(7),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: _yesNoSelectIdStandard(7),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: id7Comment,
                                  decoration: const InputDecoration(
                                    labelText: "Comment",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Text(_sourceDocument8, style: TextStyle(fontWeight: FontWeight.w900)),
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: id8Availabe,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Available",
                        ),
                        // onChanged: (val) {
                        //   calculateSourceDocumentAvailabe();
                        // },
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: id8UpToDate,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Up-to-date",
                        ),
                        // onChanged: (val) {
                        //   calculateSourceDocumentUpToDate();
                        // },
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: id8StandardForm,
                        validator: (v) {
                          if (v.trim().isEmpty) return 'Please fill this field';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Standard form",
                        ),
                        // onChanged: (val) {
                        //   calculateSourceDocumentStandard();
                        // },
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
                        controller: id8Comment,
                        decoration: const InputDecoration(
                          labelText: "Comment",
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _dataAccuracyForm() {
    return Form(
      key: _dataaccuracyformkey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dataAccuracy1 != 'Null [Data accuracy 1 is not configured]'
            ? Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(_dataAccuracy1, style: TextStyle(fontWeight: FontWeight.w900)),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text('Source document re-count'),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1SourceDocumentRecount1,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth1,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyRecountTotal1();
                              calculateDataAccuracyMonthlyVf1Month1();
                              calculateDataAccuracyDhis2Vf1Month1();
                              calculateDataAccuracyMonthlyVfTotal1();
                              calculateDataAccuracyDhis2VfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1SourceDocumentRecount2,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth2,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyRecountTotal1();
                              calculateDataAccuracyMonthlyVf1Month2();
                              calculateDataAccuracyDhis2Vf1Month2();
                              calculateDataAccuracyMonthlyVfTotal1();
                              calculateDataAccuracyDhis2VfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1SourceDocumentRecount3,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth3,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyRecountTotal1();
                              calculateDataAccuracyMonthlyVf1Month3();
                              calculateDataAccuracyDhis2Vf1Month3();
                              calculateDataAccuracyMonthlyVfTotal1();
                              calculateDataAccuracyDhis2VfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            enabled: false,
                            controller: ii1SourceDocumentRecountTotal,
                            decoration: const InputDecoration(
                              labelText: "Total",
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyRecountTotal1();
                            },
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
                            controller: ii1SourceDocumentRecountComment,
                            decoration: const InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text('HMIS monthly report value'),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1HmisMonthlyReportValue1,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth1,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyHmisTotal1();
                              calculateDataAccuracyMonthlyVf1Month1();
                              calculateDataAccuracyMonthlyVfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1HmisMonthlyReportValue2,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth2,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyHmisTotal1();
                              calculateDataAccuracyMonthlyVf1Month2();
                              calculateDataAccuracyMonthlyVfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1HmisMonthlyReportValue3,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth3,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyHmisTotal1();
                              calculateDataAccuracyMonthlyVf1Month3();
                              calculateDataAccuracyMonthlyVfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            enabled: false,
                            controller: ii1HmisMonthlyReportValueTotal,
                            decoration: const InputDecoration(
                              labelText: "Total",
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyHmisTotal1();
                            },
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
                            controller: ii1HmisMonthlyReportValueComment,
                            decoration: const InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text('DHIS2 monthly value'),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1DhisMonthlyValue1,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth1,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyDhisTotal1();
                              calculateDataAccuracyDhis2Vf1Month1();
                              calculateDataAccuracyDhis2VfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1DhisMonthlyValue2,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth2,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyDhisTotal1();
                              calculateDataAccuracyDhis2Vf1Month2();
                              calculateDataAccuracyDhis2VfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1DhisMonthlyValue3,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth3,
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyDhisTotal1();
                              calculateDataAccuracyDhis2Vf1Month3();
                              calculateDataAccuracyDhis2VfTotal1();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            enabled: false,
                            controller: ii1DhisMonthlyValueTotal,
                            decoration: const InputDecoration(
                              labelText: "Total",
                            ),
                            onChanged: (val) {
                              calculateDataAccuracyDhisTotal1();
                            },
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
                            controller: ii1DhisMonthlyValueComment,
                            decoration: const InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text('Monthly Report Verification factor(VF):', style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1MonthlyReportVf1,
                            enabled: false,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth1,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1MonthlyReportVf2,
                            enabled: false,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth2,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1MonthlyReportVf3,
                            enabled: false,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth3,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            enabled: false,
                            controller: ii1MonthlyReportVfTotal,
                            decoration: const InputDecoration(
                              labelText: "Total",
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
                            controller: ii1MonthlyReportVfComment,
                            decoration: InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text('DHIS 2 Verification factor(VF):', style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1DhisVf1,
                            enabled: false,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth1,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            controller: ii1DhisVf2,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(labelText: _dataAccuracyMonth2),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ii1DhisVf3,
                            enabled: false,
                            validator: (v) {
                              if (v.trim().isEmpty) return 'Please fill this field';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth3,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            enabled: false,
                            controller: ii1DhisVfTotal,
                            decoration: const InputDecoration(
                              labelText: "Total",
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
                            controller: ii1DhisVfComment,
                            decoration: const InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Reasons for discrepancy', style: TextStyle(fontWeight: FontWeight.w900)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Center(
                          child: Text(_dataAccuracyMonth1),
                        ),
                        Flexible(
                          flex: 1,
                          child: _reasonForDiscrepancies11(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Center(
                          child: Text(_dataAccuracyMonth2),
                        ),
                        Flexible(
                          flex: 1,
                          child: _reasonForDiscrepancies12(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Center(
                          child: Text(_dataAccuracyMonth3),
                        ),
                        Flexible(
                          flex: 1,
                          child: _reasonForDiscrepancies13(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            controller: ii1ReasonForDiscrepancyComment,
                            decoration: const InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text('Other reason (specify)', style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            controller: ii1OtherReasonForDiscrepancy1,
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth1,
                            ),
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
                            controller: ii1OtherReasonForDiscrepancy2,
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth2,
                            ),
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
                            controller: ii1OtherReasonForDiscrepancy3,
                            decoration: InputDecoration(
                              labelText: _dataAccuracyMonth3,
                            ),
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
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: "Comment",
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            : SizedBox.shrink(),
        Divider(),
        _dataAccuracy2 != 'Null [Data accuracy 2 is not configured]'
            ? Container(
                child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_dataAccuracy2, style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('Source document re-count'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2SourceDocumentRecount1,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal2();
                            calculateDataAccuracyMonthlyVf2Month1();
                            calculateDataAccuracyDhis2Vf2Month1();
                            calculateDataAccuracyMonthlyVfTotal2();
                            calculateDataAccuracyDhis2VfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2SourceDocumentRecount2,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal2();
                            calculateDataAccuracyMonthlyVf2Month2();
                            calculateDataAccuracyDhis2Vf2Month2();
                            calculateDataAccuracyMonthlyVfTotal2();
                            calculateDataAccuracyDhis2VfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2SourceDocumentRecount3,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal2();
                            calculateDataAccuracyMonthlyVf2Month3();
                            calculateDataAccuracyDhis2Vf2Month3();
                            calculateDataAccuracyMonthlyVfTotal2();
                            calculateDataAccuracyDhis2VfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii2SourceDocumentRecountTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal2();
                          },
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
                          controller: ii2SourceDocumentRecountComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('HMIS monthly report value'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2HmisMonthlyReportValue1,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal2();
                            calculateDataAccuracyMonthlyVf2Month1();
                            calculateDataAccuracyMonthlyVfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2HmisMonthlyReportValue2,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal2();
                            calculateDataAccuracyMonthlyVf2Month2();
                            calculateDataAccuracyMonthlyVfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2HmisMonthlyReportValue3,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal2();
                            calculateDataAccuracyMonthlyVf2Month3();
                            calculateDataAccuracyMonthlyVfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii2HmisMonthlyReportValueTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal2();
                          },
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
                          controller: ii2HmisMonthlyReportValueComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('DHIS2 monthly value'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2DhisMonthlyValue1,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal2();
                            calculateDataAccuracyDhis2Vf2Month1();
                            calculateDataAccuracyDhis2VfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2DhisMonthlyValue2,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal2();
                            calculateDataAccuracyDhis2Vf2Month2();
                            calculateDataAccuracyDhis2VfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2DhisMonthlyValue3,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal2();
                            calculateDataAccuracyDhis2Vf2Month3();
                            calculateDataAccuracyDhis2VfTotal2();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii2DhisMonthlyValueTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal2();
                          },
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
                          controller: ii2DhisMonthlyValueComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text(' Monthly Report Verification factor(VF):', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2MonthlyReportVf1,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2MonthlyReportVf2,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2MonthlyReportVf3,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii2MonthlyReportVfTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            //calculateDataAccuracyMonthlyVfTotal2();
                          },
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
                          controller: ii2MonthlyReportVfComment,
                          decoration: InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('DHIS 2 Verification factor(VF):', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2DhisVf1,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2DhisVf2,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(labelText: _dataAccuracyMonth2),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii2DhisVf3,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii2DhisVfTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            //calculateDataAccuracyDhis2VfTotal2();
                          },
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
                          controller: ii2DhisVfComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Reasons for discrepancy', style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Center(child: Text(_dataAccuracyMonth1)),
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepancies21(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Center(child: Text(_dataAccuracyMonth2)),
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepancies22(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Center(child: Text(_dataAccuracyMonth3)),
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepancies23(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: ii2ReasonForDiscrepancyComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('Other reason (specify)', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: ii2OtherReasonForDiscrepancy1,
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
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
                          controller: ii2OtherReasonForDiscrepancy2,
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
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
                          controller: ii2OtherReasonForDiscrepancy3,
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
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
                          controller: ii2OtherReasonForDiscrepancyComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ))
            : SizedBox.shrink(),
        Divider(),
        _dataAccuracy3 != 'Null [Data accuracy 3 is not configured]'
            ? Container(
                child: Column(
                children: [
                  Row(
                    children: [
                      Text(_dataAccuracy3, style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('Source document re-count'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3SourceDocumentRecount1,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal3();
                            calculateDataAccuracyMonthlyVf3Month1();
                            calculateDataAccuracyDhis2Vf3Month1();
                            calculateDataAccuracyMonthlyVfTotal3();
                            calculateDataAccuracyDhis2VfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3SourceDocumentRecount2,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal3();
                            calculateDataAccuracyMonthlyVf3Month2();
                            calculateDataAccuracyDhis2Vf3Month2();
                            calculateDataAccuracyMonthlyVfTotal3();
                            calculateDataAccuracyDhis2VfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3SourceDocumentRecount3,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal3();
                            calculateDataAccuracyMonthlyVf3Month3();
                            calculateDataAccuracyDhis2Vf3Month3();
                            calculateDataAccuracyMonthlyVfTotal3();
                            calculateDataAccuracyDhis2VfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii3SourceDocumentRecountTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyRecountTotal3();
                          },
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
                          controller: ii3SourceDocumentRecountComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('HMIS monthly report value'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3HmisMonthlyReportValue1,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal3();
                            calculateDataAccuracyMonthlyVf3Month1();
                            calculateDataAccuracyMonthlyVfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3HmisMonthlyReportValue2,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal3();
                            calculateDataAccuracyMonthlyVf3Month2();
                            calculateDataAccuracyMonthlyVfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3HmisMonthlyReportValue3,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal3();
                            calculateDataAccuracyMonthlyVf3Month3();
                            calculateDataAccuracyMonthlyVfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii3HmisMonthlyReportValueTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyHmisTotal3();
                          },
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
                          controller: ii3HmisMonthlyReportValueComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('DHIS2 monthly value'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3DhisMonthlyValue1,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal3();
                            calculateDataAccuracyDhis2Vf3Month1();
                            calculateDataAccuracyDhis2VfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3DhisMonthlyValue2,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal3();
                            calculateDataAccuracyDhis2Vf3Month2();
                            calculateDataAccuracyDhis2VfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3DhisMonthlyValue3,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                          onChanged: (val) {
                            calculateDataAccuracyDhisTotal3();
                            calculateDataAccuracyDhis2Vf3Month3();
                            calculateDataAccuracyDhis2VfTotal3();
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii3DhisMonthlyValueTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
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
                          controller: ii3DhisMonthlyValueComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text(' Monthly Report Verification factor(VF):', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3MonthlyReportVf1,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3MonthlyReportVf2,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3MonthlyReportVf3,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii3MonthlyReportVfTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            //calculateDataAccuracyMonthlyVfTotal3();
                          },
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
                          controller: ii3MonthlyReportVfComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('DHIS 2 Verification factor(VF):', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3DhisVf1,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3DhisVf2,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(labelText: _dataAccuracyMonth2),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ii3DhisVf3,
                          enabled: false,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ii3DhisVfTotal,
                          decoration: const InputDecoration(
                            labelText: "Total",
                          ),
                          onChanged: (val) {
                            //calculateDataAccuracyDhis2VfTotal3();
                          },
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
                          controller: ii3DhisVfComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Reasons for discrepancy', style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Center(
                        child: Text(_dataAccuracyMonth1),
                      ),
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepancies31(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Center(
                        child: Text(_dataAccuracyMonth2),
                      ),
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepancies32(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Center(
                        child: Text(_dataAccuracyMonth3),
                      ),
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepancies33(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: ii3ReasonForDiscrepancyComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text('Other reason (specify)', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: ii3OtherReasonForDiscrepancy1,
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth1,
                          ),
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
                          controller: ii3OtherReasonForDiscrepancy2,
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth2,
                          ),
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
                          controller: ii3OtherReasonForDiscrepancy3,
                          decoration: InputDecoration(
                            labelText: _dataAccuracyMonth3,
                          ),
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
                          controller: ii3OtherReasonForDiscrepancyComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ))
            : SizedBox.shrink(),
      ]),
    );
  }

  Widget _consistencyOverTimeForm() {
    return Form(
        key: _consistencyovertimeformkey,
        child: _consistencyLabel != "Null [Consistency over time is not selected]"
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('IV.a: Annual consistency', style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_consistencyLabel, // Consistency indicator name
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('1. What is the current month value'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ivCurrentMonthValue,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            calculateConsistencyAnnualRatio();
                          },
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
                          controller: ivCurrentMonthValueComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('2. What was the value of the indicator for the current month one year ago'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ivCurrentMonthYearAgoValue,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            calculateConsistencyAnnualRatio();
                          },
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
                          controller: ivCurrentMonthYearAgoValueComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Consistency ratio'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: ivAnnualRatio,
                          onChanged: (val) {
                            calculateConsistencyAnnualRatio();
                          },
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
                          controller: ivAnnualRatioComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                ])),
                Divider(),
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('IV.b Month-to-month consistency:', style: TextStyle(fontWeight: FontWeight.w900)),
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: ivMonthToMonthValue1,
                              validator: (v) {
                                if (v.trim().isEmpty) return 'Please fill this field';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Month 1: $_consistencyMonth1",
                              ),
                              onChanged: (val) {
                                calculateConsistencyMonthToMonthRatio();
                              },
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: ivMonthToMonthValue2,
                              validator: (v) {
                                if (v.trim().isEmpty) return 'Please fill this field';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Month 2: $_consistencyMonth2",
                              ),
                              onChanged: (val) {
                                calculateConsistencyMonthToMonthRatio();
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: ivMonthToMonthValue3,
                              validator: (v) {
                                if (v.trim().isEmpty) return 'Please fill this field';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Month 3: $_consistencyMonth3",
                              ),
                              onChanged: (val) {
                                calculateConsistencyMonthToMonthRatio();
                              },
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: ivMonthToMonthValueLastMonth,
                              validator: (v) {
                                if (v.trim().isEmpty) return 'Please fill this field';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Last month: $_consistencyCurrentMonth",
                              ),
                              onChanged: (val) {
                                calculateConsistencyMonthToMonthRatio();
                              },
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Consistency ratio'),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              enabled: false,
                              controller: ivMonthToMonthRatio,
                              onChanged: (val) {
                                calculateConsistencyMonthToMonthRatio();
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
                              controller: ivMonthToMonthRatioComment,
                              decoration: const InputDecoration(
                                labelText: "Comment",
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: _reasonForDiscrepanciesIv(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              controller: ivReasonForDiscrepancyComment,
                              decoration: const InputDecoration(
                                labelText: "Comment",
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Other reason (specify)'),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              controller: ivOtherReasonForDiscrepancy,
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
                              controller: ivOtherReasonForDiscrepancyComment,
                              decoration: const InputDecoration(
                                labelText: "Comment",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ])
            : SizedBox.shrink());
  }

  Widget _crossCheckForm() {
    return Form(
        key: _crosscheckformkey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _crossCheckPrimary1 != 'Null [Cross check 1 is not well configured]'
              ? Container(
                  child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('A - $_crossCheckPrimary1 : $_crossCheckSecondary1)', // Source doc 1 : Source doc 2
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('1. Number of cases sampled from the $_crossCheckPrimary1'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiiaCasesSimpledFromPrimary,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            int val1 = iiiaCasesSimpledFromPrimary.text != '' ? int.parse(iiiaCasesSimpledFromPrimary.text) : 0;
                            int val2 = iiiaCorrespondingMachingInSecondary.text != '' ? int.parse(iiiaCorrespondingMachingInSecondary.text) : 0;
                            iiiaSecondaryReliabilityRate.text = val1 != 0 ? (val2 / val1).toStringAsFixed(2) : '';
                          },
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
                          controller: iiiaPrimaryComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            '2. How many of the patients selected had a corresponding entry with matching information for the patients in the $_crossCheckSecondary1'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiiaCorrespondingMachingInSecondary,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            int val1 = iiiaCasesSimpledFromPrimary.text != '' ? int.parse(iiiaCasesSimpledFromPrimary.text) : 0;
                            int val2 = iiiaCorrespondingMachingInSecondary.text != '' ? int.parse(iiiaCorrespondingMachingInSecondary.text) : 0;
                            iiiaSecondaryReliabilityRate.text = val1 != 0 ? (val2 / val1).toStringAsFixed(2) : '';
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
                          controller: iiiaSecondaryComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('$_crossCheckSecondary1 reliability rate'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: iiiaSecondaryReliabilityRate,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          controller: iiiaReliabilityComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                ]))
              : SizedBox.shrink(),
          Divider(),
          _crossCheckPrimary2 != 'Null [Cross check 2 is not well configured]'
              ? Container(
                  child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('B - $_crossCheckPrimary2 : $_crossCheckSecondary2)', // Source doc 1 : Source doc 2
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('1. Number of cases sampled from the $_crossCheckPrimary2'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiibCasesSimpledFromPrimary,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            int val1 = iiibCasesSimpledFromPrimary.text != '' ? int.parse(iiibCasesSimpledFromPrimary.text) : 0;
                            int val2 = iiibCorrespondingMachingInSecondary.text != '' ? int.parse(iiibCorrespondingMachingInSecondary.text) : 0;
                            iiibSecondaryReliabilityRate.text = val1 != 0 ? (val2 / val1).toStringAsFixed(2) : '';
                          },
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
                          controller: iiibPrimaryComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            '2. How many of the patients selected had a corresponding entry with matching information for the patients in the $_crossCheckSecondary2'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiibCorrespondingMachingInSecondary,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            int val1 = iiibCasesSimpledFromPrimary.text != '' ? int.parse(iiibCasesSimpledFromPrimary.text) : 0;
                            int val2 = iiibCorrespondingMachingInSecondary.text != '' ? int.parse(iiibCorrespondingMachingInSecondary.text) : 0;
                            iiibSecondaryReliabilityRate.text = val1 != 0 ? (val2 / val1).toStringAsFixed(2) : '';
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          controller: iiibSecondaryComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('$_crossCheckSecondary2 reliability rate'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: iiibSecondaryReliabilityRate,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          controller: iiibReliabilityComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                ]))
              : SizedBox.shrink(),
          Divider(),
          _crossCheckPrimary3 != 'Null [Cross check 3 is not well configured]'
              ? Container(
                  child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('C - $_crossCheckPrimary3 : $_crossCheckSecondary3)', // Source doc 1 : Source doc 2
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Number of units (e.g. doses of medication/vaccine, other commodities) in stock at the site at the beginning of the reporting period (initial in stock) (a)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiicInitialStock,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            calculateCrossCheckCVr();
                          },
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
                          controller: iiicInitialStockComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Number of units received by the site during the reporting period (b)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiicReceivedStock,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            calculateCrossCheckCVr();
                          },
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
                          controller: iiicReceivedStockComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Number of units in stock at the site at the end of the reporting period (closing in stock) (c)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiicClosingStock,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            calculateCrossCheckCVr();
                          },
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
                          controller: iiicClosingStockComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Number of units used (e.g. given to patients) by the site during the reporting period (d)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: iiicUsedStock,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Please fill this field';
                            return null;
                          },
                          onChanged: (val) {
                            calculateCrossCheckCVr();
                          },
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
                          controller: iiicUsedStockComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Verification ratio:   (d/[a+b-c])'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: false,
                          controller: iiicRatio,
                          onChanged: (val) {
                            calculateCrossCheckCVr();
                          },
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
                          controller: iiicRatioComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: _reasonForDiscrepanciesC(),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: iiicReasonForDiscrepancyComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Other reason (specify)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: iiicOtherReasonForDiscrepancy,
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
                          controller: iiicOtherReasonForDiscrepancyComment,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                          ),
                        ),
                      )
                    ],
                  ),
                ]))
              : SizedBox.shrink(),
        ]));
  }

  Widget _systemAssessmentForm() {
    return Form(
        key: _systemassessmentformkey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Expanded(
                  child: Text('V.1: Is there a designated person to enter data and compile reports?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(1),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV1Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.2: Is there a designated person to review the quality of compiled data prior to submission to the next level?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(2),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV2Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.3: Does the health facility have written guidelines on data collection and reporting for malaria?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(3),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV3Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.4: Does the health facility have a reserve stock of blank registers or reporting forms?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(4),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV4Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.5: Has this health facility experienced any stock out of registers or reporting forms (since last visit)?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(5),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV5Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.6: Is a standardized register being used to record information on malaria cases (not improvised forms)?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(6),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV6Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.7: Can a patients malaria diagnosis and treatment history be easily found in the facility records?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(7),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV7Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.8: Are data archives properly maintained with historical patient level (registers) and aggregate (monthly report)'
                      ' results?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(8),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: vQuestionV8Comment,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.9: Does the facility maintain accurate demographic information for the catchment area (that is, a record current'
                      ' population and the number of births and deaths)?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(9),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    controller: vQuestionV9Comment,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.10: Does the facility have established targets to monitor progress towards goals and objectives for malaria '
                      'prevention and treatment?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(10),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    controller: vQuestionV10Comment,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.11: Does the facility have an up-to-date display (for example, a chart on the wall) of the number of malaria cases'
                      ' diagnosed and treated by reporting period for the year?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(11),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    controller: vQuestionV11Comment,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('V.12: Is there a chart of disease incidence by month displayed at the facility?'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _yesNoSelectV(12),
                ),
                Flexible(
                  flex: 8,
                  child: TextFormField(
                    controller: vQuestionV12Comment,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    enabled: false,
                    controller: systemReadiness,
                    decoration: const InputDecoration(
                      labelText: "System readiness",
                    ),
                  ),
                ),
              ],
            ),
          ]))
        ]));
  }

  Future<void> _fillForms() async {
    if (_sectionsNumbers.contains(1)) {
      await _fillCompletenessFields();
      await _fillTimelinessFields();
      await _fillDataElementCompletenessFields();
      await _fillSourceDocumentCompletenessFields();
    }
    if (_sectionsNumbers.contains(2)) await _fillDataAccuracyFields();
    if (_sectionsNumbers.contains(3)) await _fillCrossCheckFields();
    if (_sectionsNumbers.contains(4)) await _fillConsistencyOverTimeFields();
    if (_sectionsNumbers.contains(5)) await _fillSystemAssessmentFields();
  }

  Future<void> _pushStepOne() async {
    await _pushCompletenessForm();
    await _pushTimelinessForm();
    await _pushDeComplenessForm();
    await _pushSourceDocumentComplenessForm();
  }

  Future<void> _pushStepTwo() async {
    await _pushDataAccuracyForm();
  }

  Future<void> _pushStepThree() async {
    await _pushCrossCheckForm();
  }

  Future<void> _pushStepFour() async {
    await _pushConsistencyOverTimeForm();
  }

  Future<void> _pushStepFive() async {
    await _pushSystemAssesmentForm();
  }

  Widget _yesNoSelectV(int yesNoController) {
    List<Map<String, dynamic>> dropItems = [
      {'value': "0", 'label': 'No'},
      {'value': "1", 'label': 'Yes'}
    ];

    return Container(
      child: SelectFormField(
        controller: (yesNoController == 1)
            ? vQuestionV1
            : (yesNoController == 2)
                ? vQuestionV2
                : (yesNoController == 3)
                    ? vQuestionV3
                    : (yesNoController == 4)
                        ? vQuestionV4
                        : (yesNoController == 5)
                            ? vQuestionV5
                            : (yesNoController == 6)
                                ? vQuestionV6
                                : (yesNoController == 7)
                                    ? vQuestionV7
                                    : (yesNoController == 8)
                                        ? vQuestionV8
                                        : (yesNoController == 9)
                                            ? vQuestionV9
                                            : (yesNoController == 10)
                                                ? vQuestionV10
                                                : (yesNoController == 11)
                                                    ? vQuestionV11
                                                    : vQuestionV12,
        type: SelectFormFieldType.dropdown,
        items: dropItems,
        onChanged: (value) {
          calculateSystemReadiness();
        },
        // validator: (value) {
        //   if (value.isEmpty) {
        //     return 'Please select this field';
        //   }
        //   return null;
        // },
      ),
    );
  }

  Widget _yesNoSelectIb(int yesNoController) {
    List<Map<String, dynamic>> dropItems = [
      {'value': "0", 'label': 'No'},
      {'value': "1", 'label': 'Yes'}
    ];
    return Container(
      child: SelectFormField(
        labelText: (yesNoController == 1)
            ? _dataAccuracyMonth1
            : (yesNoController == 2)
                ? _dataAccuracyMonth2
                : _dataAccuracyMonth3,
        controller: (yesNoController == 1)
            ? ibSubmittedMonth1
            : (yesNoController == 2)
                ? ibSubmittedMonth2
                : ibSubmittedMonth3,
        type: SelectFormFieldType.dropdown,
        hintText: 'None',
        items: dropItems,
        onChanged: (value) {
          setState(() {
            calculateTimeliness();
          });
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Please select this field';
          }
          return null;
        },
      ),
    );
  }

  Widget _yesNoSelectIdAvailable(int yesNoController) {
    List<Map<String, dynamic>> dropItems = [
      {'value': "0", 'label': 'No'},
      {'value': "1", 'label': 'Yes'}
    ];

    return Container(
      child: SelectFormField(
        labelText: 'Available',
        controller: (yesNoController == 1)
            ? id1Availabe
            : (yesNoController == 2)
                ? id2Availabe
                : (yesNoController == 3)
                    ? id3Availabe
                    : (yesNoController == 4)
                        ? id4Availabe
                        : (yesNoController == 5)
                            ? id5Availabe
                            : (yesNoController == 6)
                                ? id6Availabe
                                : id7Availabe,
        type: SelectFormFieldType.dropdown,
        items: dropItems,
        onChanged: (value) {
          setState(() {
            calculateSourceDocumentAvailabe();
          });
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Please select this field';
          }
          return null;
        },
      ),
    );
  }

  Widget _yesNoSelectIdUpToDate(int yesNoController) {
    List<Map<String, dynamic>> dropItems = [
      {'value': "0", 'label': 'No'},
      {'value': "1", 'label': 'Yes'}
    ];

    return Container(
      child: SelectFormField(
        labelText: 'Up-to-date',
        controller: (yesNoController == 1)
            ? id1UpToDate
            : (yesNoController == 2)
                ? id2UpToDate
                : (yesNoController == 3)
                    ? id3UpToDate
                    : (yesNoController == 4)
                        ? id4UpToDate
                        : (yesNoController == 5)
                            ? id5UpToDate
                            : (yesNoController == 6)
                                ? id6UpToDate
                                : id7UpToDate,
        type: SelectFormFieldType.dropdown,
        items: dropItems,
        onChanged: (value) {
          setState(() {
            calculateSourceDocumentUpToDate();
          });
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Please select this field';
          }
          return null;
        },
      ),
    );
  }

  Widget _yesNoSelectIdStandard(int yesNoController) {
    List<Map<String, dynamic>> dropItems = [
      {'value': "0", 'label': 'No'},
      {'value': "1", 'label': 'Yes'}
    ];

    return Container(
      child: SelectFormField(
        labelText: 'Standard form',
        controller: (yesNoController == 1)
            ? id1StandardForm
            : (yesNoController == 2)
                ? id2StandardForm
                : (yesNoController == 3)
                    ? id3StandardForm
                    : (yesNoController == 4)
                        ? id4StandardForm
                        : (yesNoController == 5)
                            ? id5StandardForm
                            : (yesNoController == 6)
                                ? id6StandardForm
                                : id7StandardForm,
        type: SelectFormFieldType.dropdown,
        items: dropItems,
        onChanged: (value) {
          setState(() {
            calculateSourceDocumentStandard();
          });
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Please select this field';
          }
          return null;
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies11() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii1DiscrepanciesMonth1,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii1DiscrepanciesMonth1 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies12() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii1DiscrepanciesMonth2,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii1DiscrepanciesMonth2 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies13() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii1DiscrepanciesMonth3,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii1DiscrepanciesMonth3 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies21() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii2DiscrepanciesMonth1,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii2DiscrepanciesMonth1 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies22() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii2DiscrepanciesMonth2,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii2DiscrepanciesMonth2 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies23() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii2DiscrepanciesMonth3,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii2DiscrepanciesMonth3 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies31() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii3DiscrepanciesMonth1,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii3DiscrepanciesMonth1 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies32() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii3DiscrepanciesMonth2,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii3DiscrepanciesMonth2 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepancies33() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ii3DiscrepanciesMonth3,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ii3DiscrepanciesMonth3 = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepanciesC() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: iiicReasonForDiscrepancy,
        onSaved: (value) {
          // if (value == null) return;
          setState(() {
            iiicReasonForDiscrepancy = value;
          });
        },
      ),
    );
  }

  Widget _reasonForDiscrepanciesIv() {
    return Container(
      padding: EdgeInsets.all(16),
      child: MultiSelectFormField(
        autovalidate: AutovalidateMode.disabled,
        title: Text('Reasons for discrepancy'),
        dataSource: _discrepancyItems,
        textField: 'display',
        valueField: 'value',
        okButtonLabel: 'OK',
        cancelButtonLabel: 'CANCEL',
        // required: true,
        hintWidget: Text('Please choose one or more'),
        initialValue: ivReasonForDiscrepancy,
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            ivReasonForDiscrepancy = value;
          });
        },
      ),
    );
  }

  // Indicators calculation
  void calculateSystemReadiness() {
    int denominator = 0;
    int question1, question2, question3, question4, question5, question6, question7, question8, question9, question10, question11, question12;
    if (vQuestionV1.text != '') {
      question1 = int.parse(vQuestionV1.text);
      denominator = denominator + 1;
    } else {
      question1 = 0;
    }
    if (vQuestionV2.text != '') {
      question2 = int.parse(vQuestionV2.text);
      denominator = denominator + 1;
    } else {
      question2 = 0;
    }
    if (vQuestionV3.text != '') {
      question3 = int.parse(vQuestionV3.text);
      denominator = denominator + 1;
    } else {
      question3 = 0;
    }
    if (vQuestionV4.text != '') {
      question4 = int.parse(vQuestionV4.text);
      denominator = denominator + 1;
    } else {
      question4 = 0;
    }
    if (vQuestionV5.text != '') {
      question5 = int.parse(vQuestionV5.text);
      denominator = denominator + 1;
    } else {
      question5 = 0;
    }
    if (vQuestionV6.text != '') {
      question6 = int.parse(vQuestionV6.text);
      denominator = denominator + 1;
    } else {
      question6 = 0;
    }
    if (vQuestionV7.text != '') {
      question7 = int.parse(vQuestionV7.text);
      denominator = denominator + 1;
    } else {
      question7 = 0;
    }
    if (vQuestionV8.text != '') {
      question8 = int.parse(vQuestionV8.text);
      denominator = denominator + 1;
    } else {
      question8 = 0;
    }
    if (vQuestionV9.text != '') {
      question9 = int.parse(vQuestionV9.text);
      denominator = denominator + 1;
    } else {
      question9 = 0;
    }
    if (vQuestionV10.text != '') {
      question10 = int.parse(vQuestionV10.text);
      denominator = denominator + 1;
    } else {
      question10 = 0;
    }
    if (vQuestionV11.text != '') {
      question11 = int.parse(vQuestionV11.text);
      denominator = denominator + 1;
    } else {
      question11 = 0;
    }
    if (vQuestionV12.text != '') {
      question12 = int.parse(vQuestionV12.text);
      denominator = denominator + 1;
    } else {
      question12 = 0;
    }

    systemReadiness.text = denominator != 0
        ? (((question1 +
                        question2 +
                        question3 +
                        question4 +
                        question5 +
                        question6 +
                        question7 +
                        question8 +
                        question9 +
                        question10 +
                        question11 +
                        question12) /
                    denominator) *
                100)
            .toStringAsFixed(2)
        : '';
  }

  calculateDataAccuracyMonthlyVf1Month1() {
    int num = ii1SourceDocumentRecount1.text != '' ? int.parse(ii1SourceDocumentRecount1.text) : 0;
    int den = ii1HmisMonthlyReportValue1.text != '' ? int.parse(ii1HmisMonthlyReportValue1.text) : 0;
    ii1MonthlyReportVf1.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf1Month1() {
    int num = ii1SourceDocumentRecount1.text != '' ? int.parse(ii1SourceDocumentRecount1.text) : 0;
    int den = ii1DhisMonthlyValue1.text != '' ? int.parse(ii1DhisMonthlyValue1.text) : 0;
    ii1DhisVf1.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf1Month2() {
    int num = ii1SourceDocumentRecount2.text != '' ? int.parse(ii1SourceDocumentRecount2.text) : 0;
    int den = ii1HmisMonthlyReportValue2.text != '' ? int.parse(ii1HmisMonthlyReportValue2.text) : 0;
    ii1MonthlyReportVf2.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf1Month2() {
    int num = ii1SourceDocumentRecount2.text != '' ? int.parse(ii1SourceDocumentRecount2.text) : 0;
    int den = ii1DhisMonthlyValue2.text != '' ? int.parse(ii1DhisMonthlyValue2.text) : 0;
    ii1DhisVf2.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf1Month3() {
    int num = ii1SourceDocumentRecount3.text != '' ? int.parse(ii1SourceDocumentRecount3.text) : 0;
    int den = ii1HmisMonthlyReportValue3.text != '' ? int.parse(ii1HmisMonthlyReportValue3.text) : 0;
    ii1MonthlyReportVf3.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf1Month3() {
    int num = ii1SourceDocumentRecount3.text != '' ? int.parse(ii1SourceDocumentRecount3.text) : 0;
    int den = ii1DhisMonthlyValue3.text != '' ? int.parse(ii1DhisMonthlyValue3.text) : 0;
    ii1DhisVf3.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf2Month1() {
    int num = ii2SourceDocumentRecount1.text != '' ? int.parse(ii2SourceDocumentRecount1.text) : 0;
    int den = ii2HmisMonthlyReportValue1.text != '' ? int.parse(ii2HmisMonthlyReportValue1.text) : 0;
    ii2MonthlyReportVf1.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf2Month1() {
    int num = ii2SourceDocumentRecount1.text != '' ? int.parse(ii2SourceDocumentRecount1.text) : 0;
    int den = ii2DhisMonthlyValue1.text != '' ? int.parse(ii2DhisMonthlyValue1.text) : 0;
    ii2DhisVf1.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf2Month2() {
    int num = ii2SourceDocumentRecount2.text != '' ? int.parse(ii2SourceDocumentRecount2.text) : 0;
    int den = ii2HmisMonthlyReportValue2.text != '' ? int.parse(ii2HmisMonthlyReportValue2.text) : 0;
    ii2MonthlyReportVf2.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf2Month2() {
    int num = ii2SourceDocumentRecount2.text != '' ? int.parse(ii2SourceDocumentRecount2.text) : 0;
    int den = ii2DhisMonthlyValue2.text != '' ? int.parse(ii2DhisMonthlyValue2.text) : 0;
    ii2DhisVf2.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf2Month3() {
    int num = ii2SourceDocumentRecount3.text != '' ? int.parse(ii2SourceDocumentRecount3.text) : 0;
    int den = ii2HmisMonthlyReportValue3.text != '' ? int.parse(ii2HmisMonthlyReportValue3.text) : 0;
    ii2MonthlyReportVf3.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf2Month3() {
    int num = ii2SourceDocumentRecount3.text != '' ? int.parse(ii2SourceDocumentRecount3.text) : 0;
    int den = ii2DhisMonthlyValue3.text != '' ? int.parse(ii2DhisMonthlyValue3.text) : 0;
    ii2DhisVf3.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf3Month1() {
    int num = ii3SourceDocumentRecount1.text != '' ? int.parse(ii3SourceDocumentRecount1.text) : 0;
    int den = ii3HmisMonthlyReportValue1.text != '' ? int.parse(ii3HmisMonthlyReportValue1.text) : 0;
    ii3MonthlyReportVf1.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf3Month1() {
    int num = ii3SourceDocumentRecount1.text != '' ? int.parse(ii3SourceDocumentRecount1.text) : 0;
    int den = ii3DhisMonthlyValue1.text != '' ? int.parse(ii3DhisMonthlyValue1.text) : 0;
    ii3DhisVf1.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf3Month2() {
    int num = ii3SourceDocumentRecount2.text != '' ? int.parse(ii3SourceDocumentRecount2.text) : 0;
    int den = ii3HmisMonthlyReportValue2.text != '' ? int.parse(ii3HmisMonthlyReportValue2.text) : 0;
    ii3MonthlyReportVf2.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf3Month2() {
    int num = ii3SourceDocumentRecount2.text != '' ? int.parse(ii3SourceDocumentRecount2.text) : 0;
    int den = ii3DhisMonthlyValue2.text != '' ? int.parse(ii3DhisMonthlyValue2.text) : 0;
    ii3DhisVf2.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyMonthlyVf3Month3() {
    int num = ii3SourceDocumentRecount3.text != '' ? int.parse(ii3SourceDocumentRecount3.text) : 0;
    int den = ii3HmisMonthlyReportValue3.text != '' ? int.parse(ii3HmisMonthlyReportValue3.text) : 0;
    ii3MonthlyReportVf3.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  calculateDataAccuracyDhis2Vf3Month3() {
    int num = ii3SourceDocumentRecount3.text != '' ? int.parse(ii3SourceDocumentRecount3.text) : 0;
    int den = ii3DhisMonthlyValue3.text != '' ? int.parse(ii3DhisMonthlyValue3.text) : 0;
    ii3DhisVf3.text = den != 0 ? (num / den).toStringAsFixed(2) : '';
  }

  void calculateCompleteness() {
    int expected = iaExpectedCells.text != '' ? int.parse(iaExpectedCells.text) : 0;
    int completed = iaCompletedCells.text != '' ? int.parse(iaCompletedCells.text) : 0;
    iaPercent.text = expected != 0 ? ((completed / expected) * 100).toStringAsFixed(2) : '';
  }

  void calculateConsistencyAnnualRatio() {
    int val1 = ivCurrentMonthValue.text != '' ? int.parse(ivCurrentMonthValue.text) : 0;
    int val2 = ivCurrentMonthYearAgoValue.text != '' ? int.parse(ivCurrentMonthYearAgoValue.text) : 0;
    ivAnnualRatio.text = val2 != 0 ? (val1 / val2).toStringAsFixed(2) : '';
  }

  void calculateConsistencyMonthToMonthRatio() {
    int val1 = ivMonthToMonthValue1.text != '' ? int.parse(ivMonthToMonthValue1.text) : 0;
    int val2 = ivMonthToMonthValue2.text != '' ? int.parse(ivMonthToMonthValue2.text) : 0;
    int val3 = ivMonthToMonthValue3.text != '' ? int.parse(ivMonthToMonthValue3.text) : 0;
    int val4 = ivMonthToMonthValueLastMonth.text != '' ? int.parse(ivMonthToMonthValueLastMonth.text) : 0;
    ivMonthToMonthRatio.text = (val1 + val2 + val3) != 0 ? (val4 / ((val1 + val2 + val3) / 3)).toStringAsFixed(2) : '';
  }

  void calculateCrossCheckCVr() {
    int val1 = iiicInitialStock.text != '' ? int.parse(iiicInitialStock.text) : 0;
    int val2 = iiicReceivedStock.text != '' ? int.parse(iiicReceivedStock.text) : 0;
    int val3 = iiicClosingStock.text != '' ? int.parse(iiicClosingStock.text) : 0;
    int val4 = iiicUsedStock.text != '' ? int.parse(iiicUsedStock.text) : 0;
    iiicRatio.text = (val1 + val2 - val3) != 0 ? (val4 / (val1 + val2 - val3)).toStringAsFixed(2) : '0';
  }

  void calculateTimeliness() {
    int month1 = ibSubmittedMonth1.text != '' ? int.parse(ibSubmittedMonth1.text) : 0;
    int month2 = ibSubmittedMonth2.text != '' ? int.parse(ibSubmittedMonth2.text) : 0;
    int month3 = ibSubmittedMonth3.text != '' ? int.parse(ibSubmittedMonth3.text) : 0;
    ibPercent.text = (((month1 + month2 + month3) / 3) * 100).toStringAsFixed(2);
  }

  void calculateSourceDocumentAvailabe() {
    int available1 = id1Availabe.text != '' ? int.parse(id1Availabe.text) : 0;
    int available2 = id2Availabe.text != '' ? int.parse(id2Availabe.text) : 0;
    int available3 = id3Availabe.text != '' ? int.parse(id3Availabe.text) : 0;
    int available4 = id4Availabe.text != '' ? int.parse(id4Availabe.text) : 0;
    int available5 = id5Availabe.text != '' ? int.parse(id5Availabe.text) : 0;
    int available6 = id6Availabe.text != '' ? int.parse(id6Availabe.text) : 0;
    int available7 = id7Availabe.text != '' ? int.parse(id7Availabe.text) : 0;

    id8Availabe.text =
        (((available1 + available2 + available3 + available4 + available5 + available6 + available7) / _sourceDocumentCompletenesses.length) * 100)
            .toStringAsFixed(2);
  }

  void calculateSourceDocumentUpToDate() {
    int available1 = id1UpToDate.text != '' ? int.parse(id1UpToDate.text) : 0;
    int available2 = id2UpToDate.text != '' ? int.parse(id2UpToDate.text) : 0;
    int available3 = id3UpToDate.text != '' ? int.parse(id3UpToDate.text) : 0;
    int available4 = id4UpToDate.text != '' ? int.parse(id4UpToDate.text) : 0;
    int available5 = id5UpToDate.text != '' ? int.parse(id5UpToDate.text) : 0;
    int available6 = id6UpToDate.text != '' ? int.parse(id6UpToDate.text) : 0;
    int available7 = id7UpToDate.text != '' ? int.parse(id7UpToDate.text) : 0;

    id8UpToDate.text =
        (((available1 + available2 + available3 + available4 + available5 + available6 + available7) / _sourceDocumentCompletenesses.length) * 100)
            .toStringAsFixed(2);
  }

  void calculateSourceDocumentStandard() {
    int available1 = id1StandardForm.text != '' ? int.parse(id1StandardForm.text) : 0;
    int available2 = id2StandardForm.text != '' ? int.parse(id2StandardForm.text) : 0;
    int available3 = id3StandardForm.text != '' ? int.parse(id3StandardForm.text) : 0;
    int available4 = id4StandardForm.text != '' ? int.parse(id4StandardForm.text) : 0;
    int available5 = id5StandardForm.text != '' ? int.parse(id5StandardForm.text) : 0;
    int available6 = id6StandardForm.text != '' ? int.parse(id6StandardForm.text) : 0;
    int available7 = id7StandardForm.text != '' ? int.parse(id7StandardForm.text) : 0;

    id8StandardForm.text =
        (((available1 + available2 + available3 + available4 + available5 + available6 + available7) / _sourceDocumentCompletenesses.length) * 100)
            .toStringAsFixed(2);
  }

  void calculateDataAccuracyRecountTotal1() {
    int source1 = ii1SourceDocumentRecount1.text != '' ? int.parse(ii1SourceDocumentRecount1.text) : 0;
    int source2 = ii1SourceDocumentRecount2.text != '' ? int.parse(ii1SourceDocumentRecount2.text) : 0;
    int source3 = ii1SourceDocumentRecount3.text != '' ? int.parse(ii1SourceDocumentRecount3.text) : 0;
    ii1SourceDocumentRecountTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyHmisTotal1() {
    int source1 = ii1HmisMonthlyReportValue1.text != '' ? int.parse(ii1HmisMonthlyReportValue1.text) : 0;
    int source2 = ii1HmisMonthlyReportValue2.text != '' ? int.parse(ii1HmisMonthlyReportValue2.text) : 0;
    int source3 = ii1HmisMonthlyReportValue3.text != '' ? int.parse(ii1HmisMonthlyReportValue3.text) : 0;
    ii1HmisMonthlyReportValueTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyDhisTotal1() {
    int source1 = ii1DhisMonthlyValue1.text != '' ? int.parse(ii1DhisMonthlyValue1.text) : 0;
    int source2 = ii1DhisMonthlyValue2.text != '' ? int.parse(ii1DhisMonthlyValue2.text) : 0;
    int source3 = ii1DhisMonthlyValue3.text != '' ? int.parse(ii1DhisMonthlyValue3.text) : 0;
    ii1DhisMonthlyValueTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyMonthlyVfTotal1() {
    int recount1 = ii1SourceDocumentRecount1.text != '' ? int.parse(ii1SourceDocumentRecount1.text) : 0;
    int recount2 = ii1SourceDocumentRecount2.text != '' ? int.parse(ii1SourceDocumentRecount2.text) : 0;
    int recount3 = ii1SourceDocumentRecount3.text != '' ? int.parse(ii1SourceDocumentRecount3.text) : 0;

    int value1 = ii1HmisMonthlyReportValue1.text != '' ? int.parse(ii1HmisMonthlyReportValue1.text) : 0;
    int value2 = ii1HmisMonthlyReportValue2.text != '' ? int.parse(ii1HmisMonthlyReportValue2.text) : 0;
    int value3 = ii1HmisMonthlyReportValue3.text != '' ? int.parse(ii1HmisMonthlyReportValue3.text) : 0;

    if (value1 != 0 && value2 != 0 && value3 != 0) {
      ii1MonthlyReportVfTotal.text = (((recount1 / value1) + (recount2 / value2) + (recount3 / value3)) / 3).toStringAsFixed(2);
    } else {
      ii1MonthlyReportVfTotal.text = '';
    }
  }

  void calculateDataAccuracyDhis2VfTotal1() {
    int recount1 = ii1SourceDocumentRecount1.text != '' ? int.parse(ii1SourceDocumentRecount1.text) : 0;
    int recount2 = ii1SourceDocumentRecount2.text != '' ? int.parse(ii1SourceDocumentRecount2.text) : 0;
    int recount3 = ii1SourceDocumentRecount3.text != '' ? int.parse(ii1SourceDocumentRecount3.text) : 0;

    int value1 = ii1DhisMonthlyValue1.text != '' ? int.parse(ii1DhisMonthlyValue1.text) : 0;
    int value2 = ii1DhisMonthlyValue2.text != '' ? int.parse(ii1DhisMonthlyValue2.text) : 0;
    int value3 = ii1DhisMonthlyValue3.text != '' ? int.parse(ii1DhisMonthlyValue3.text) : 0;

    if (value1 != 0 && value2 != 0 && value3 != 0) {
      ii1DhisVfTotal.text = (((recount1 / value1) + (recount2 / value2) + (recount3 / value3)) / 3).toStringAsFixed(2);
    } else {
      ii1DhisVfTotal.text = '';
    }
  }

  void calculateDataAccuracyRecountTotal2() {
    int source1 = ii2SourceDocumentRecount1.text != '' ? int.parse(ii2SourceDocumentRecount1.text) : 0;
    int source2 = ii2SourceDocumentRecount2.text != '' ? int.parse(ii2SourceDocumentRecount2.text) : 0;
    int source3 = ii2SourceDocumentRecount3.text != '' ? int.parse(ii2SourceDocumentRecount3.text) : 0;
    ii2SourceDocumentRecountTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyHmisTotal2() {
    int source1 = ii2HmisMonthlyReportValue1.text != '' ? int.parse(ii2HmisMonthlyReportValue1.text) : 0;
    int source2 = ii2HmisMonthlyReportValue2.text != '' ? int.parse(ii2HmisMonthlyReportValue2.text) : 0;
    int source3 = ii2HmisMonthlyReportValue3.text != '' ? int.parse(ii2HmisMonthlyReportValue3.text) : 0;
    ii2HmisMonthlyReportValueTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyDhisTotal2() {
    int source1 = ii2DhisMonthlyValue1.text != '' ? int.parse(ii2DhisMonthlyValue1.text) : 0;
    int source2 = ii2DhisMonthlyValue2.text != '' ? int.parse(ii2DhisMonthlyValue2.text) : 0;
    int source3 = ii2DhisMonthlyValue3.text != '' ? int.parse(ii2DhisMonthlyValue3.text) : 0;
    ii2DhisMonthlyValueTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyMonthlyVfTotal2() {
    int recount1 = ii2SourceDocumentRecount1.text != '' ? int.parse(ii2SourceDocumentRecount1.text) : 0;
    int recount2 = ii2SourceDocumentRecount2.text != '' ? int.parse(ii2SourceDocumentRecount2.text) : 0;
    int recount3 = ii2SourceDocumentRecount3.text != '' ? int.parse(ii2SourceDocumentRecount3.text) : 0;

    int value1 = ii2HmisMonthlyReportValue1.text != '' ? int.parse(ii2HmisMonthlyReportValue1.text) : 0;
    int value2 = ii2HmisMonthlyReportValue2.text != '' ? int.parse(ii2HmisMonthlyReportValue2.text) : 0;
    int value3 = ii2HmisMonthlyReportValue3.text != '' ? int.parse(ii2HmisMonthlyReportValue3.text) : 0;

    if (value1 != 0 && value2 != 0 && value3 != 0) {
      ii2MonthlyReportVfTotal.text = (((recount1 / value1) + (recount2 / value2) + (recount3 / value3)) / 3).toStringAsFixed(2);
    } else {
      ii2MonthlyReportVfTotal.text = '';
    }
  }

  void calculateDataAccuracyDhis2VfTotal2() {
    int recount1 = ii2SourceDocumentRecount1.text != '' ? int.parse(ii2SourceDocumentRecount1.text) : 0;
    int recount2 = ii2SourceDocumentRecount2.text != '' ? int.parse(ii2SourceDocumentRecount2.text) : 0;
    int recount3 = ii2SourceDocumentRecount3.text != '' ? int.parse(ii2SourceDocumentRecount3.text) : 0;

    int value1 = ii2DhisMonthlyValue1.text != '' ? int.parse(ii2DhisMonthlyValue1.text) : 0;
    int value2 = ii2DhisMonthlyValue2.text != '' ? int.parse(ii2DhisMonthlyValue2.text) : 0;
    int value3 = ii2DhisMonthlyValue3.text != '' ? int.parse(ii2DhisMonthlyValue3.text) : 0;

    if (value1 != 0 && value2 != 0 && value3 != 0) {
      ii2DhisVfTotal.text = (((recount1 / value1) + (recount2 / value2) + (recount3 / value3)) / 3).toStringAsFixed(2);
    } else {
      ii2DhisVfTotal.text = '';
    }
  }

  void calculateDataAccuracyRecountTotal3() {
    int source1 = ii3SourceDocumentRecount1.text != '' ? int.parse(ii3SourceDocumentRecount1.text) : 0;
    int source2 = ii3SourceDocumentRecount2.text != '' ? int.parse(ii3SourceDocumentRecount2.text) : 0;
    int source3 = ii3SourceDocumentRecount3.text != '' ? int.parse(ii3SourceDocumentRecount3.text) : 0;
    ii3SourceDocumentRecountTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyHmisTotal3() {
    int source1 = ii3HmisMonthlyReportValue1.text != '' ? int.parse(ii3HmisMonthlyReportValue1.text) : 0;
    int source2 = ii3HmisMonthlyReportValue2.text != '' ? int.parse(ii3HmisMonthlyReportValue2.text) : 0;
    int source3 = ii3HmisMonthlyReportValue3.text != '' ? int.parse(ii3HmisMonthlyReportValue3.text) : 0;
    ii3HmisMonthlyReportValueTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyDhisTotal3() {
    int source1 = ii3DhisMonthlyValue1.text != '' ? int.parse(ii3DhisMonthlyValue1.text) : 0;
    int source2 = ii3DhisMonthlyValue2.text != '' ? int.parse(ii3DhisMonthlyValue2.text) : 0;
    int source3 = ii3DhisMonthlyValue3.text != '' ? int.parse(ii3DhisMonthlyValue3.text) : 0;
    ii3DhisMonthlyValueTotal.text = (source1 + source2 + source3).toString();
  }

  void calculateDataAccuracyMonthlyVfTotal3() {
    int recount1 = ii3SourceDocumentRecount1.text != '' ? int.parse(ii3SourceDocumentRecount1.text) : 0;
    int recount2 = ii3SourceDocumentRecount2.text != '' ? int.parse(ii3SourceDocumentRecount2.text) : 0;
    int recount3 = ii3SourceDocumentRecount3.text != '' ? int.parse(ii3SourceDocumentRecount3.text) : 0;

    int value1 = ii3HmisMonthlyReportValue1.text != '' ? int.parse(ii3HmisMonthlyReportValue1.text) : 0;
    int value2 = ii3HmisMonthlyReportValue2.text != '' ? int.parse(ii3HmisMonthlyReportValue2.text) : 0;
    int value3 = ii3HmisMonthlyReportValue3.text != '' ? int.parse(ii3HmisMonthlyReportValue3.text) : 0;

    if (value1 != 0 && value2 != 0 && value3 != 0) {
      ii3MonthlyReportVfTotal.text = (((recount1 / value1) + (recount2 / value2) + (recount3 / value3)) / 3).toStringAsFixed(2);
    } else {
      ii3MonthlyReportVfTotal.text = '';
    }
  }

  void calculateDataAccuracyDhis2VfTotal3() {
    int recount1 = ii3SourceDocumentRecount1.text != '' ? int.parse(ii3SourceDocumentRecount1.text) : 0;
    int recount2 = ii3SourceDocumentRecount2.text != '' ? int.parse(ii3SourceDocumentRecount2.text) : 0;
    int recount3 = ii3SourceDocumentRecount3.text != '' ? int.parse(ii3SourceDocumentRecount3.text) : 0;

    int value1 = ii3DhisMonthlyValue1.text != '' ? int.parse(ii3DhisMonthlyValue1.text) : 0;
    int value2 = ii3DhisMonthlyValue2.text != '' ? int.parse(ii3DhisMonthlyValue2.text) : 0;
    int value3 = ii3DhisMonthlyValue3.text != '' ? int.parse(ii3DhisMonthlyValue3.text) : 0;

    if (value1 != 0 && value2 != 0 && value3 != 0) {
      ii3DhisVfTotal.text = (((recount1 / value1) + (recount2 / value2) + (recount3 / value3)) / 3).toStringAsFixed(2);
    } else {
      ii3DhisVfTotal.text = '';
    }
  }

  Future<void> _getConfig() async {
    _periods = await configManager.getSupervisionConfig('period');
    _dataElements = await configManager.getSupervisionConfig('data_element');
    _indicators = await configManager.getSupervisionConfig('indicator');
    _sourceDocuments = await configManager.getSupervisionConfig('source_document');
    _sections = await configManager.getSupervisionConfig('section');
    configManager.getSupervisionConfig('entrydiscrepancy').then((value) {
      _discrepancies = value;
      for (var i = 0; i < value.length; i++) {
        _discrepancyItems.add({"display": value[i].description, "value": value[i].id});
      }
    });
    _facilities = await configManager.getSupervisionConfig('facility');
    configManager.getDataRowsBySupervision('supervisionfacilities', widget.selectedSupervision.id).then((value) {
      setState(() {
        //_supervisionFacilities = value;
        _selectedFacilities = MrdqaHelpers.getSelectedFacilities(_facilities, value);
      });
    });
    //supervisionData['supervision'] = _currentSupervision;
    //_plannedVisits = await configManager.getDataRowsBySupervision('visits', _supervisionId);
    _supervisionPeriods = await configManager.getDataRowsBySupervision('supervisionperiod', widget.selectedSupervision.id);
    _dataElementCompletenesses = await configManager.getDataRowsBySupervision('dataelementcompleteness', widget.selectedSupervision.id);
    _sourceDocumentCompletenesses = await configManager.getDataRowsBySupervision('sourcedocumentcompleteness', widget.selectedSupervision.id);
    _selectedIndicators = await configManager.getDataRowsBySupervision('selectedindicator', widget.selectedSupervision.id);
    _crossChecks = await configManager.getDataRowsBySupervision('crosscheck', widget.selectedSupervision.id);
    _consistencyOverTime = await configManager.getDataRowBySupervision('consistencyovertime', widget.selectedSupervision.id);
    if (widget.selectedSupervision.period.day < 20) {
      _consistencyCurrentMonth = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 2, 'period').description;
      _consistencyMonth3 = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 3, 'period').description;
      _consistencyMonth2 = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 4, 'period').description;
      _consistencyMonth1 = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 5, 'period').description;
    } else {
      _consistencyCurrentMonth = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 1, 'period').description;
      _consistencyMonth3 = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 2, 'period').description;
      _consistencyMonth2 = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 3, 'period').description;
      _consistencyMonth1 = MrdqaHelpers.getObjectByNumber(_periods, widget.selectedSupervision.period.month - 4, 'period').description;
    }
    _supervisionSections = await configManager.getDataRowsBySupervision('supervisionsection', widget.selectedSupervision.id);
    setState(() {});
  }

  Future<void> _fillCompletenessFields() async {
    configManager.getDataRowByFacilityAndSupervision('entrycompletenessmonthlyreport', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value.id != null) {
        setState(() {
          _entryCompletenessMonthlyReport = value;
          iaExpectedCells.text = value.expectedCells.toString();
          iaCompletedCells.text = value.completedCells.toString();
          iaPercent.text = value.percent.toString();
          iaComment.text = value.comment;
        });
      } else {
        setState(() {
          _entryCompletenessMonthlyReport = new EntryCompletenessMonthlyReport(id: 0);
          iaExpectedCells.text = '';
          iaCompletedCells.text = '';
          iaPercent.text = '';
          iaComment.text = '';
        });
      }
    });
  }

  Future<void> _fillTimelinessFields() async {
    configManager.getDataRowByFacilityAndSupervision('entrytimelinessmonthlyreport', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value.id != null) {
        _entryTimelinessMonthlyReport = value;
        setState(() {
          ibSubmittedMonth1?.text = value.submittedMonth1.toString();
          ibSubmittedMonth2.text = value.submittedMonth2.toString();
          ibSubmittedMonth3.text = value.submittedMonth3.toString();
          ibPercent.text = value.percent.toString();
          ibComment.text = value.comment;
        });
      } else {
        _entryTimelinessMonthlyReport = new EntryTimelinessMonthlyReport(id: 0);
        ibSubmittedMonth1.text = '';
        ibSubmittedMonth2.text = '';
        ibSubmittedMonth3.text = '';
        ibPercent.text = '';
        ibComment.text = '';
        setState(() {});
      }
    });
  }

  Future<void> _fillDataElementCompletenessFields() async {
    configManager.getDataRowsByFacilityAndSupervision('entrydataelementcompleteness', widget.selectedSupervision.id, _facilityId).then((value) {
      _entryDataElementCompletenessMap = {
        'entry1': new EntryDataElementCompleteness(id: 0),
        'entry2': new EntryDataElementCompleteness(id: 0),
        'entry3': new EntryDataElementCompleteness(id: 0),
        'entry4': new EntryDataElementCompleteness(id: 0),
        'entry5': new EntryDataElementCompleteness(id: 0),
        'entry6': new EntryDataElementCompleteness(id: 0),
        'missing': new EntryDataElementCompleteness(id: 0),
        'total': new EntryDataElementCompleteness(id: 0)
      };
      if (value != null && value.isNotEmpty && value.length > 0) {
        for (var i = 0; i < value.length; i++) {
          if (value[i].type == 'entry1') {
            setState(() {
              _entryDataElementCompletenessMap['entry1'].id = value[i].id;
              _entryDataElementCompletenessMap['entry1'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['entry1'].percent = value[i].percent;
              ic1missingCasesData.text = value[i].missingCasesData.toString();
              ic1Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'entry2') {
            setState(() {
              _entryDataElementCompletenessMap['entry2'].id = value[i].id;
              _entryDataElementCompletenessMap['entry2'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['entry2'].percent = value[i].percent;
              ic2missingCasesData.text = value[i].missingCasesData.toString();
              ic2Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'entry3') {
            setState(() {
              _entryDataElementCompletenessMap['entry3'].id = value[i].id;
              _entryDataElementCompletenessMap['entry3'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['entry3'].percent = value[i].percent;
              ic3missingCasesData.text = value[i].missingCasesData.toString();
              ic3Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'entry4') {
            setState(() {
              _entryDataElementCompletenessMap['entry4'].id = value[i].id;
              _entryDataElementCompletenessMap['entry4'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['entry4'].percent = value[i].percent;
              ic4missingCasesData.text = value[i].missingCasesData.toString();
              ic4Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'entry5') {
            setState(() {
              _entryDataElementCompletenessMap['entry5'].id = value[i].id;
              _entryDataElementCompletenessMap['entry5'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['entry5'].percent = value[i].percent;
              ic5missingCasesData.text = value[i].missingCasesData.toString();
              ic5Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'entry6') {
            setState(() {
              _entryDataElementCompletenessMap['entry6'].id = value[i].id;
              _entryDataElementCompletenessMap['entry6'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['entry6'].percent = value[i].percent;
              ic6missingCasesData.text = value[i].missingCasesData.toString();
              ic6Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'missing') {
            setState(() {
              _entryDataElementCompletenessMap['missing'].id = value[i].id;
              _entryDataElementCompletenessMap['missing'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['missing'].percent = value[i].percent;
              ic7missingCasesData.text = value[i].missingCasesData.toString();
              ic7Percent.text = value[i].percent.toString();
            });
          } else if (value[i].type == 'total') {
            setState(() {
              _entryDataElementCompletenessMap['total'].id = value[i].id;
              _entryDataElementCompletenessMap['total'].missingCasesData = value[i].missingCasesData;
              _entryDataElementCompletenessMap['total'].percent = value[i].percent;
              ic8missingCasesData.text = value[i].missingCasesData.toString();
              ic8Percent.text = value[i].percent.toString();
            });
          }
        }
      } else {
        setState(() {
          ic1missingCasesData.text = '';
          ic1Percent.text = '';
          ic2missingCasesData.text = '';
          ic2Percent.text = '';
          ic3missingCasesData.text = '';
          ic3Percent.text = '';
          ic4missingCasesData.text = '';
          ic4Percent.text = '';
          ic5missingCasesData.text = '';
          ic5Percent.text = '';
          ic6missingCasesData.text = '';
          ic6Percent.text = '';
          ic7missingCasesData.text = '';
          ic7Percent.text = '';
          ic8missingCasesData.text = '';
          ic8Percent.text = '';
        });
      }
    });
  }

  Future<void> _fillSourceDocumentCompletenessFields() async {
    configManager.getDataRowsByFacilityAndSupervision('entrysourcedocumentcompleteness', widget.selectedSupervision.id, _facilityId).then((value) {
      _entrySourceDocumentCompletenessMap = {
        'entry1': new EntrySourceDocumentCompleteness(id: 0),
        'entry2': new EntrySourceDocumentCompleteness(id: 0),
        'entry3': new EntrySourceDocumentCompleteness(id: 0),
        'entry4': new EntrySourceDocumentCompleteness(id: 0),
        'entry5': new EntrySourceDocumentCompleteness(id: 0),
        'entry6': new EntrySourceDocumentCompleteness(id: 0),
        'entry7': new EntrySourceDocumentCompleteness(id: 0),
        'result': new EntrySourceDocumentCompleteness(id: 0)
      };
      if (value != null && value.isNotEmpty && value.length > 0) {
        for (var i = 0; i < value.length; i++) {
          if (value[i].type == 'entry1') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry1'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry1'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry1'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry1'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry1'].comment = value[i].comment;
              id1Availabe.text = value[i].available.toString();
              id1UpToDate.text = value[i].upToDate.toString();
              id1StandardForm.text = value[i].standardForm.toString();
              id1Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'entry2') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry2'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry2'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry2'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry2'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry2'].comment = value[i].comment;
              id2Availabe.text = value[i].available.toString();
              id2UpToDate.text = value[i].upToDate.toString();
              id2StandardForm.text = value[i].standardForm.toString();
              id2Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'entry3') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry3'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry3'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry3'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry3'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry3'].comment = value[i].comment;
              id3Availabe.text = value[i].available.toString();
              id3UpToDate.text = value[i].upToDate.toString();
              id3StandardForm.text = value[i].standardForm.toString();
              id3Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'entry4') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry4'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry4'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry4'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry4'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry4'].comment = value[i].comment;
              id4Availabe.text = value[i].available.toString();
              id4UpToDate.text = value[i].upToDate.toString();
              id4StandardForm.text = value[i].standardForm.toString();
              id4Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'entry5') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry5'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry5'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry5'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry5'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry5'].comment = value[i].comment;
              id5Availabe.text = value[i].available.toString();
              id5UpToDate.text = value[i].upToDate.toString();
              id5StandardForm.text = value[i].standardForm.toString();
              id5Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'entry6') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry6'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry6'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry6'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry6'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry6'].comment = value[i].comment;
              id6Availabe.text = value[i].available.toString();
              id6UpToDate.text = value[i].upToDate.toString();
              id6StandardForm.text = value[i].standardForm.toString();
              id6Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'entry7') {
            setState(() {
              _entrySourceDocumentCompletenessMap['entry7'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['entry7'].available = value[i].available;
              _entrySourceDocumentCompletenessMap['entry7'].upToDate = value[i].upToDate;
              _entrySourceDocumentCompletenessMap['entry7'].standardForm = value[i].standardForm;
              _entrySourceDocumentCompletenessMap['entry7'].comment = value[i].comment;
              id7Availabe.text = value[i].available.toString();
              id7UpToDate.text = value[i].upToDate.toString();
              id7StandardForm.text = value[i].standardForm.toString();
              id7Comment.text = value[i].comment;
            });
          } else if (value[i].type == 'result') {
            setState(() {
              _entrySourceDocumentCompletenessMap['result'].id = value[i].id;
              _entrySourceDocumentCompletenessMap['result'].availableResult = value[i].availableResult;
              _entrySourceDocumentCompletenessMap['result'].upToDateResult = value[i].upToDateResult;
              _entrySourceDocumentCompletenessMap['result'].standardFormResult = value[i].standardFormResult;
              _entrySourceDocumentCompletenessMap['result'].comment = value[i].comment;
              id8Availabe.text = value[i].availableResult.toString();
              id8UpToDate.text = value[i].upToDateResult.toString();
              id8StandardForm.text = value[i].standardFormResult.toString();
              id8Comment.text = value[i].comment;
            });
          }
        }
      } else {
        setState(() {
          id1Availabe.text = '';
          id1UpToDate.text = '';
          id1StandardForm.text = '';
          id1Comment.text = '';
          id2Availabe.text = '';
          id2UpToDate.text = '';
          id2StandardForm.text = '';
          id2Comment.text = '';
          id3Availabe.text = '';
          id3UpToDate.text = '';
          id3StandardForm.text = '';
          id3Comment.text = '';
          id4Availabe.text = '';
          id4UpToDate.text = '';
          id4StandardForm.text = '';
          id4Comment.text = '';
          id5Availabe.text = '';
          id5UpToDate.text = '';
          id5StandardForm.text = '';
          id5Comment.text = '';
          id6Availabe.text = '';
          id6UpToDate.text = '';
          id6StandardForm.text = '';
          id6Comment.text = '';
          id7Availabe.text = '';
          id7UpToDate.text = '';
          id7StandardForm.text = '';
          id7Comment.text = '';
          id8Availabe.text = '';
          id8UpToDate.text = '';
          id8StandardForm.text = '';
          id8Comment.text = '';
        });
      }
    });
  }

  Future<void> _fillDataAccuracyFields() async {
    __entryDataAccuracy = EntryDataAccuracy(id: 0);
    _dataAccuracyTuple2 = EntryDataAccuracyTuple2(entryDataAccuracy: __entryDataAccuracy, entryDataAccuracyDiscrepancy: []);
    _dataAccuracies = [];
    _dataAccuracies.add(_dataAccuracyTuple2);
    _dataAccuracies.add(_dataAccuracyTuple2);
    _dataAccuracies.add(_dataAccuracyTuple2);
    configManager.getDataRowsByFacilityAndSupervision('entrydataaccuracy', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.isNotEmpty) {
        for (var i = 0; i < value.length; i++) {
          if (value[i].type == 'entry1') {
            setState(() {
              ii1SourceDocumentRecount1.text = value[i].sourceDocumentRecount1.toString(); // int
              ii1SourceDocumentRecount2.text = value[i].sourceDocumentRecount2.toString(); // int
              ii1SourceDocumentRecount3.text = value[i].sourceDocumentRecount3.toString(); // int
              ii1SourceDocumentRecountTotal.text = value[i].sourceDocumentRecountTotal.toString(); // int
              ii1SourceDocumentRecountComment.text = value[i].sourceDocumentRecountComment; // String
              ii1HmisMonthlyReportValue1.text = value[i].hmisMonthlyReportValue1.toString(); // int
              ii1HmisMonthlyReportValue2.text = value[i].hmisMonthlyReportValue2.toString(); // int
              ii1HmisMonthlyReportValue3.text = value[i].hmisMonthlyReportValue3.toString(); // int
              ii1HmisMonthlyReportValueTotal.text = value[i].hmisMonthlyReportValueTotal.toString(); // int
              ii1HmisMonthlyReportValueComment.text = value[i].hmisMonthlyReportValueComment; // String
              ii1DhisMonthlyValue1.text = value[i].dhisMonthlyValue1.toString(); // int
              ii1DhisMonthlyValue2.text = value[i].dhisMonthlyValue2.toString(); // int
              ii1DhisMonthlyValue3.text = value[i].dhisMonthlyValue3.toString(); // int
              ii1DhisMonthlyValueTotal.text = value[i].dhisMonthlyValueTotal.toString(); // int
              ii1DhisMonthlyValueComment.text = value[i].dhisMonthlyValueComment; // String
              ii1MonthlyReportVf1.text = value[i].monthlyReportVf1.toString(); // int
              ii1MonthlyReportVf2.text = value[i].monthlyReportVf2.toString(); // int
              ii1MonthlyReportVf3.text = value[i].monthlyReportVf3.toString(); // int
              ii1MonthlyReportVfTotal.text = value[i].monthlyReportVfTotal.toString(); // int
              ii1MonthlyReportVfComment.text = value[i].monthlyReportVfComment; // String
              ii1DhisVf1.text = value[i].dhisVf1.toString(); // int
              ii1DhisVf2.text = value[i].dhisVf2.toString(); // int
              ii1DhisVf3.text = value[i].dhisVf3.toString(); // int
              ii1DhisVfTotal.text = value[i].dhisVfTotal.toString(); // int
              ii1DhisVfComment.text = value[i].dhisVfComment; // String
              ii1ReasonForDiscrepancyComment.text = value[i].reasonForDiscrepancyComment; // String
              ii1OtherReasonForDiscrepancy1.text = value[i].otherReasonForDiscrepancy1; // String
              ii1OtherReasonForDiscrepancy2.text = value[i].otherReasonForDiscrepancy2; // String
              ii1OtherReasonForDiscrepancy3.text = value[i].otherReasonForDiscrepancy3; // String
              ii1OtherReasonForDiscrepancyComment.text = value[i].otherReasonForDiscrepancyComment; // String
            });
          } else if (value[i].type == 'entry2') {
            setState(() {
              ii2SourceDocumentRecount1.text = value[i].sourceDocumentRecount1.toString(); // int
              ii2SourceDocumentRecount2.text = value[i].sourceDocumentRecount2.toString(); // int
              ii2SourceDocumentRecount3.text = value[i].sourceDocumentRecount3.toString(); // int
              ii2SourceDocumentRecountTotal.text = value[i].sourceDocumentRecountTotal.toString(); // int
              ii2SourceDocumentRecountComment.text = value[i].sourceDocumentRecountComment; // String
              ii2HmisMonthlyReportValue1.text = value[i].hmisMonthlyReportValue1.toString(); // int
              ii2HmisMonthlyReportValue2.text = value[i].hmisMonthlyReportValue2.toString(); // int
              ii2HmisMonthlyReportValue3.text = value[i].hmisMonthlyReportValue3.toString(); // int
              ii2HmisMonthlyReportValueTotal.text = value[i].hmisMonthlyReportValueTotal.toString(); // int
              ii2HmisMonthlyReportValueComment.text = value[i].hmisMonthlyReportValueComment; // String
              ii2DhisMonthlyValue1.text = value[i].dhisMonthlyValue1.toString(); // int
              ii2DhisMonthlyValue2.text = value[i].dhisMonthlyValue2.toString(); // int
              ii2DhisMonthlyValue3.text = value[i].dhisMonthlyValue3.toString(); // int
              ii2DhisMonthlyValueTotal.text = value[i].dhisMonthlyValueTotal.toString(); // int
              ii2DhisMonthlyValueComment.text = value[i].dhisMonthlyValueComment; // String
              ii2MonthlyReportVf1.text = value[i].monthlyReportVf1.toString(); // int
              ii2MonthlyReportVf2.text = value[i].monthlyReportVf2.toString(); // int
              ii2MonthlyReportVf3.text = value[i].monthlyReportVf3.toString(); // int
              ii2MonthlyReportVfTotal.text = value[i].monthlyReportVfTotal.toString(); // int
              ii2MonthlyReportVfComment.text = value[i].monthlyReportVfComment; // String
              ii2DhisVf1.text = value[i].dhisVf1.toString(); // int
              ii2DhisVf2.text = value[i].dhisVf2.toString(); // int
              ii2DhisVf3.text = value[i].dhisVf3.toString(); // int
              ii2DhisVfTotal.text = value[i].dhisVfTotal.toString(); // int
              ii2DhisVfComment.text = value[i].dhisVfComment; // String
              ii2ReasonForDiscrepancyComment.text = value[i].reasonForDiscrepancyComment; // String
              ii2OtherReasonForDiscrepancy1.text = value[i].otherReasonForDiscrepancy1; // String
              ii2OtherReasonForDiscrepancy2.text = value[i].otherReasonForDiscrepancy2; // String
              ii2OtherReasonForDiscrepancy3.text = value[i].otherReasonForDiscrepancy3; // String
              ii2OtherReasonForDiscrepancyComment.text = value[i].otherReasonForDiscrepancyComment;
            });
          } else if (value[i].type == 'entry3') {
            setState(() {
              ii3SourceDocumentRecount1.text = value[i].sourceDocumentRecount1.toString(); // int
              ii3SourceDocumentRecount2.text = value[i].sourceDocumentRecount2.toString(); // int
              ii3SourceDocumentRecount3.text = value[i].sourceDocumentRecount3.toString(); // int
              ii3SourceDocumentRecountTotal.text = value[i].sourceDocumentRecountTotal.toString(); // int
              ii3SourceDocumentRecountComment.text = value[i].sourceDocumentRecountComment; // String
              ii3HmisMonthlyReportValue1.text = value[i].hmisMonthlyReportValue1.toString(); // int
              ii3HmisMonthlyReportValue2.text = value[i].hmisMonthlyReportValue2.toString(); // int
              ii3HmisMonthlyReportValue3.text = value[i].hmisMonthlyReportValue3.toString(); // int
              ii3HmisMonthlyReportValueTotal.text = value[i].hmisMonthlyReportValueTotal.toString(); // int
              ii3HmisMonthlyReportValueComment.text = value[i].hmisMonthlyReportValueComment; // String
              ii3DhisMonthlyValue1.text = value[i].dhisMonthlyValue1.toString(); // int
              ii3DhisMonthlyValue2.text = value[i].dhisMonthlyValue2.toString(); // int
              ii3DhisMonthlyValue3.text = value[i].dhisMonthlyValue3.toString(); // int
              ii3DhisMonthlyValueTotal.text = value[i].dhisMonthlyValueTotal.toString(); // int
              ii3DhisMonthlyValueComment.text = value[i].dhisMonthlyValueComment; // String
              ii3MonthlyReportVf1.text = value[i].monthlyReportVf1.toString(); // int
              ii3MonthlyReportVf2.text = value[i].monthlyReportVf2.toString(); // int
              ii3MonthlyReportVf3.text = value[i].monthlyReportVf3.toString(); // int
              ii3MonthlyReportVfTotal.text = value[i].monthlyReportVfTotal.toString(); // int
              ii3MonthlyReportVfComment.text = value[i].monthlyReportVfComment; // String
              ii3DhisVf1.text = value[i].dhisVf1.toString(); // int
              ii3DhisVf2.text = value[i].dhisVf2.toString(); // int
              ii3DhisVf3.text = value[i].dhisVf3.toString(); // int
              ii3DhisVfTotal.text = value[i].dhisVfTotal.toString(); // int
              ii3DhisVfComment.text = value[i].dhisVfComment; // String
              ii3ReasonForDiscrepancyComment.text = value[i].reasonForDiscrepancyComment; // String
              ii3OtherReasonForDiscrepancy1.text = value[i].otherReasonForDiscrepancy1; // String
              ii3OtherReasonForDiscrepancy2.text = value[i].otherReasonForDiscrepancy2; // String
              ii3OtherReasonForDiscrepancy3.text = value[i].otherReasonForDiscrepancy3; // String
              ii3OtherReasonForDiscrepancyComment.text = value[i].otherReasonForDiscrepancyComment;
            });
          }

          setState(() {
            _dataAccuracies[i].entryDataAccuracy = value[i];
          });
          configManager
              .getDataRowsBySupervisionCountryAndId('entrydataaccuracydiscrepancy', widget.selectedSupervision.id, _facilityId, value[i].indicatorId)
              .then((val) {
            if (val == null) {
              val = [];
            }
            if (value[i].type == 'entry1') {
              if (val.length > 0) {
                setState(() {
                  ii1DiscrepanciesMonth1 = MrdqaHelpers.getMonthDiscrepancies(val, 1);
                  ii1DiscrepanciesMonth2 = MrdqaHelpers.getMonthDiscrepancies(val, 2);
                  ii1DiscrepanciesMonth3 = MrdqaHelpers.getMonthDiscrepancies(val, 3);
                });
              } else {
                ii1DiscrepanciesMonth1 = [];
                ii1DiscrepanciesMonth2 = [];
                ii1DiscrepanciesMonth3 = [];
              }
            } else if (value[i].type == 'entry2') {
              if (val.length > 0) {
                setState(() {
                  ii2DiscrepanciesMonth1 = MrdqaHelpers.getMonthDiscrepancies(val, 1);
                  ii2DiscrepanciesMonth2 = MrdqaHelpers.getMonthDiscrepancies(val, 2);
                  ii2DiscrepanciesMonth3 = MrdqaHelpers.getMonthDiscrepancies(val, 3);
                });
              } else {
                ii2DiscrepanciesMonth1 = [];
                ii2DiscrepanciesMonth2 = [];
                ii2DiscrepanciesMonth3 = [];
              }
            } else if (value[i].type == 'entry3') {
              if (val.length > 0) {
                setState(() {
                  ii3DiscrepanciesMonth1 = MrdqaHelpers.getMonthDiscrepancies(val, 1);
                  ii3DiscrepanciesMonth2 = MrdqaHelpers.getMonthDiscrepancies(val, 2);
                  ii3DiscrepanciesMonth3 = MrdqaHelpers.getMonthDiscrepancies(val, 3);
                });
              } else {
                ii3DiscrepanciesMonth1 = [];
                ii3DiscrepanciesMonth2 = [];
                ii3DiscrepanciesMonth3 = [];
              }
            }
          });
        }
      } else {
        setState(() {
          ii1SourceDocumentRecount1.text = '';
          ii1SourceDocumentRecount2.text = '';
          ii1SourceDocumentRecount3.text = ''; // int
          ii1SourceDocumentRecountTotal.text = ''; // int
          ii1SourceDocumentRecountComment.text = ''; // String
          ii1HmisMonthlyReportValue1.text = ''; // int
          ii1HmisMonthlyReportValue2.text = ''; // int
          ii1HmisMonthlyReportValue3.text = ''; // int
          ii1HmisMonthlyReportValueTotal.text = ''; // int
          ii1HmisMonthlyReportValueComment.text = ''; // String
          ii1DhisMonthlyValue1.text = ''; // int
          ii1DhisMonthlyValue2.text = ''; // int
          ii1DhisMonthlyValue3.text = ''; // int
          ii1DhisMonthlyValueTotal.text = ''; // int
          ii1DhisMonthlyValueComment.text = ''; // String
          ii1MonthlyReportVf1.text = ''; // int
          ii1MonthlyReportVf2.text = ''; // int
          ii1MonthlyReportVf3.text = ''; // int
          ii1MonthlyReportVfTotal.text = ''; // int
          ii1MonthlyReportVfComment.text = ''; // String
          ii1DhisVf1.text = ''; // int
          ii1DhisVf2.text = ''; // int
          ii1DhisVf3.text = ''; // int
          ii1DhisVfTotal.text = ''; // int
          ii1DhisVfComment.text = ''; // String
          ii1DiscrepanciesMonth1 = [];
          ii1DiscrepanciesMonth2 = [];
          ii1DiscrepanciesMonth3 = [];
          ii1ReasonForDiscrepancyComment.text = ''; // String
          ii1OtherReasonForDiscrepancy1.text = ''; // String
          ii1OtherReasonForDiscrepancy2.text = ''; // String
          ii1OtherReasonForDiscrepancy3.text = ''; // String
          ii1OtherReasonForDiscrepancyComment.text = '';
          ii2SourceDocumentRecount1.text = '';
          ii2SourceDocumentRecount2.text = '';
          ii2SourceDocumentRecount3.text = ''; // int
          ii2SourceDocumentRecountTotal.text = ''; // int
          ii2SourceDocumentRecountComment.text = ''; // String
          ii2HmisMonthlyReportValue1.text = ''; // int
          ii2HmisMonthlyReportValue2.text = ''; // int
          ii2HmisMonthlyReportValue3.text = ''; // int
          ii2HmisMonthlyReportValueTotal.text = ''; // int
          ii2HmisMonthlyReportValueComment.text = ''; // String
          ii2DhisMonthlyValue1.text = ''; // int
          ii2DhisMonthlyValue2.text = ''; // int
          ii2DhisMonthlyValue3.text = ''; // int
          ii2DhisMonthlyValueTotal.text = ''; // int
          ii2DhisMonthlyValueComment.text = ''; // String
          ii2MonthlyReportVf1.text = ''; // int
          ii2MonthlyReportVf2.text = ''; // int
          ii2MonthlyReportVf3.text = ''; // int
          ii2MonthlyReportVfTotal.text = ''; // int
          ii2MonthlyReportVfComment.text = ''; // String
          ii2DhisVf1.text = ''; // int
          ii2DhisVf2.text = ''; // int
          ii2DhisVf3.text = ''; // int
          ii2DhisVfTotal.text = ''; // int
          ii2DhisVfComment.text = ''; // String
          ii2DiscrepanciesMonth1 = [];
          ii2DiscrepanciesMonth2 = [];
          ii2DiscrepanciesMonth3 = [];
          ii2ReasonForDiscrepancyComment.text = ''; // String
          ii2OtherReasonForDiscrepancy1.text = ''; // String
          ii2OtherReasonForDiscrepancy2.text = ''; // String
          ii2OtherReasonForDiscrepancy3.text = ''; // String
          ii2OtherReasonForDiscrepancyComment.text = '';
          ii3SourceDocumentRecount1.text = '';
          ii3SourceDocumentRecount2.text = '';
          ii3SourceDocumentRecount3.text = ''; // int
          ii3SourceDocumentRecountTotal.text = ''; // int
          ii3SourceDocumentRecountComment.text = ''; // String
          ii3HmisMonthlyReportValue1.text = ''; // int
          ii3HmisMonthlyReportValue2.text = ''; // int
          ii3HmisMonthlyReportValue3.text = ''; // int
          ii3HmisMonthlyReportValueTotal.text = ''; // int
          ii3HmisMonthlyReportValueComment.text = ''; // String
          ii3DhisMonthlyValue1.text = ''; // int
          ii3DhisMonthlyValue2.text = ''; // int
          ii3DhisMonthlyValue3.text = ''; // int
          ii3DhisMonthlyValueTotal.text = ''; // int
          ii3DhisMonthlyValueComment.text = ''; // String
          ii3MonthlyReportVf1.text = ''; // int
          ii3MonthlyReportVf2.text = ''; // int
          ii3MonthlyReportVf3.text = ''; // int
          ii3MonthlyReportVfTotal.text = ''; // int
          ii3MonthlyReportVfComment.text = ''; // String
          ii3DhisVf1.text = ''; // int
          ii3DhisVf2.text = ''; // int
          ii3DhisVf3.text = ''; // int
          ii3DhisVfTotal.text = ''; // int
          ii3DhisVfComment.text = ''; // String
          ii3DiscrepanciesMonth1 = [];
          ii3DiscrepanciesMonth2 = [];
          ii3DiscrepanciesMonth3 = [];
          ii3ReasonForDiscrepancyComment.text = ''; // String
          ii3OtherReasonForDiscrepancy1.text = ''; // String
          ii3OtherReasonForDiscrepancy2.text = ''; // String
          ii3OtherReasonForDiscrepancy3.text = ''; // String
          ii3OtherReasonForDiscrepancyComment.text = '';
        });
      }
    });
  }

  Future<void> _fillCrossCheckFields() async {
    _entryCrossCheckAb = new EntryCrossCheckAb(id: 0);
    _entryCrossCheckAbList = [_entryCrossCheckAb, _entryCrossCheckAb];
    _entryCrossCheckC = new EntryCrossCheckC(id: 0);
    configManager.getDataRowsByFacilityAndSupervision('entrycrosscheckab', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          _entryCrossCheckAbList = value;
        });
        for (var i = 0; i < value.length; i++) {
          if (value[i].type == 'a') {
            setState(() {
              iiiaCasesSimpledFromPrimary.text = value[i].casesSimpledFromPrimary.toString(); // int
              iiiaPrimaryComment.text = value[i].primaryComment; // String
              iiiaCorrespondingMachingInSecondary.text = value[i].correspondingMachingInSecondary.toString(); // int
              iiiaSecondaryComment.text = value[i].secondaryComment; // String
              iiiaSecondaryReliabilityRate.text = value[i].secondaryReliabilityRate.toString(); // int
              iiiaReliabilityComment.text = value[i].reliabilityComment; // String
            });
          } else if (value[i].type == 'b') {
            setState(() {
              iiibCasesSimpledFromPrimary.text = value[i].casesSimpledFromPrimary.toString(); // int
              iiibPrimaryComment.text = value[i].primaryComment; // String
              iiibCorrespondingMachingInSecondary.text = value[i].correspondingMachingInSecondary.toString(); // int
              iiibSecondaryComment.text = value[i].secondaryComment; // String
              iiibSecondaryReliabilityRate.text = value[i].secondaryReliabilityRate.toString(); // int
              iiibReliabilityComment.text = value[i].reliabilityComment; // String
            });
          }
        }
      } else {
        setState(() {
          iiiaCasesSimpledFromPrimary.text = ''; // int
          iiiaPrimaryComment.text = ''; // String
          iiiaCorrespondingMachingInSecondary.text = ''; // int
          iiiaSecondaryComment.text = ''; // String
          iiiaSecondaryReliabilityRate.text = ''; // int
          iiiaReliabilityComment.text = ''; // String
          iiibCasesSimpledFromPrimary.text = ''; // int
          iiibPrimaryComment.text = ''; // String
          iiibCorrespondingMachingInSecondary.text = ''; // int
          iiibSecondaryComment.text = ''; // String
          iiibSecondaryReliabilityRate.text = ''; // int
          iiibReliabilityComment.text = ''; // String
        });
      }
    });

    configManager.getDataRowByFacilityAndSupervision('entrycrosscheckc', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.id != null) {
        setState(() {
          _entryCrossCheckC = value;
          iiicInitialStock.text = value.initialStock.toString(); // Int
          iiicInitialStockComment.text = value.initialStockComment; // String
          iiicReceivedStock.text = value.receivedStock.toString(); // Int
          iiicReceivedStockComment.text = value.receivedStockComment; // String
          iiicClosingStock.text = value.closingStock.toString(); // Int
          iiicClosingStockComment.text = value.closingStockComment; // String
          iiicUsedStock.text = value.usedStock.toString(); // Int
          iiicUsedStockComment.text = value.usedStockComment; // String
          iiicRatio.text = value.ratio.toString(); // Double
          iiicRatioComment.text = value.ratioComment; // String
          iiicReasonForDiscrepancyComment.text = value.reasonForDiscrepancyComment; // String
          iiicOtherReasonForDiscrepancy.text = value.otherReasonForDiscrepancy.toString(); // String
          iiicOtherReasonForDiscrepancyComment.text = value.otherReasonForDiscrepancyComment; // String
        });
      } else {
        setState(() {
          iiicInitialStock.text = ''; // Int
          iiicInitialStockComment.text = ''; // String
          iiicReceivedStock.text = ''; // Int
          iiicReceivedStockComment.text = ''; // String
          iiicClosingStock.text = ''; // Int
          iiicClosingStockComment.text = ''; // String
          iiicUsedStock.text = ''; // Int
          iiicUsedStockComment.text = ''; // String
          iiicRatio.text = ''; // Double
          iiicRatioComment.text = ''; // String
          iiicReasonForDiscrepancyComment.text = ''; // String
          iiicOtherReasonForDiscrepancy.text = ''; // String
          iiicOtherReasonForDiscrepancyComment.text = ''; // String
        });
      }
    });

    configManager.getDataRowsByFacilityAndSupervision('entrycrosscheckcdiscrepancies', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.length > 0) {
        List<int> result = [];
        for (var i = 0; i < value.length; i++) {
          result.add(value[i].entryDiscrepanciesId);
        }
        setState(() {
          iiicReasonForDiscrepancy = result;
        });
      } else {
        setState(() {
          iiicReasonForDiscrepancy = [];
        });
      }
    });
  }

  Future<void> _fillConsistencyOverTimeFields() async {
    _entryConsistencyOverTime = new EntryConsistencyOverTime(id: 0);
    configManager.getDataRowByFacilityAndSupervision('entryconsistencyovertime', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.id != null) {
        _entryConsistencyOverTime = value;
        setState(() {
          ivCurrentMonthValue.text = value.currentMonthValue.toString();
          ivCurrentMonthValueComment.text = value.currentMonthValueComment;
          ivCurrentMonthYearAgoValue.text = value.currentMonthYearAgoValue.toString();
          ivCurrentMonthYearAgoValueComment.text = value.currentMonthYearAgoValueComment;
          ivAnnualRatio.text = value.annualRatio.toString();
          ivAnnualRatioComment.text = value.annualRatioComment;
          ivMonthToMonthValue1.text = value.monthToMonthValue1.toString();
          ivMonthToMonthValue2.text = value.monthToMonthValue2.toString();
          ivMonthToMonthValue3.text = value.monthToMonthValue3.toString();
          ivMonthToMonthValueLastMonth.text = value.monthToMonthValueLastMonth.toString();
          ivMonthToMonthRatio.text = value.monthToMonthRatio.toString();
          ivMonthToMonthRatioComment.text = value.monthToMonthRatioComment;
          ivReasonForDiscrepancyComment.text = value.reasonForDiscrepancyComment;
          ivOtherReasonForDiscrepancy.text = value.otherReasonForDiscrepancy.toString();
          ivOtherReasonForDiscrepancyComment.text = value.otherReasonForDiscrepancyComment;
        });
      } else {
        setState(() {
          ivCurrentMonthValue.text = '';
          ivCurrentMonthValueComment.text = '';
          ivCurrentMonthYearAgoValue.text = '';
          ivCurrentMonthYearAgoValueComment.text = '';
          ivAnnualRatio.text = '';
          ivAnnualRatioComment.text = '';
          ivMonthToMonthValue1.text = '';
          ivMonthToMonthValue2.text = '';
          ivMonthToMonthValue3.text = '';
          ivMonthToMonthValueLastMonth.text = '';
          ivMonthToMonthRatio.text = '';
          ivMonthToMonthRatioComment.text = '';
          ivReasonForDiscrepancyComment.text = '';
          ivOtherReasonForDiscrepancy.text = '';
          ivOtherReasonForDiscrepancyComment.text = '';
        });
      }
    });
    configManager.getDataRowsByFacilityAndSupervision('entryconsistencyovertimediscrepancy', widget.selectedSupervision.id, _facilityId).then((val) {
      if (val != null && val.length > 0) {
        List<int> result = [];
        for (var i = 0; i < val.length; i++) {
          result.add(val[i].entryDiscrepanciesId);
        }
        setState(() {
          ivReasonForDiscrepancy = result;
        });
      } else {
        setState(() {
          ivReasonForDiscrepancy = [];
        });
      }
    });
  }

  Future<void> _fillSystemAssessmentFields() async {
    _entrySystemAssessment = new EntrySystemAssessment(id: 0);
    configManager.getDataRowByFacilityAndSupervision('entrysystemassessment', widget.selectedSupervision.id, _facilityId).then((value) {
      if (value != null && value.id != null) {
        _entrySystemAssessment = value;
        setState(() {
          vQuestionV1.text = value.questionV1.toString();
          vQuestionV1Comment.text = value.questionV1Comment;
          vQuestionV2.text = value.questionV2.toString();
          vQuestionV2Comment.text = value.questionV2Comment;
          vQuestionV3.text = value.questionV3.toString();
          vQuestionV3Comment.text = value.questionV3Comment;
          vQuestionV4.text = value.questionV4.toString();
          vQuestionV4Comment.text = value.questionV4Comment;
          vQuestionV5.text = value.questionV5.toString();
          vQuestionV5Comment.text = value.questionV5Comment;
          vQuestionV6.text = value.questionV6.toString();
          vQuestionV6Comment.text = value.questionV6Comment;
          vQuestionV7.text = value.questionV7.toString();
          vQuestionV7Comment.text = value.questionV7Comment;
          vQuestionV8.text = value.questionV8.toString();
          vQuestionV8Comment.text = value.questionV8Comment;
          vQuestionV9.text = value.questionV9.toString();
          vQuestionV9Comment.text = value.questionV9Comment;
          vQuestionV10.text = value.questionV10.toString();
          vQuestionV10Comment.text = value.questionV10Comment;
          vQuestionV11.text = value.questionV11.toString();
          vQuestionV11Comment.text = value.questionV11Comment;
          vQuestionV12.text = value.questionV12.toString();
          vQuestionV12Comment.text = value.questionV12Comment;
          systemReadiness.text = value.systemReadiness.toString();
        });
      } else {
        setState(() {
          vQuestionV1.text = '';
          vQuestionV1Comment.text = '';
          vQuestionV2.text = '';
          vQuestionV2Comment.text = '';
          vQuestionV3.text = '';
          vQuestionV3Comment.text = '';
          vQuestionV4.text = '';
          vQuestionV4Comment.text = '';
          vQuestionV5.text = '';
          vQuestionV5Comment.text = '';
          vQuestionV6.text = '';
          vQuestionV6Comment.text = '';
          vQuestionV7.text = '';
          vQuestionV7Comment.text = '';
          vQuestionV8.text = '';
          vQuestionV8Comment.text = '';
          vQuestionV9.text = '';
          vQuestionV9Comment.text = '';
          vQuestionV10.text = '';
          vQuestionV10Comment.text = '';
          vQuestionV11.text = '';
          vQuestionV11Comment.text = '';
          vQuestionV12.text = '';
          vQuestionV12Comment.text = '';
          systemReadiness.text = '';
        });
      }
    });
  }

  Future<void> _pushCompletenessForm() async {
    _entryCompletenessMonthlyReport.expectedCells = int.parse(iaExpectedCells.text);
    _entryCompletenessMonthlyReport.completedCells = int.parse(iaCompletedCells.text);
    _entryCompletenessMonthlyReport.percent = double.parse(iaPercent.text);
    _entryCompletenessMonthlyReport.comment = iaComment.text;
    if (_entryCompletenessMonthlyReport.id != 0) {
      configManager.updateRowById('entrycompletenessmonthlyreport', _entryCompletenessMonthlyReport);
    } else {
      _entryCompletenessMonthlyReport.facilityId = _facilityId;
      _entryCompletenessMonthlyReport.supervisionId = widget.selectedSupervision.id;
      configManager.saveRowData('entrycompletenessmonthlyreport', _entryCompletenessMonthlyReport);
    }
  }

  Future<void> _pushTimelinessForm() async {
    _entryTimelinessMonthlyReport.submittedMonth1 = int.parse(ibSubmittedMonth1.text);
    _entryTimelinessMonthlyReport.submittedMonth2 = int.parse(ibSubmittedMonth2.text);
    _entryTimelinessMonthlyReport.submittedMonth3 = int.parse(ibSubmittedMonth3.text);
    _entryTimelinessMonthlyReport.percent = double.parse(ibPercent.text);
    _entryTimelinessMonthlyReport.comment = ibComment.text;
    if (_entryTimelinessMonthlyReport.id != 0) {
      configManager.updateRowById('entrytimelinessmonthlyreport', _entryTimelinessMonthlyReport);
    } else {
      _entryTimelinessMonthlyReport.facilityId = _facilityId;
      _entryTimelinessMonthlyReport.supervisionId = widget.selectedSupervision.id;
      configManager.saveRowData('entrytimelinessmonthlyreport', _entryTimelinessMonthlyReport);
    }
  }

  Future<void> _pushDeComplenessForm() async {
    if (MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 1, 'de_completeness') != null) {
      _entryDataElementCompletenessMap['entry1'].dataElementId = MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 1, 'de_completeness').dataElementId;
      _entryDataElementCompletenessMap['entry1'].missingCasesData = int.parse(ic1missingCasesData.text);
      _entryDataElementCompletenessMap['entry1'].percent = double.parse(ic1Percent.text);
      _entryDataElementCompletenessMap['entry1'].type = 'entry1';
    }

    if (MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 2, 'de_completeness') != null) {
      _entryDataElementCompletenessMap['entry2'].dataElementId = MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 2, 'de_completeness').dataElementId;
      _entryDataElementCompletenessMap['entry2'].missingCasesData = int.parse(ic1missingCasesData.text);
      _entryDataElementCompletenessMap['entry2'].percent = double.parse(ic2Percent.text);
      _entryDataElementCompletenessMap['entry2'].type = 'entry2';
    }

    if (MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 3, 'de_completeness') != null) {
      _entryDataElementCompletenessMap['entry3'].dataElementId = MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 3, 'de_completeness').dataElementId;
      _entryDataElementCompletenessMap['entry3'].missingCasesData = int.parse(ic1missingCasesData.text);
      _entryDataElementCompletenessMap['entry3'].percent = double.parse(ic3Percent.text);
      _entryDataElementCompletenessMap['entry3'].type = 'entry3';
    }

    if (MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 4, 'de_completeness') != null) {
      _entryDataElementCompletenessMap['entry4'].dataElementId = MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 4, 'de_completeness').dataElementId;
      _entryDataElementCompletenessMap['entry4'].missingCasesData = int.parse(ic1missingCasesData.text);
      _entryDataElementCompletenessMap['entry4'].percent = double.parse(ic4Percent.text);
      _entryDataElementCompletenessMap['entry4'].type = 'entry4';
    }

    if (MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 5, 'de_completeness') != null) {
      _entryDataElementCompletenessMap['entry5'].dataElementId = MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 5, 'de_completeness').dataElementId;
      _entryDataElementCompletenessMap['entry5'].missingCasesData = int.parse(ic1missingCasesData.text);
      _entryDataElementCompletenessMap['entry5'].percent = double.parse(ic5Percent.text);
      _entryDataElementCompletenessMap['entry5'].type = 'entry5';
    }

    if (MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 6, 'de_completeness') != null) {
      _entryDataElementCompletenessMap['entry6'].dataElementId = MrdqaHelpers.getObjectByNumber(_dataElementCompletenesses, 6, 'de_completeness').dataElementId;
      _entryDataElementCompletenessMap['entry6'].missingCasesData = int.parse(ic1missingCasesData.text);
      _entryDataElementCompletenessMap['entry6'].percent = double.parse(ic6Percent.text);
      _entryDataElementCompletenessMap['entry6'].type = 'entry6';
    }

    _entryDataElementCompletenessMap['missing'].dataElementId = widget.selectedSupervision.id;
    _entryDataElementCompletenessMap['missing'].missingCasesData = int.parse(ic7missingCasesData.text);
    _entryDataElementCompletenessMap['missing'].percent = double.parse(ic7Percent.text);
    _entryDataElementCompletenessMap['missing'].type = 'missing';

    _entryDataElementCompletenessMap['total'].dataElementId = widget.selectedSupervision.id;
    _entryDataElementCompletenessMap['total'].missingCasesData = int.parse(ic8missingCasesData.text);
    _entryDataElementCompletenessMap['total'].percent = double.parse(ic8Percent.text);
    _entryDataElementCompletenessMap['total'].type = 'total';

    _entryDataElementCompletenessMap.forEach((key, value) {
      if (value != null && value.dataElementId != null) {
        if (value.id != 0) {
          configManager.updateRowById('entrydataelementcompleteness', value);
        } else {
          value.facilityId = _facilityId;
          value.supervisionId = widget.selectedSupervision.id;
          configManager.saveRowData('entrydataelementcompleteness', value);
        }
      }
    });
  }

  Future<void> _pushSourceDocumentComplenessForm() async {
    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 1, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry1'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 1, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry1'].available = int.parse(id1Availabe.text);
      _entrySourceDocumentCompletenessMap['entry1'].upToDate = int.parse(id1UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry1'].standardForm = int.parse(id1StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry1'].comment = id1Comment.text;
      _entrySourceDocumentCompletenessMap['entry1'].type = 'entry1';
    }

    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 2, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry2'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 2, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry2'].available = int.parse(id2Availabe.text);
      _entrySourceDocumentCompletenessMap['entry2'].upToDate = int.parse(id2UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry2'].standardForm = int.parse(id2StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry2'].comment = id2Comment.text;
      _entrySourceDocumentCompletenessMap['entry2'].type = 'entry2';
    }

    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 3, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry3'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 3, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry3'].available = int.parse(id3Availabe.text);
      _entrySourceDocumentCompletenessMap['entry3'].upToDate = int.parse(id3UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry3'].standardForm = int.parse(id3StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry3'].comment = id3Comment.text;
      _entrySourceDocumentCompletenessMap['entry3'].type = 'entry3';
    }

    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 4, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry4'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 4, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry4'].available = int.parse(id4Availabe.text);
      _entrySourceDocumentCompletenessMap['entry4'].upToDate = int.parse(id4UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry4'].standardForm = int.parse(id4StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry4'].comment = id4Comment.text;
      _entrySourceDocumentCompletenessMap['entry4'].type = 'entry4';
    }

    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 5, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry5'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 5, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry5'].available = int.parse(id5Availabe.text);
      _entrySourceDocumentCompletenessMap['entry5'].upToDate = int.parse(id5UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry5'].standardForm = int.parse(id5StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry5'].comment = id5Comment.text;
      _entrySourceDocumentCompletenessMap['entry5'].type = 'entry5';
    }

    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 6, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry6'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 6, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry6'].available = int.parse(id6Availabe.text);
      _entrySourceDocumentCompletenessMap['entry6'].upToDate = int.parse(id6UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry6'].standardForm = int.parse(id6StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry6'].comment = id6Comment.text;
      _entrySourceDocumentCompletenessMap['entry6'].type = 'entry6';
    }

    if (MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 7, 'sd_completeness') != null) {
      _entrySourceDocumentCompletenessMap['entry7'].sourceDocumentId = MrdqaHelpers.getObjectByNumber(_sourceDocumentCompletenesses, 7, 'sd_completeness').sourceDocumentId;
      _entrySourceDocumentCompletenessMap['entry7'].available = int.parse(id7Availabe.text);
      _entrySourceDocumentCompletenessMap['entry7'].upToDate = int.parse(id7UpToDate.text);
      _entrySourceDocumentCompletenessMap['entry7'].standardForm = int.parse(id7StandardForm.text);
      _entrySourceDocumentCompletenessMap['entry7'].comment = id7Comment.text;
      _entrySourceDocumentCompletenessMap['entry7'].type = 'entry7';
    }

    _entrySourceDocumentCompletenessMap['result'].sourceDocumentId = widget.selectedSupervision.id;
    _entrySourceDocumentCompletenessMap['result'].availableResult = double.parse(id8Availabe.text);
    _entrySourceDocumentCompletenessMap['result'].upToDateResult = double.parse(id8UpToDate.text);
    _entrySourceDocumentCompletenessMap['result'].standardFormResult = double.parse(id8StandardForm.text);
    _entrySourceDocumentCompletenessMap['result'].comment = id8Comment.text;
    _entrySourceDocumentCompletenessMap['result'].type = 'result';

    _entrySourceDocumentCompletenessMap.forEach((key, value) {
      if (value != null && value.sourceDocumentId != null) {
        if (value.id != 0) {
          configManager.updateRowById('entrysourcedocumentcompleteness', value);
        } else {
          value.facilityId = _facilityId;
          value.supervisionId = widget.selectedSupervision.id;
          configManager.saveRowData('entrysourcedocumentcompleteness', value);
        }
      }
    });
  }

  Future<void> _pushDataAccuracyForm() async {
    EntryDataAccuracyDiscrepancy dataAccuracyDiscrepency;
    var $idOne = _dataAccuracies[0].entryDataAccuracy.id;
    var $idTwo = _dataAccuracies[1].entryDataAccuracy.id;
    var $idThree = _dataAccuracies[2].entryDataAccuracy.id;
    _dataAccuracies = [];

    SelectedIndicator selectedIndicatorOne = MrdqaHelpers.getObjectByNumber(_selectedIndicators, 1, 'selected_indicator');
    if (selectedIndicatorOne != null) {
      __entryDataAccuracy = new EntryDataAccuracy();
      __entryDataAccuracy.supervisionId = widget.selectedSupervision.id;
      __entryDataAccuracy.facilityId = _facilityId;
      __entryDataAccuracy.indicatorId = selectedIndicatorOne.indicatorId;
      __entryDataAccuracy.sourceDocumentRecount1 = int.parse(ii1SourceDocumentRecount1.text);
      __entryDataAccuracy.sourceDocumentRecount2 = int.parse(ii1SourceDocumentRecount2.text);
      __entryDataAccuracy.sourceDocumentRecount3 = int.parse(ii1SourceDocumentRecount3.text);
      __entryDataAccuracy.sourceDocumentRecountTotal = int.parse(ii1SourceDocumentRecountTotal.text);
      __entryDataAccuracy.sourceDocumentRecountComment = ii1SourceDocumentRecountComment.text;
      __entryDataAccuracy.hmisMonthlyReportValue1 = int.parse(ii1HmisMonthlyReportValue1.text);
      __entryDataAccuracy.hmisMonthlyReportValue2 = int.parse(ii1HmisMonthlyReportValue2.text);
      __entryDataAccuracy.hmisMonthlyReportValue3 = int.parse(ii1HmisMonthlyReportValue3.text);
      __entryDataAccuracy.hmisMonthlyReportValueTotal = int.parse(ii1HmisMonthlyReportValueTotal.text);
      __entryDataAccuracy.hmisMonthlyReportValueComment = ii1HmisMonthlyReportValueComment.text;
      __entryDataAccuracy.dhisMonthlyValue1 = int.parse(ii1DhisMonthlyValue1.text);
      __entryDataAccuracy.dhisMonthlyValue2 = int.parse(ii1DhisMonthlyValue2.text); // int
      __entryDataAccuracy.dhisMonthlyValue3 = int.parse(ii1DhisMonthlyValue3.text);
      __entryDataAccuracy.dhisMonthlyValueTotal = int.parse(ii1DhisMonthlyValueTotal.text);
      __entryDataAccuracy.dhisMonthlyValueComment = ii1DhisMonthlyValueComment.text;
      __entryDataAccuracy.monthlyReportVf1 = double.parse(ii1MonthlyReportVf1.text);
      __entryDataAccuracy.monthlyReportVf2 = double.parse(ii1MonthlyReportVf2.text);
      __entryDataAccuracy.monthlyReportVf3 = double.parse(ii1MonthlyReportVf3.text);
      __entryDataAccuracy.monthlyReportVfTotal = double.parse(ii1MonthlyReportVfTotal.text);
      __entryDataAccuracy.dhisMonthlyValueComment = ii1MonthlyReportVfComment.text;
      __entryDataAccuracy.dhisVf1 = double.parse(ii1DhisVf1.text);
      __entryDataAccuracy.dhisVf2 = double.parse(ii1DhisVf2.text);
      __entryDataAccuracy.dhisVf3 = double.parse(ii1DhisVf3.text);
      __entryDataAccuracy.dhisVfTotal = double.parse(ii1DhisVfTotal.text);
      __entryDataAccuracy.dhisVfComment = ii1DhisVfComment.text;
      __entryDataAccuracy.reasonForDiscrepancyComment = ii1ReasonForDiscrepancyComment.text;
      __entryDataAccuracy.otherReasonForDiscrepancy1 = ii1OtherReasonForDiscrepancy1.text;
      __entryDataAccuracy.otherReasonForDiscrepancy2 = ii1OtherReasonForDiscrepancy2.text;
      __entryDataAccuracy.otherReasonForDiscrepancy3 = ii1OtherReasonForDiscrepancy3.text;
      __entryDataAccuracy.otherReasonForDiscrepancyComment = ii1OtherReasonForDiscrepancyComment.text;
      __entryDataAccuracy.type = 'entry1';

      configManager.clearRowOfSupervisionFacility('entrydataaccuracydiscrepancy', widget.selectedSupervision.id, _facilityId);
      _entryDataAccuracyDiscrepancies = [];
      for (var i = 0; i < ii1DiscrepanciesMonth1.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorOne.indicatorId,
            entryDiscrepancyId: ii1DiscrepanciesMonth1[i],
            month: 1);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      for (var i = 0; i < ii1DiscrepanciesMonth2.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorOne.indicatorId,
            entryDiscrepancyId: ii1DiscrepanciesMonth2[i],
            month: 2);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      for (var i = 0; i < ii1DiscrepanciesMonth3.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorOne.indicatorId,
            entryDiscrepancyId: ii1DiscrepanciesMonth3[i],
            month: 3);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      __entryDataAccuracy.id = $idOne;
      _dataAccuracyTuple2 =
          new EntryDataAccuracyTuple2(entryDataAccuracy: __entryDataAccuracy, entryDataAccuracyDiscrepancy: _entryDataAccuracyDiscrepancies);
      _dataAccuracies.add(_dataAccuracyTuple2);
    }

    SelectedIndicator selectedIndicatorTwo = MrdqaHelpers.getObjectByNumber(_selectedIndicators, 2, 'selected_indicator');
    if (selectedIndicatorTwo != null) {
      __entryDataAccuracy = new EntryDataAccuracy();
      __entryDataAccuracy.supervisionId = widget.selectedSupervision.id;
      __entryDataAccuracy.facilityId = _facilityId;
      __entryDataAccuracy.indicatorId = selectedIndicatorTwo.indicatorId;
      __entryDataAccuracy.sourceDocumentRecount1 = int.parse(ii2SourceDocumentRecount1.text);
      __entryDataAccuracy.sourceDocumentRecount2 = int.parse(ii2SourceDocumentRecount2.text);
      __entryDataAccuracy.sourceDocumentRecount3 = int.parse(ii2SourceDocumentRecount3.text);
      __entryDataAccuracy.sourceDocumentRecountTotal = int.parse(ii2SourceDocumentRecountTotal.text);
      __entryDataAccuracy.sourceDocumentRecountComment = ii2SourceDocumentRecountComment.text;
      __entryDataAccuracy.hmisMonthlyReportValue1 = int.parse(ii2HmisMonthlyReportValue1.text);
      __entryDataAccuracy.hmisMonthlyReportValue2 = int.parse(ii2HmisMonthlyReportValue2.text);
      __entryDataAccuracy.hmisMonthlyReportValue3 = int.parse(ii2HmisMonthlyReportValue3.text);
      __entryDataAccuracy.hmisMonthlyReportValueTotal = int.parse(ii2HmisMonthlyReportValueTotal.text);
      __entryDataAccuracy.hmisMonthlyReportValueComment = ii2HmisMonthlyReportValueComment.text;
      __entryDataAccuracy.dhisMonthlyValue1 = int.parse(ii2DhisMonthlyValue1.text);
      __entryDataAccuracy.dhisMonthlyValue2 = int.parse(ii2DhisMonthlyValue2.text); // int
      __entryDataAccuracy.dhisMonthlyValue3 = int.parse(ii2DhisMonthlyValue3.text);
      __entryDataAccuracy.dhisMonthlyValueTotal = int.parse(ii2DhisMonthlyValueTotal.text);
      __entryDataAccuracy.dhisMonthlyValueComment = ii2DhisMonthlyValueComment.text;
      __entryDataAccuracy.monthlyReportVf1 = double.parse(ii2MonthlyReportVf1.text);
      __entryDataAccuracy.monthlyReportVf2 = double.parse(ii2MonthlyReportVf2.text);
      __entryDataAccuracy.monthlyReportVf3 = double.parse(ii2MonthlyReportVf3.text);
      __entryDataAccuracy.monthlyReportVfTotal = double.parse(ii2MonthlyReportVfTotal.text);
      __entryDataAccuracy.dhisMonthlyValueComment = ii2MonthlyReportVfComment.text;
      __entryDataAccuracy.dhisVf1 = double.parse(ii2DhisVf1.text);
      __entryDataAccuracy.dhisVf2 = double.parse(ii2DhisVf2.text);
      __entryDataAccuracy.dhisVf3 = double.parse(ii2DhisVf3.text);
      __entryDataAccuracy.dhisVfTotal = double.parse(ii2DhisVfTotal.text);
      __entryDataAccuracy.dhisVfComment = ii2DhisVfComment.text;
      __entryDataAccuracy.reasonForDiscrepancyComment = ii2ReasonForDiscrepancyComment.text;
      __entryDataAccuracy.otherReasonForDiscrepancy1 = ii2OtherReasonForDiscrepancy1.text;
      __entryDataAccuracy.otherReasonForDiscrepancy2 = ii2OtherReasonForDiscrepancy2.text;
      __entryDataAccuracy.otherReasonForDiscrepancy3 = ii2OtherReasonForDiscrepancy3.text;
      __entryDataAccuracy.otherReasonForDiscrepancyComment = ii2OtherReasonForDiscrepancyComment.text;
      __entryDataAccuracy.type = 'entry2';

      _discrepancy = EntryDiscrepancies();
      _entryDataAccuracyDiscrepancies = [];
      for (var i = 0; i < ii2DiscrepanciesMonth1.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorTwo.indicatorId,
            entryDiscrepancyId: ii2DiscrepanciesMonth1[i],
            month: 1);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      for (var i = 0; i < ii2DiscrepanciesMonth2.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorTwo.indicatorId,
            entryDiscrepancyId: ii2DiscrepanciesMonth2[i],
            month: 2);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      for (var i = 0; i < ii2DiscrepanciesMonth3.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorTwo.indicatorId,
            entryDiscrepancyId: ii2DiscrepanciesMonth3[i],
            month: 3);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }

      __entryDataAccuracy.id = $idTwo;
      _dataAccuracyTuple2 =
          new EntryDataAccuracyTuple2(entryDataAccuracy: __entryDataAccuracy, entryDataAccuracyDiscrepancy: _entryDataAccuracyDiscrepancies);
      _dataAccuracies.add(_dataAccuracyTuple2);
    }

    SelectedIndicator selectedIndicatorThree = MrdqaHelpers.getObjectByNumber(_selectedIndicators, 3, 'selected_indicator');
    if (selectedIndicatorThree != null) {
      __entryDataAccuracy = new EntryDataAccuracy();
      __entryDataAccuracy.supervisionId = widget.selectedSupervision.id;
      __entryDataAccuracy.facilityId = _facilityId;
      __entryDataAccuracy.indicatorId = selectedIndicatorThree.indicatorId;
      __entryDataAccuracy.sourceDocumentRecount1 = int.parse(ii3SourceDocumentRecount1.text);
      __entryDataAccuracy.sourceDocumentRecount2 = int.parse(ii3SourceDocumentRecount2.text);
      __entryDataAccuracy.sourceDocumentRecount3 = int.parse(ii3SourceDocumentRecount3.text);
      __entryDataAccuracy.sourceDocumentRecountTotal = int.parse(ii3SourceDocumentRecountTotal.text);
      __entryDataAccuracy.sourceDocumentRecountComment = ii3SourceDocumentRecountComment.text;
      __entryDataAccuracy.hmisMonthlyReportValue1 = int.parse(ii3HmisMonthlyReportValue1.text);
      __entryDataAccuracy.hmisMonthlyReportValue2 = int.parse(ii3HmisMonthlyReportValue2.text);
      __entryDataAccuracy.hmisMonthlyReportValue3 = int.parse(ii3HmisMonthlyReportValue3.text);
      __entryDataAccuracy.hmisMonthlyReportValueTotal = int.parse(ii3HmisMonthlyReportValueTotal.text);
      __entryDataAccuracy.hmisMonthlyReportValueComment = ii3HmisMonthlyReportValueComment.text;
      __entryDataAccuracy.dhisMonthlyValue1 = int.parse(ii3DhisMonthlyValue1.text);
      __entryDataAccuracy.dhisMonthlyValue2 = int.parse(ii3DhisMonthlyValue2.text); // int
      __entryDataAccuracy.dhisMonthlyValue3 = int.parse(ii3DhisMonthlyValue3.text);
      __entryDataAccuracy.dhisMonthlyValueTotal = int.parse(ii3DhisMonthlyValueTotal.text);
      __entryDataAccuracy.dhisMonthlyValueComment = ii3DhisMonthlyValueComment.text;
      __entryDataAccuracy.monthlyReportVf1 = double.parse(ii3MonthlyReportVf1.text);
      __entryDataAccuracy.monthlyReportVf2 = double.parse(ii3MonthlyReportVf2.text);
      __entryDataAccuracy.monthlyReportVf3 = double.parse(ii3MonthlyReportVf3.text);
      __entryDataAccuracy.monthlyReportVfTotal = double.parse(ii3MonthlyReportVfTotal.text);
      __entryDataAccuracy.dhisMonthlyValueComment = ii3MonthlyReportVfComment.text;
      __entryDataAccuracy.dhisVf1 = double.parse(ii3DhisVf1.text);
      __entryDataAccuracy.dhisVf2 = double.parse(ii3DhisVf2.text);
      __entryDataAccuracy.dhisVf3 = double.parse(ii3DhisVf3.text);
      __entryDataAccuracy.dhisVfTotal = double.parse(ii3DhisVfTotal.text);
      __entryDataAccuracy.dhisVfComment = ii3DhisVfComment.text;
      __entryDataAccuracy.reasonForDiscrepancyComment = ii3ReasonForDiscrepancyComment.text;
      __entryDataAccuracy.otherReasonForDiscrepancy1 = ii3OtherReasonForDiscrepancy1.text;
      __entryDataAccuracy.otherReasonForDiscrepancy2 = ii3OtherReasonForDiscrepancy2.text;
      __entryDataAccuracy.otherReasonForDiscrepancy3 = ii3OtherReasonForDiscrepancy3.text;
      __entryDataAccuracy.otherReasonForDiscrepancyComment = ii3OtherReasonForDiscrepancyComment.text;
      __entryDataAccuracy.type = 'entry3';

      for (var i = 0; i < ii3DiscrepanciesMonth1.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorThree.indicatorId,
            entryDiscrepancyId: ii3DiscrepanciesMonth1[i],
            month: 1);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      for (var i = 0; i < ii3DiscrepanciesMonth2.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorThree.indicatorId,
            entryDiscrepancyId: ii3DiscrepanciesMonth2[i],
            month: 2);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      for (var i = 0; i < ii3DiscrepanciesMonth3.length; i++) {
        dataAccuracyDiscrepency = new EntryDataAccuracyDiscrepancy(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            indicatorId: selectedIndicatorThree.indicatorId,
            entryDiscrepancyId: ii3DiscrepanciesMonth3[i],
            month: 3);
        configManager.saveRowData('entrydataaccuracydiscrepancy', dataAccuracyDiscrepency);
      }
      __entryDataAccuracy.id = $idThree;
      _dataAccuracyTuple2 =
          new EntryDataAccuracyTuple2(entryDataAccuracy: __entryDataAccuracy, entryDataAccuracyDiscrepancy: _entryDataAccuracyDiscrepancies);
      _dataAccuracies.add(_dataAccuracyTuple2);
    }

    for (var i = 0; i < _dataAccuracies.length; i++) {
      if (_dataAccuracies[i] != null) {
        if (_dataAccuracies[i].entryDataAccuracy.indicatorId != null) {
          if (_dataAccuracies[i].entryDataAccuracy.id != 0 && _dataAccuracies[i].entryDataAccuracy.id != null) {
            configManager.updateRowById('entrydataaccuracy', _dataAccuracies[i].entryDataAccuracy);
          } else {
            configManager.saveRowData('entrydataaccuracy', _dataAccuracies[i].entryDataAccuracy);
          }
        }
      }
    }
    ;
  }

  Future<void> _pushCrossCheckForm() async {
    _discrepancy = EntryDiscrepancies();
    _entryCrossCheckCDiscrepancies = [];
    EntryCrossCheckCDiscrepancies entryCrossCheckCDiscrepancy = new EntryCrossCheckCDiscrepancies();
    var $idOne = _entryCrossCheckAbList[0].id;
    var $idTwo = _entryCrossCheckAbList[1].id;
    _entryCrossCheckAbList = [];

    CrossCheck crossChecksA = MrdqaHelpers.getCrossCheckByType(_crossChecks, 'a');
    if (crossChecksA != null) {
      _entryCrossCheckAb = new EntryCrossCheckAb();
      if ($idOne == 0) {
        _entryCrossCheckAb.supervisionId = widget.selectedSupervision.id;
        _entryCrossCheckAb.facilityId = _facilityId;
        _entryCrossCheckAb.primaryDataSourceId = crossChecksA.primaryDataSourceId;
        _entryCrossCheckAb.secondaryDataSourceId = crossChecksA.secondaryDataSourceId;
      }
      _entryCrossCheckAb.id = $idOne;
      _entryCrossCheckAb.casesSimpledFromPrimary = int.parse(iiiaCasesSimpledFromPrimary.text);
      _entryCrossCheckAb.primaryComment = iiiaPrimaryComment.text;
      _entryCrossCheckAb.correspondingMachingInSecondary = int.parse(iiiaCorrespondingMachingInSecondary.text);
      _entryCrossCheckAb.secondaryComment = iiiaSecondaryComment.text;
      _entryCrossCheckAb.secondaryReliabilityRate = double.parse(iiiaSecondaryReliabilityRate.text);
      _entryCrossCheckAb.reliabilityComment = iiiaReliabilityComment.text;
      _entryCrossCheckAb.type = 'a';
      _entryCrossCheckAbList.add(_entryCrossCheckAb);
    }

    CrossCheck crossChecksB = MrdqaHelpers.getCrossCheckByType(_crossChecks, 'b');
    if (crossChecksB != null) {
      _entryCrossCheckAb = new EntryCrossCheckAb();
      if ($idTwo == 0) {
        _entryCrossCheckAb.supervisionId = widget.selectedSupervision.id;
        _entryCrossCheckAb.facilityId = _facilityId;
        _entryCrossCheckAb.primaryDataSourceId = crossChecksB.primaryDataSourceId;
        _entryCrossCheckAb.secondaryDataSourceId = crossChecksB.secondaryDataSourceId;
      }
      _entryCrossCheckAb.id = $idTwo;
      _entryCrossCheckAb.casesSimpledFromPrimary = int.parse(iiibCasesSimpledFromPrimary.text);
      _entryCrossCheckAb.primaryComment = iiibPrimaryComment.text;
      _entryCrossCheckAb.correspondingMachingInSecondary = int.parse(iiibCorrespondingMachingInSecondary.text);
      _entryCrossCheckAb.secondaryComment = iiibSecondaryComment.text;
      _entryCrossCheckAb.secondaryReliabilityRate = double.parse(iiibSecondaryReliabilityRate.text);
      _entryCrossCheckAb.reliabilityComment = iiibReliabilityComment.text;
      _entryCrossCheckAb.type = 'b';
      _entryCrossCheckAbList.add(_entryCrossCheckAb);
    }

    CrossCheck crossChecksC = MrdqaHelpers.getCrossCheckByType(_crossChecks, 'c');
    if (crossChecksC != null) {
      if (_entryCrossCheckC.id == 0) {
        _entryCrossCheckC.supervisionId = widget.selectedSupervision.id;
        _entryCrossCheckC.facilityId = _facilityId;
        _entryCrossCheckC.primaryDataSourceId = crossChecksC.primaryDataSourceId;
        _entryCrossCheckC.secondaryDataSourceId = crossChecksC.secondaryDataSourceId;
      }
      _entryCrossCheckC.initialStock = int.parse(iiicInitialStock.text);
      _entryCrossCheckC.initialStockComment = iiicInitialStockComment.text;
      _entryCrossCheckC.receivedStock = int.parse(iiicReceivedStock.text);
      _entryCrossCheckC.receivedStockComment = iiicReceivedStockComment.text;
      _entryCrossCheckC.closingStock = int.parse(iiicClosingStock.text);
      _entryCrossCheckC.receivedStockComment = iiicClosingStockComment.text;
      _entryCrossCheckC.usedStock = int.parse(iiicUsedStock.text);
      _entryCrossCheckC.usedStockComment = iiicUsedStockComment.text;
      _entryCrossCheckC.ratio = double.parse(iiicRatio.text);
      _entryCrossCheckC.ratioComment = iiicRatioComment.text;
      _entryCrossCheckC.reasonForDiscrepancyComment = iiicReasonForDiscrepancyComment.text;
      _entryCrossCheckC.otherReasonForDiscrepancy = iiicOtherReasonForDiscrepancy.text;
      _entryCrossCheckC.otherReasonForDiscrepancyComment = iiicOtherReasonForDiscrepancyComment.text;
      configManager.clearRowOfSupervisionFacility('entrycrosscheckcdiscrepancy', widget.selectedSupervision.id, _facilityId);
      for (var i = 0; i < iiicReasonForDiscrepancy.length; i++) {
        entryCrossCheckCDiscrepancy = new EntryCrossCheckCDiscrepancies(
            supervisionId: widget.selectedSupervision.id,
            facilityId: _facilityId,
            primaryDataSourceId: crossChecksC.primaryDataSourceId,
            secondaryDataSourceId: crossChecksC.secondaryDataSourceId,
            entryDiscrepanciesId: iiicReasonForDiscrepancy[i]);
        configManager.saveRowData('entrycrosscheckcdiscrepancy', entryCrossCheckCDiscrepancy);
      }
    }
    for (var i = 0; i < _entryCrossCheckAbList.length; i++) {
      if (_entryCrossCheckAbList[i] != null &&
          _entryCrossCheckAbList[i].primaryDataSourceId != null &&
          _entryCrossCheckAbList[i].secondaryDataSourceId != null) {
        if (_entryCrossCheckAbList[i].id != 0) {
          configManager.updateRowById('entrycrosscheckab', _entryCrossCheckAbList[i]);
        } else {
          configManager.saveRowData('entrycrosscheckab', _entryCrossCheckAbList[i]);
        }
      }
    }
    if (_entryCrossCheckC.primaryDataSourceId != null && _entryCrossCheckC.secondaryDataSourceId != null) {
      if (_entryCrossCheckC.id != 0) {
        configManager.updateRowById('entrycrosscheckc', _entryCrossCheckC);
      } else {
        configManager.saveRowData('entrycrosscheckc', _entryCrossCheckC);
      }
    }
  }

  Future<void> _pushConsistencyOverTimeForm() async {
    _discrepancy = EntryDiscrepancies();
    _entryConsistencyOverTimeDiscrepancies = [];
    EntryConsistencyOverTimeDiscrepancies entryConsistencyOverTimeDiscrepancy = new EntryConsistencyOverTimeDiscrepancies();
    if (_consistencyOverTime != null && _consistencyOverTime.indicatorId != null) {
      if (_entryConsistencyOverTime.id == 0) {
        _entryConsistencyOverTime.supervisionId = widget.selectedSupervision.id;
        _entryConsistencyOverTime.facilityId = _facilityId;
        _entryConsistencyOverTime.indicatorId = _consistencyOverTime.indicatorId;
      }
      _entryConsistencyOverTime.currentMonthValue = double.parse(ivCurrentMonthValue.text);
      _entryConsistencyOverTime.currentMonthValueComment = ivCurrentMonthValueComment.text;
      _entryConsistencyOverTime.currentMonthYearAgoValue = double.parse(ivCurrentMonthYearAgoValue.text);
      _entryConsistencyOverTime.currentMonthYearAgoValueComment = ivCurrentMonthYearAgoValueComment.text;
      _entryConsistencyOverTime.annualRatio = double.parse(ivAnnualRatio.text);
      _entryConsistencyOverTime.annualRatioComment = ivAnnualRatioComment.text;
      _entryConsistencyOverTime.monthToMonthValue1 = double.parse(ivMonthToMonthValue1.text);
      _entryConsistencyOverTime.monthToMonthValue2 = double.parse(ivMonthToMonthValue2.text);
      _entryConsistencyOverTime.monthToMonthValue3 = double.parse(ivMonthToMonthValue3.text);
      _entryConsistencyOverTime.monthToMonthValueLastMonth = double.parse(ivMonthToMonthValueLastMonth.text);
      _entryConsistencyOverTime.monthToMonthRatio = double.parse(ivMonthToMonthRatio.text);
      _entryConsistencyOverTime.monthToMonthRatioComment = ivMonthToMonthRatioComment.text;
      _entryConsistencyOverTime.reasonForDiscrepancyComment = ivReasonForDiscrepancyComment.text;
      _entryConsistencyOverTime.otherReasonForDiscrepancy = ivOtherReasonForDiscrepancy.text;
      _entryConsistencyOverTime.otherReasonForDiscrepancyComment = ivOtherReasonForDiscrepancyComment.text;
      configManager.clearRowOfSupervisionFacility('entryconsistencyovertimediscrepancy', widget.selectedSupervision.id, _facilityId);
      for (int i = 0; i < ivReasonForDiscrepancy.length; i++) {
        entryConsistencyOverTimeDiscrepancy = new EntryConsistencyOverTimeDiscrepancies(
            supervisionId: widget.selectedSupervision.id, facilityId: _facilityId, entryDiscrepanciesId: ivReasonForDiscrepancy[i]);
        configManager.saveRowData('entryconsistencyovertimediscrepancy', entryConsistencyOverTimeDiscrepancy);
      }

      if (_entryConsistencyOverTime.id != 0) {
        configManager.updateRowById('entryconsistencyovertime', _entryConsistencyOverTime);
      } else {
        configManager.saveRowData('entryconsistencyovertime', _entryConsistencyOverTime);
      }
    }
  }

  Future<void> _pushSystemAssesmentForm() async {
    if (_entrySystemAssessment.id == 0) {
      _entrySystemAssessment.supervisionId = widget.selectedSupervision.id;
      _entrySystemAssessment.facilityId = _facilityId;
    }
    _entrySystemAssessment.questionV1 = vQuestionV1.text;
    _entrySystemAssessment.questionV1Comment = vQuestionV1Comment.text;
    _entrySystemAssessment.questionV2 = vQuestionV2.text;
    _entrySystemAssessment.questionV2Comment = vQuestionV2Comment.text;
    _entrySystemAssessment.questionV3 = vQuestionV3.text;
    _entrySystemAssessment.questionV3Comment = vQuestionV3Comment.text;
    _entrySystemAssessment.questionV4 = vQuestionV4.text;
    _entrySystemAssessment.questionV4Comment = vQuestionV4Comment.text;
    _entrySystemAssessment.questionV5 = vQuestionV5.text;
    _entrySystemAssessment.questionV5Comment = vQuestionV5Comment.text;
    _entrySystemAssessment.questionV6 = vQuestionV6.text;
    _entrySystemAssessment.questionV6Comment = vQuestionV6Comment.text;
    _entrySystemAssessment.questionV7 = vQuestionV7.text;
    _entrySystemAssessment.questionV7Comment = vQuestionV7Comment.text;
    _entrySystemAssessment.questionV8 = vQuestionV8.text;
    _entrySystemAssessment.questionV8Comment = vQuestionV8Comment.text;
    _entrySystemAssessment.questionV9 = vQuestionV9.text;
    _entrySystemAssessment.questionV9Comment = vQuestionV9Comment.text;
    _entrySystemAssessment.questionV10 = vQuestionV10.text;
    _entrySystemAssessment.questionV10Comment = vQuestionV10Comment.text;
    _entrySystemAssessment.questionV11 = vQuestionV11.text;
    _entrySystemAssessment.questionV11Comment = vQuestionV11Comment.text;
    _entrySystemAssessment.questionV12 = vQuestionV12.text;
    _entrySystemAssessment.questionV12Comment = vQuestionV12Comment.text;
    _entrySystemAssessment.systemReadiness = double.parse(systemReadiness.text);
    if (_entrySystemAssessment.id != 0) {
      configManager.updateRowById('entrysystemassessment', _entrySystemAssessment);
    } else {
      configManager.saveRowData('entrysystemassessment', _entrySystemAssessment);
    }
  }
}
