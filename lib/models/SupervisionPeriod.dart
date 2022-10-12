class SupervisionPeriod {
  SupervisionPeriod({this.id, this.supervisionId, this.periodNumber});

  final int id;
  final int supervisionId;
  final int periodNumber; // Use the number instead of the id

  @override
  String toString() {
    return 'Supervision period: id: $id, number: $supervisionId, periodNumber: $periodNumber';
  }
}