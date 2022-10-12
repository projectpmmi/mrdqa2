class DataElementCompleteness{
  DataElementCompleteness({this.id, this.dataElementId, this.number, this.supervisionId});
  int id;
  int dataElementId;
  int number; // 1, 2...6
  int supervisionId;

  @override
  String toString() {
    return 'Data Element completeness: id: $id, dataElementId: $dataElementId, number: $number, supervisionId: $supervisionId';
  }

  Map<String, int> toJson() => {
    "$number": dataElementId
  };
}