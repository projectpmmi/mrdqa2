class EntryTimelinessMonthlyReport {
  EntryTimelinessMonthlyReport(
      {this.id, this.supervisionId, this.facilityId, this.submittedMonth1, this.submittedMonth2, this.submittedMonth3, this.percent, this.comment});

  int id;
  int supervisionId;
  int facilityId;
  int submittedMonth1;
  int submittedMonth2;
  int submittedMonth3;
  double percent;
  String comment;

  @override
  String toString() {
    return 'EntryTimelinessMonthlyReport: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, submittedMonth1: $submittedMonth1, submittedMonth2: $submittedMonth2, submittedMonth3: $submittedMonth3, percent: $percent';
  }
}
