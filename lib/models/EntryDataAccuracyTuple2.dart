import '../models/EntryDataAccuracy.dart';
import '../models/EntryDataAccuracyDiscrepancy.dart';

class EntryDataAccuracyTuple2 {
  EntryDataAccuracyTuple2({this.entryDataAccuracy, this.entryDataAccuracyDiscrepancy});

  EntryDataAccuracy entryDataAccuracy;
  List<EntryDataAccuracyDiscrepancy> entryDataAccuracyDiscrepancy;
}