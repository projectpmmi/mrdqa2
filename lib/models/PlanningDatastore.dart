
class PlanningDatastore{
  String facilityCode;
  String dateVisit;
  String teamLead;

  PlanningDatastore(this.facilityCode, this.dateVisit, this.teamLead);

  Map<String, String> toJson() => {
    "facility_code": facilityCode,
    "date_visit": dateVisit,
    "team_lead": teamLead,
  };
}