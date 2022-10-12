import '../models/EntryConsistencyOverTime.dart';
import '../models/EntryConsistencyOverTimeDiscrepancies.dart';

class EntryConsistencyOverTimeTuple2 {
  EntryConsistencyOverTimeTuple2({this.entryConsistencyOverTime, this.entryConsistencyOverTimeDiscrepancies});

  EntryConsistencyOverTime entryConsistencyOverTime;
  List<EntryConsistencyOverTimeDiscrepancies> entryConsistencyOverTimeDiscrepancies;
}