class Visit{
  Visit({this.id, this.supervisionId, this.facilityId, this.date, this.teamLead, this.status});
  int id;
  int supervisionId;
  int facilityId;
  DateTime date;
  String teamLead;
  String status;

  @override
  String toString() {
    return 'Visit: id: $id, supervisionid: $supervisionId, facilityid: $facilityId, date: $date, teamlead: $teamLead';
  }
}