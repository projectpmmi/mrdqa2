class EntryCompletenessMonthlyReport{
  EntryCompletenessMonthlyReport({this.id, this.supervisionId, this.facilityId, this.expectedCells, this.completedCells, this.percent, this.comment});
  int id;
  int supervisionId;
  int facilityId;
  int expectedCells;
  int completedCells;
  double percent;
  String comment;

  @override
  String toString() {
    return 'EntryCompletenessMonthlyReport: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, percent: $percent';
  }
}