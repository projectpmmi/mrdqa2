class EntrySystemAssessment {
  EntrySystemAssessment({
    this.id,
    this.supervisionId,
    this.facilityId,
    this.questionV1,
    this.questionV1Comment,
    this.questionV2,
    this.questionV2Comment,
    this.questionV3,
    this.questionV3Comment,
    this.questionV4,
    this.questionV4Comment,
    this.questionV5,
    this.questionV5Comment,
    this.questionV6,
    this.questionV6Comment,
    this.questionV7,
    this.questionV7Comment,
    this.questionV8,
    this.questionV8Comment,
    this.questionV9,
    this.questionV9Comment,
    this.questionV10,
    this.questionV10Comment,
    this.questionV11,
    this.questionV11Comment,
    this.questionV12,
    this.questionV12Comment,
    this.systemReadiness,
  });

  int id;
  int supervisionId;
  int facilityId;
  String questionV1;
  String questionV1Comment;
  String questionV2;
  String questionV2Comment;
  String questionV3;
  String questionV3Comment;
  String questionV4;
  String questionV4Comment;
  String questionV5;
  String questionV5Comment;
  String questionV6;
  String questionV6Comment;
  String questionV7;
  String questionV7Comment;
  String questionV8;
  String questionV8Comment;
  String questionV9;
  String questionV9Comment;
  String questionV10;
  String questionV10Comment;
  String questionV11;
  String questionV11Comment;
  String questionV12;
  String questionV12Comment;
  double systemReadiness;

  @override
  String toString() {
    return 'EntrySystemAssessment: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, questionV1: $questionV1, systemReadiness: $systemReadiness';
  }
}
