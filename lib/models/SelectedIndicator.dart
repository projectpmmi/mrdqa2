class SelectedIndicator{
  SelectedIndicator({this.id, this.indicatorId, this.number, this.supervisionId});
  int id;
  int indicatorId;
  int number;
  int supervisionId;

  @override
  String toString() {
    return 'Selected indicator: id: $id, indicatorId: $indicatorId, number: $number, supervisionId: $supervisionId';
  }

  Map<String, int> toJson() => {
    "$number": indicatorId
  };
}