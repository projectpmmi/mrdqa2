class VisitControllersTuple2 {
  VisitControllersTuple2({this.nameTeamLead, this.dateVisit, this.status, this.visitId});

  String nameTeamLead;
  DateTime dateVisit;
  String status;
  int visitId;

  @override
  String toString() {
    return 'Controller: Name: $nameTeamLead, Date: $dateVisit, status: $status, VisitId: $visitId';
  }
}