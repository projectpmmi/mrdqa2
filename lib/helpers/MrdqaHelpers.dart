import 'package:mrdqa_tool/models/CrossCheck.dart';
import 'package:mrdqa_tool/models/EntryDataAccuracyDiscrepancy.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:mrdqa_tool/models/Periods.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:mrdqa_tool/models/SourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/DataElement.dart';
import 'package:mrdqa_tool/models/Indicator.dart';
import 'package:mrdqa_tool/models/SourceDocument.dart';
import 'package:mrdqa_tool/models/SupervisionFacilities.dart';

class MrdqaHelpers {
  static dynamic getObjectByNumber(dynamic list, number, objectType) {
    switch (objectType) {
      case 'period':
        Periods period = new Periods();
        if (number == 0)
          number = 12;
        else if (number == -1)
          number = 11;
        else if (number == -2)
          number = 10;
        else if (number == -3)
          number = 9;
        else if (number == -4) number = 8;
        period = list.firstWhere((element) => element.number == number, orElse: () => null);

        return period;
        break;

      case 'selected_indicator':
        SelectedIndicator selectedIndicator = new SelectedIndicator();
        selectedIndicator = list.firstWhere((element) => element.number == number, orElse: () => null);

        return selectedIndicator;
        break;

      case 'de_completeness':
        DataElementCompleteness dataElementCompleteness = new DataElementCompleteness();
        dataElementCompleteness = list.firstWhere((element) => element.number == number, orElse: () => null);

        return dataElementCompleteness;
        break;

      case 'sd_completeness':
        SourceDocumentCompleteness sourceDocumentCompleteness = new SourceDocumentCompleteness();
        sourceDocumentCompleteness = list.firstWhere((element) => element.number == number, orElse: () => null);

        return sourceDocumentCompleteness;
        break;
    }
  }

  static   CrossCheck getCrossCheckByType(List<CrossCheck> crossChecks, type) {
    CrossCheck crossCheck = new CrossCheck();
    crossCheck = crossChecks.firstWhere((element) => element.type == type, orElse: () => null);

    return crossCheck;
  }

  static dynamic getObjectById(dynamic list, int id, String objectType) {
    switch (objectType) {
      case 'period':
        Periods period = new Periods();
        period = list.firstWhere((element) => element.id == id, orElse: () => null);

        return period;
        break;

      case 'data_element':
        DataElement dataElement = new DataElement();
        dataElement = list.firstWhere((element) => element.id == id, orElse: () => null);

        return dataElement;
        break;

      case 'indicator':
        Indicator indicator = new Indicator();
        indicator = list.firstWhere((element) => element.id == id, orElse: () => null);

        return indicator;
        break;

      case 'source_document':
        SourceDocument sourceDocument = new SourceDocument();
        sourceDocument = list.firstWhere((element) => element.id == id, orElse: () => null);

        return sourceDocument;
        break;
    }
  }

  static List<Facility> getSelectedFacilities(List<Facility> facilities, List<SupervisionFacilities> supervisionFacilities) {
    List<Facility> result = [];

    supervisionFacilities.forEach((sup) {
      facilities.forEach((fac) {
        if (fac.id == sup.facilityId) {
          result.add(fac);
        }
      });
    });

    return result;
  }

  static   List<int> getMonthDiscrepancies(List<EntryDataAccuracyDiscrepancy> discrepanciesList, int month) {
    List<int> result = [];
    for (var i = 0; i < discrepanciesList.length; i++) {
      if (discrepanciesList[i].month == month) {
        result.add(discrepanciesList[i].entryDiscrepancyId);
      }
    }

    return result;
  }
}
