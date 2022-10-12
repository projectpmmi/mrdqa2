class EntryCrossCheckC {
  EntryCrossCheckC({
      this.id,
      this.supervisionId,
      this.facilityId,
      this.primaryDataSourceId,
      this.secondaryDataSourceId,
      this.initialStock,
      this.initialStockComment,
      this.receivedStock,
      this.receivedStockComment,
      this.closingStock,
      this.closingStockComment,
      this.usedStock,
      this.usedStockComment,
      this.ratio,
      this.ratioComment,
      this.reasonForDiscrepancyComment,
      this.otherReasonForDiscrepancy,
      this.otherReasonForDiscrepancyComment});

  int id;
  int supervisionId;
  int facilityId;
  int primaryDataSourceId;
  int secondaryDataSourceId;
  int initialStock;
  String initialStockComment;
  int receivedStock;
  String receivedStockComment;
  int closingStock;
  String closingStockComment;
  int usedStock;
  String usedStockComment;
  double ratio;
  String ratioComment;
  String reasonForDiscrepancyComment;
  String otherReasonForDiscrepancy;
  String otherReasonForDiscrepancyComment;

  @override
  String toString() {
    return 'EntryCrossCheckC: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, primaryDataSourceId: $primaryDataSourceId, secondaryDataSourceId: $secondaryDataSourceId, ratio: $ratio';
  }
}
