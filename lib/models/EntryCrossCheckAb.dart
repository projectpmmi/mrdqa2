class EntryCrossCheckAb {
  EntryCrossCheckAb(
      {this.id,
      this.supervisionId,
      this.facilityId,
      this.primaryDataSourceId,
      this.secondaryDataSourceId,
      this.casesSimpledFromPrimary,
      this.primaryComment,
      this.correspondingMachingInSecondary,
      this.secondaryComment,
      this.secondaryReliabilityRate,
      this.reliabilityComment,
      this.type});

  int id;
  int supervisionId;
  int facilityId;
  int primaryDataSourceId;
  int secondaryDataSourceId;
  int casesSimpledFromPrimary;
  String primaryComment;
  int correspondingMachingInSecondary;
  String secondaryComment;
  double secondaryReliabilityRate;
  String reliabilityComment;
  String type; // a, b

  @override
  String toString() {
    return 'EntryCrossCheckAb: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, primaryDataSourceId: $primaryDataSourceId, secondaryDataSourceId: $secondaryDataSourceId, secondaryReliabilityRate: $secondaryReliabilityRate';
  }
}
