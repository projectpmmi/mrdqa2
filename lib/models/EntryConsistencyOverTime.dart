class EntryConsistencyOverTime {
  EntryConsistencyOverTime(
      {this.id,
      this.supervisionId,
      this.facilityId,
      this.indicatorId,
      this.currentMonthValue,
      this.currentMonthValueComment,
      this.currentMonthYearAgoValue,
      this.currentMonthYearAgoValueComment,
      this.annualRatio,
      this.annualRatioComment,
      this.monthToMonthValue1,
      this.monthToMonthValue2,
      this.monthToMonthValue3,
      this.monthToMonthValueLastMonth,
      this.monthToMonthRatio,
      this.monthToMonthRatioComment,
      this.reasonForDiscrepancyComment,
      this.otherReasonForDiscrepancy,
      this.otherReasonForDiscrepancyComment});

  int id;
  int facilityId;
  int supervisionId;
  int indicatorId;
  double currentMonthValue;
  String currentMonthValueComment;
  double currentMonthYearAgoValue;
  String currentMonthYearAgoValueComment;
  double annualRatio;
  String annualRatioComment;
  double monthToMonthValue1;
  double monthToMonthValue2;
  double monthToMonthValue3;
  double monthToMonthValueLastMonth;
  double monthToMonthRatio;
  String monthToMonthRatioComment;
  String reasonForDiscrepancyComment;
  String otherReasonForDiscrepancy;
  String otherReasonForDiscrepancyComment;

  @override
  String toString() {
    return 'EntryConsistencyOverTime: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, annualRatio: $annualRatio, monthToMonthRatio: $monthToMonthRatio';
  }
}
