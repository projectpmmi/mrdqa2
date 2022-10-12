class SupervisionFacilities{
  SupervisionFacilities({this.id, this.supervisionId, this.facilityId});
  final int id;
  final int supervisionId;
  final int facilityId;

  @override
  String toString() {
    return 'id: $id, Supervision id: $supervisionId facility id: $facilityId';
  }
}