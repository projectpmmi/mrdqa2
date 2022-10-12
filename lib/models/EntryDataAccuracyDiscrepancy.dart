class EntryDataAccuracyDiscrepancy {
  EntryDataAccuracyDiscrepancy(
      {this.id, this.supervisionId, this.facilityId, this.indicatorId, this.entryDiscrepancyId, this.month});

  final int id;
  final int supervisionId;
  final int facilityId;
  final int indicatorId;
  final int entryDiscrepancyId;
  final int month;

  @override
  String toString() {
    return 'Data accuracy discrepency: supervisionId: $supervisionId, facilityId: $facilityId, indicatorId: $indicatorId, '
        'entryDiscrepancyId: $entryDiscrepancyId, month: $month';
  }
}
