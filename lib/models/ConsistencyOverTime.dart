class ConsistencyOverTime{
  ConsistencyOverTime({this.id, this.indicatorId, this.moe, this.supervisionId});
  final int id;
  final int indicatorId;
  final int moe;
  final int supervisionId;

  @override
  String toString() {
    return 'Consistency Over Time: id: $id, indicatorId: $indicatorId, supervisionId: $supervisionId';
  }
}