class EntryConsistencyOverTimeDiscrepancies {
  EntryConsistencyOverTimeDiscrepancies(
      {this.id, this.supervisionId, this.facilityId, this.entryDiscrepanciesId});

  final int id;
  final int supervisionId;
  final int facilityId;
  final int entryDiscrepanciesId;

  @override
  String toString() {
    return 'EntryConsistencyOverTimeDiscrepancies: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, entryDiscrepanciesId: $entryDiscrepanciesId';
  }
}
