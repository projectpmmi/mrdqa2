class SupervisionIndicators{
  SupervisionIndicators({this.id, this.supervisionId, this.indicatorId, this.type});
  final int id;
  final int supervisionId;
  final String indicatorId;
  final String type; //Either indicator, Data element or Data Source to avoid having three tables.
}