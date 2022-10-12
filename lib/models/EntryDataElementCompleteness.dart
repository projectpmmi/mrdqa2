class EntryDataElementCompleteness {
  EntryDataElementCompleteness({this.id, this.supervisionId, this.facilityId, this.dataElementId, this.missingCasesData, this.percent, this.type});

  int id;
  int supervisionId;
  int facilityId;
  int dataElementId;
  int missingCasesData;
  double percent;
  String type; //entry1 or entry2.../missing/total create table to insert missing and total or use a variable for these two.
// Put supervision id when it's missing or total.

  @override
  String toString() {
    return 'Entry Data Element: id: $id, supervisionid: $supervisionId, facilityid: $facilityId, dataElementId: $dataElementId, missingCasesData: $missingCasesData';
  }
}
