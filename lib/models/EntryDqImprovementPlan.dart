class EntryDqImprovementPlan {
  EntryDqImprovementPlan(
      {this.id,
      this.supervisionId,
      this.facilityId,
      this.weaknesses,
      this.actionPointDescription,
      this.responsibles,
      this.timeLine,
      this.comment,
      this.type});

  int id;
  int supervisionId;
  int facilityId;
  String weaknesses;
  String actionPointDescription;
  String responsibles;
  DateTime timeLine;
  String comment;
  String type; // a, b, c or d.

  @override
  String toString() {
    return 'EntryDqImprovementPlan: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, weaknesses: $weaknesses, actionPointDescription: $actionPointDescription, responsible: $responsibles, timeline: ${timeLine.toString()}, comment: $comment type: $type';
  }
}
