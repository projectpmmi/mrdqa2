class CrossCheck{
  CrossCheck({this.id, this.primaryDataSourceId, this.secondaryDataSourceId, this.moe, this.supervisionId, this.type});
  final int id;
  final int primaryDataSourceId;
  final int secondaryDataSourceId;
  final int moe;
  final int supervisionId;
  final String type; // a, b, c

  @override
  String toString() {
    return 'Cross check: id: $id, primaryDataSourceId: $primaryDataSourceId, secondaryDataSourceId: $secondaryDataSourceId, supervisionId: $supervisionId, type: $type';
  }
}