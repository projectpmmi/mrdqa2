class SupervisionSection {
  SupervisionSection({this.id, this.supervisionId, this.sectionNumber});

  final int id;
  final int supervisionId;
  final int sectionNumber; // Use the number instead of the id

  @override
  String toString() {
    return 'Supervision section: id: $id, number: $supervisionId, sectionNumber: $sectionNumber';
  }
}