import 'package:mrdqa_tool/models/IndicatorDatastore.dart';
import 'package:mrdqa_tool/models/PlanningDatastore.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/models/Visit.dart';
import 'package:mrdqa_tool/models/DataElementCompleteness.dart';
import 'package:mrdqa_tool/models/SourceDocumentCompleteness.dart';
import 'package:mrdqa_tool/models/ConsistencyOverTime.dart';
import 'package:mrdqa_tool/models/CrossCheck.dart';
import 'package:mrdqa_tool/models/SelectedIndicator.dart';
import 'package:mrdqa_tool/models/CrossCheckDatastore.dart';

class DatastorePayload {
  Supervision supervision;
  Map<String, Visit> visits;
  List<DataElementCompleteness> dataElementCompleteness;
  List<SourceDocumentCompleteness> sourceDocumentCompleteness;
  ConsistencyOverTime consistencyOverTime;
  List<CrossCheck> crossChecks;
  List<SelectedIndicator> selectedIndicator;
  List<int> sectionPlanning;
  List<int> periodPlanning;

  DatastorePayload(
      this.supervision,
      this.visits,
      this.dataElementCompleteness,
      this.sourceDocumentCompleteness,
      this.consistencyOverTime,
      this.crossChecks,
      this.selectedIndicator,
      this.sectionPlanning,
      this.periodPlanning);

  Map<String, dynamic> toJson() {
    return {
        "name": "${supervision.description}",
        "period": "${supervision.period}",
        "supervisions": toSupervisionsJson(),
        "facilities": visits.keys.toList(),
        "supervisionsection": sectionPlanning,
        "supervisionperiod": periodPlanning,
        "indicators": {
          "completeness": {"data_element": toDataElementJson(), "source_document": toSourceDocumentJson()},
          "consistency": consistencyOverTime.indicatorId,
          "cross_checks": toCrossChecksJson(),
          "data_accuracy": toDataAccuracyJson()
        },

    };
  }

  List<Map<String, String>> toSupervisionsJson() {
    List<Map<String, String>> supervisionJson;
    PlanningDatastore planningDatastore;
    Map<String, dynamic> visit;

    for (var k in visits.keys) {
      planningDatastore = PlanningDatastore(k, visits[k].date.toString(), visits[k].teamLead);
      visit = planningDatastore.toJson();
      if (supervisionJson != null) {
        supervisionJson.add(visit);
      } else {
        supervisionJson = [visit];
      }
    }

    return supervisionJson;
  }

  Map<String, int> toDataElementJson() {
    Map<String, int> dataelementJson;

    for (var d in dataElementCompleteness) {
      if (dataelementJson != null) {
        dataelementJson.addAll(d.toJson());
      } else {
        dataelementJson = d.toJson();
      }
    }

    return dataelementJson;
  }

  Map<String, int> toSourceDocumentJson() {
    Map<String, int> sourceDocumentJson;

    for (var d in sourceDocumentCompleteness) {
      if (sourceDocumentJson != null) {
        sourceDocumentJson.addAll(d.toJson());
      } else {
        sourceDocumentJson = d.toJson();
      }
    }

    return sourceDocumentJson;
  }

  Map<String, dynamic> toCrossChecksJson() {
    Map<String, Map<String, dynamic>> crossChecksJson;
    CrossCheckDatastore crossCheckDatastore;

    for (var p in crossChecks) {
      crossCheckDatastore = CrossCheckDatastore(p.primaryDataSourceId, p.secondaryDataSourceId);
      if (crossChecksJson != null) {
        crossChecksJson["${p.type}"] = crossCheckDatastore.toJson();
      } else {
        crossChecksJson = {"${p.type}": crossCheckDatastore.toJson()};
      }
    }

    return crossChecksJson;
  }

  Map<String, int> toDataAccuracyJson() {
    Map<String, int> dataAccuracyJson;

    for (var k in selectedIndicator) {
      if (dataAccuracyJson != null) {
        dataAccuracyJson.addAll(k.toJson());
      } else {
        dataAccuracyJson = k.toJson();
      }
    }

    return dataAccuracyJson;
  }
}
