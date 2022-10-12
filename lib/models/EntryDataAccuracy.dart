class EntryDataAccuracy {
  EntryDataAccuracy({
    this.id,
    this.supervisionId,
    this.facilityId,
    this.indicatorId,
    this.sourceDocumentRecount1,
    this.sourceDocumentRecount2,
    this.sourceDocumentRecount3,
    this.sourceDocumentRecountTotal,
    this.sourceDocumentRecountComment,
    this.hmisMonthlyReportValue1,
    this.hmisMonthlyReportValue2,
    this.hmisMonthlyReportValue3,
    this.hmisMonthlyReportValueTotal,
    this.hmisMonthlyReportValueComment,
    this.dhisMonthlyValue1,
    this.dhisMonthlyValue2,
    this.dhisMonthlyValue3,
    this.dhisMonthlyValueTotal,
    this.dhisMonthlyValueComment,
    this.monthlyReportVf1,
    this.monthlyReportVf2,
    this.monthlyReportVf3,
    this.monthlyReportVfTotal,
    this.monthlyReportVfComment,
    this.dhisVf1,
    this.dhisVf2,
    this.dhisVf3,
    this.dhisVfTotal,
    this.dhisVfComment,
    this.reasonForDiscrepancyComment,
    this.otherReasonForDiscrepancy1,
    this.otherReasonForDiscrepancy2,
    this.otherReasonForDiscrepancy3,
    this.otherReasonForDiscrepancyComment,
    this.type,
  });

  int id;
  int supervisionId;
  int facilityId;
  int indicatorId;
  int sourceDocumentRecount1;
  int sourceDocumentRecount2;
  int sourceDocumentRecount3;
  int sourceDocumentRecountTotal;
  String sourceDocumentRecountComment;
  int hmisMonthlyReportValue1;
  int hmisMonthlyReportValue2;
  int hmisMonthlyReportValue3;
  int hmisMonthlyReportValueTotal;
  String hmisMonthlyReportValueComment;
  int dhisMonthlyValue1;
  int dhisMonthlyValue2;
  int dhisMonthlyValue3;
  int dhisMonthlyValueTotal;
  String dhisMonthlyValueComment;
  double monthlyReportVf1;
  double monthlyReportVf2;
  double monthlyReportVf3;
  double monthlyReportVfTotal;
  String monthlyReportVfComment;
  double dhisVf1;
  double dhisVf2;
  double dhisVf3;
  double dhisVfTotal;
  String dhisVfComment;
  String reasonForDiscrepancyComment;
  String otherReasonForDiscrepancy1;
  String otherReasonForDiscrepancy2;
  String otherReasonForDiscrepancy3;
  String otherReasonForDiscrepancyComment;
  String type; // entry1, entry2 ...

  @override
  String toString() {
    return 'EntryDataAccuracy: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, monthlyReportVfTotal: $monthlyReportVfTotal, dhisVfTotal: $dhisVfTotal';
  }
}