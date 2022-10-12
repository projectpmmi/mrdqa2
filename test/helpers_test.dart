// Import the test package and Counter class
import 'package:mrdqa_tool/helpers/MrdqaHelpers.dart';
import 'package:mrdqa_tool/models/CrossCheck.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:mrdqa_tool/models/EntryDataAccuracyDiscrepancy.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/SourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/Periods.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Object by number', () {
  test('Get a period based on a number', () {
    // todo add it in texture or add factories and fakes
    List<Periods> periods = [
      new Periods(id: 1, number: 1, description: 'January'),
      new Periods(id: 2, number: 2, description: 'February'),
      new Periods(id: 3, number: 3, description: 'March'),
      new Periods(id: 4, number: 4, description: 'April'),
      new Periods(id: 5, number: 5, description: 'May'),
      new Periods(id: 6, number: 6, description: 'June'),
      new Periods(id: 7, number: 7, description: 'July'),
      new Periods(id: 8, number: 8, description: 'August'),
      new Periods(id: 9, number: 9, description: 'September'),
      new Periods(id: 10, number: 10, description: 'October'),
      new Periods(id: 11, number: 11, description: 'November'),
      new Periods(id: 12, number: 12, description: 'December'),
    ];

    expect(MrdqaHelpers.getObjectByNumber(periods, 1, 'period'), periods[0]);
    expect(MrdqaHelpers.getObjectByNumber(periods, 5, 'period'), periods[4]);
    expect(MrdqaHelpers.getObjectByNumber(periods, 0, 'period'), periods[11]);
    expect(MrdqaHelpers.getObjectByNumber(periods, -2, 'period'), periods[9]);
    expect(MrdqaHelpers.getObjectByNumber(periods, -4, 'period'), periods[7]);
    expect(MrdqaHelpers.getObjectByNumber(periods, 13, 'period'), isNull);
    expect(MrdqaHelpers.getObjectByNumber(periods, -5, 'period'), isNull);
  });

  test('Get a selected indicator based on the number', () {
    List<SelectedIndicator> selectedIndicators = [
      new SelectedIndicator(id: 1, indicatorId: 1, number: 1, supervisionId: 1),
      new SelectedIndicator(id: 2, indicatorId: 2, number: 2, supervisionId: 1),
      new SelectedIndicator(id: 3, indicatorId: 3, number: 3, supervisionId: 2),
      new SelectedIndicator(id: 4, indicatorId: 4, number: 4, supervisionId: 2),
      new SelectedIndicator(id: 5, indicatorId: 5, number: 5, supervisionId: 2),
      new SelectedIndicator(id: 6, indicatorId: 6, number: 6, supervisionId: 3),
      new SelectedIndicator(id: 7, indicatorId: 7, number: 7, supervisionId: 4),
    ];

    expect(MrdqaHelpers.getObjectByNumber(selectedIndicators, 1, 'selected_indicator'), selectedIndicators[0]);
    expect(MrdqaHelpers.getObjectByNumber(selectedIndicators, 3, 'selected_indicator'), selectedIndicators[2]);
    expect(MrdqaHelpers.getObjectByNumber(selectedIndicators, 5, 'selected_indicator'), selectedIndicators[4]);
    expect(MrdqaHelpers.getObjectByNumber(selectedIndicators, 7, 'selected_indicator'), selectedIndicators[6]);
    expect(MrdqaHelpers.getObjectByNumber(selectedIndicators, 10, 'selected_indicator'), isNull);
  });

  test('Get data element by number', () {
    List<DataElementCompleteness> dataElementCompleteness = [
      new DataElementCompleteness(id: 1, dataElementId: 1, number: 1, supervisionId: 1),
      new DataElementCompleteness(id: 1, dataElementId: 1, number: 2, supervisionId: 1),
      new DataElementCompleteness(id: 1, dataElementId: 1, number: 3, supervisionId: 1),
      new DataElementCompleteness(id: 1, dataElementId: 1, number: 4, supervisionId: 1),
      new DataElementCompleteness(id: 1, dataElementId: 1, number: 5, supervisionId: 1),
      new DataElementCompleteness(id: 1, dataElementId: 1, number: 6, supervisionId: 1),
    ];

    expect(MrdqaHelpers.getObjectByNumber(dataElementCompleteness, 2, 'de_completeness'), dataElementCompleteness[1]);
    expect(MrdqaHelpers.getObjectByNumber(dataElementCompleteness, 4, 'de_completeness'), dataElementCompleteness[3]);
    expect(MrdqaHelpers.getObjectByNumber(dataElementCompleteness, 6, 'de_completeness'), dataElementCompleteness[5]);
    expect(MrdqaHelpers.getObjectByNumber(dataElementCompleteness, 8, 'de_completeness'), isNull);
  });

  test('Get source document by number', () {
    List<SourceDocumentCompleteness> sourceDocumentCompleteness = [
      new SourceDocumentCompleteness(id: 1, sourceDocumentId: 1, number: 1, supervisionId: 1),
      new SourceDocumentCompleteness(id: 1, sourceDocumentId: 1, number: 2, supervisionId: 1),
      new SourceDocumentCompleteness(id: 1, sourceDocumentId: 1, number: 3, supervisionId: 1),
      new SourceDocumentCompleteness(id: 1, sourceDocumentId: 1, number: 4, supervisionId: 1),
      new SourceDocumentCompleteness(id: 1, sourceDocumentId: 1, number: 5, supervisionId: 1),
      new SourceDocumentCompleteness(id: 1, sourceDocumentId: 1, number: 6, supervisionId: 1),
    ];

    expect(MrdqaHelpers.getObjectByNumber(sourceDocumentCompleteness, 2, 'sd_completeness'), sourceDocumentCompleteness[1]);
    expect(MrdqaHelpers.getObjectByNumber(sourceDocumentCompleteness, 4, 'sd_completeness'), sourceDocumentCompleteness[3]);
    expect(MrdqaHelpers.getObjectByNumber(sourceDocumentCompleteness, 6, 'sd_completeness'), sourceDocumentCompleteness[5]);
    expect(MrdqaHelpers.getObjectByNumber(sourceDocumentCompleteness, 8, 'sd_completeness'), isNull);
  });
  });

  test('Get Cross checks by type', () {
    List<CrossCheck> crossChecks = [
      new CrossCheck(id: 1, primaryDataSourceId: 1, secondaryDataSourceId: 2, moe: 2, supervisionId: 1, type: 'a'),
      new CrossCheck(id: 1, primaryDataSourceId: 1, secondaryDataSourceId: 2, moe: 2, supervisionId: 1, type: 'b'),
      new CrossCheck(id: 1, primaryDataSourceId: 1, secondaryDataSourceId: 2, moe: 2, supervisionId: 1, type: 'c'),
    ];

    expect(MrdqaHelpers.getCrossCheckByType(crossChecks, 'a'), crossChecks[0]);
    expect(MrdqaHelpers.getCrossCheckByType(crossChecks, 'b'), crossChecks[1]);
    expect(MrdqaHelpers.getCrossCheckByType(crossChecks, 'c'), crossChecks[2]);
    expect(MrdqaHelpers.getCrossCheckByType(crossChecks, 'd'), isNull);
  });

  group('Get object by id', () {
    test('Get period', () {
      List<Periods> periods = [
        new Periods(id: 1, number: 1, description: 'January'),
        new Periods(id: 2, number: 2, description: 'February'),
        new Periods(id: 3, number: 3, description: 'March'),
        new Periods(id: 4, number: 4, description: 'April'),
        new Periods(id: 5, number: 5, description: 'May'),
        new Periods(id: 6, number: 6, description: 'June'),
        new Periods(id: 7, number: 7, description: 'July'),
        new Periods(id: 8, number: 8, description: 'August'),
        new Periods(id: 9, number: 9, description: 'September'),
        new Periods(id: 10, number: 10, description: 'October'),
        new Periods(id: 11, number: 11, description: 'November'),
        new Periods(id: 12, number: 12, description: 'December'),
      ];

      expect(MrdqaHelpers.getObjectById(periods, 2, 'period'), periods[1]);
      expect(MrdqaHelpers.getObjectById(periods, 5, 'period'), periods[4]);
      expect(MrdqaHelpers.getObjectById(periods, 11, 'period'), periods[10]);
      expect(MrdqaHelpers.getObjectById(periods, 20, 'period'), isNull);
    });

    test('Get data element', () {
      List<DataElement> dataElements = [
        new DataElement(id: 1, uid: 'ueidbsgx0', name: 'Data element one', isDhisDataElement: true, code: 'DATA_ELEMENT_ONE'),
        new DataElement(id: 2, uid: 'ueidbsgx0', name: 'Data element two', isDhisDataElement: true, code: 'DATA_ELEMENT_ONE'),
        new DataElement(id: 3, uid: 'ueidbsgx0', name: 'Data element three', isDhisDataElement: true, code: 'DATA_ELEMENT_ONE'),
        new DataElement(id: 4, uid: 'ueidbsgx0', name: 'Data element four', isDhisDataElement: true, code: 'DATA_ELEMENT_ONE'),
        new DataElement(id: 5, uid: 'ueidbsgx0', name: 'Data element five', isDhisDataElement: true, code: 'DATA_ELEMENT_ONE'),
      ];

      expect(MrdqaHelpers.getObjectById(dataElements, 1, 'data_element'), dataElements[0]);
      expect(MrdqaHelpers.getObjectById(dataElements, 4, 'data_element'), dataElements[3]);
      expect(MrdqaHelpers.getObjectById(dataElements, 5, 'data_element'), dataElements[4]);
      expect(MrdqaHelpers.getObjectById(dataElements, 20, 'data_element'), isNull);
    });

    test('Get indicator', () {
      List<Indicator> indicators = [
        new Indicator(id: 1, uid: 'ueidbsgx0', name: 'Indicator one', isDhisDataElement: true),
        new Indicator(id: 2, uid: 'ueidbsgx0', name: 'Indicator two', isDhisDataElement: true),
        new Indicator(id: 3, uid: 'ueidbsgx0', name: 'Indicator three', isDhisDataElement: true),
        new Indicator(id: 4, uid: 'ueidbsgx0', name: 'Indicator four', isDhisDataElement: true),
        new Indicator(id: 5, uid: 'ueidbsgx0', name: 'Indicator five', isDhisDataElement: true),
      ];

      expect(MrdqaHelpers.getObjectById(indicators, 1, 'indicator'), indicators[0]);
      expect(MrdqaHelpers.getObjectById(indicators, 4, 'indicator'), indicators[3]);
      expect(MrdqaHelpers.getObjectById(indicators, 5, 'indicator'), indicators[4]);
      expect(MrdqaHelpers.getObjectById(indicators, 20, 'indicator'), isNull);
    });

    test('Get source document', () {
      List<SourceDocument> sourceDocumets = [
        new SourceDocument(id: 1, uid: 'ueidbsgx0', name: 'Source document one'),
        new SourceDocument(id: 2, uid: 'ueidbsgx0', name: 'Source document two'),
        new SourceDocument(id: 3, uid: 'ueidbsgx0', name: 'Source document three'),
        new SourceDocument(id: 4, uid: 'ueidbsgx0', name: 'Source document four'),
        new SourceDocument(id: 5, uid: 'ueidbsgx0', name: 'Source document five'),
      ];

      expect(MrdqaHelpers.getObjectById(sourceDocumets, 1, 'source_document'), sourceDocumets[0]);
      expect(MrdqaHelpers.getObjectById(sourceDocumets, 4, 'source_document'), sourceDocumets[3]);
      expect(MrdqaHelpers.getObjectById(sourceDocumets, 5, 'source_document'), sourceDocumets[4]);
      expect(MrdqaHelpers.getObjectById(sourceDocumets, 20, 'source_document'), isNull);
    });
  });

  test('Get selected facilities', () {
    List<Facility> facilities = [
      new Facility(id: 1, uid: 'ui45bg8s00w', name: 'Facility one', isDhisFacility: true),
      new Facility(id: 2, uid: 'ui45bg8s00w', name: 'Facility two', isDhisFacility: true),
      new Facility(id: 3, uid: 'ui45bg8s00w', name: 'Facility three', isDhisFacility: true),
      new Facility(id: 4, uid: 'ui45bg8s00w', name: 'Facility four', isDhisFacility: true),
      new Facility(id: 5, uid: 'ui45bg8s00w', name: 'Facility five', isDhisFacility: true)
    ];

    List<SupervisionFacilities> supervisionFacilities = [
      new SupervisionFacilities(id: 1, supervisionId: 1, facilityId: 1),
      new SupervisionFacilities(id: 2, supervisionId: 1, facilityId: 3),
      new SupervisionFacilities(id: 3, supervisionId: 1, facilityId: 5),
      new SupervisionFacilities(id: 4, supervisionId: 1, facilityId: 10),
    ];

    expect(MrdqaHelpers.getSelectedFacilities(facilities, supervisionFacilities).length, 3);
    expect(MrdqaHelpers.getSelectedFacilities(facilities, supervisionFacilities)[1].name, 'Facility three');


  });

  test('Get a month discrepencies', () {
    List<EntryDataAccuracyDiscrepancy> discrepanciesList = [
      new EntryDataAccuracyDiscrepancy(id: 1, supervisionId: 1, facilityId: 1, indicatorId: 1, entryDiscrepancyId: 1, month: 1),
      new EntryDataAccuracyDiscrepancy(id: 2, supervisionId: 1, facilityId: 1, indicatorId: 1, entryDiscrepancyId: 2, month: 2),
      new EntryDataAccuracyDiscrepancy(id: 3, supervisionId: 1, facilityId: 1, indicatorId: 1, entryDiscrepancyId: 2, month: 1),
      new EntryDataAccuracyDiscrepancy(id: 4, supervisionId: 1, facilityId: 1, indicatorId: 1, entryDiscrepancyId: 4, month: 2),
      new EntryDataAccuracyDiscrepancy(id: 5, supervisionId: 1, facilityId: 1, indicatorId: 1, entryDiscrepancyId: 3, month: 2),
    ];

    expect(MrdqaHelpers.getMonthDiscrepancies(discrepanciesList, 1).length, 2);
    expect(MrdqaHelpers.getMonthDiscrepancies(discrepanciesList, 2).length, 3);
    expect(MrdqaHelpers.getMonthDiscrepancies(discrepanciesList, 2)[1], 4);
  });

}