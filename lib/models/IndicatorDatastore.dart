import 'CrossCheckDatastore.dart';

class IndicatorDatastore{
  int consistency;
  Map<String, List> completeness;
  Map<String, CrossCheckDatastore> crossChecks;
  List<int> dataAccuracy;

  IndicatorDatastore(this.consistency, this.completeness, this.crossChecks, this.dataAccuracy);
  Map<String, dynamic> toJson() => {
    "consistency": consistency,
    "completeness": completeness,
    "cross_checks": crossChecks,
    "data_accuracy": dataAccuracy,
  };
}