class EntrySourceDocumentCompleteness {
  EntrySourceDocumentCompleteness(
      {this.id,
      this.supervisionId,
      this.facilityId,
      this.sourceDocumentId,
      this.available,
      this.upToDate,
      this.standardForm,
      this.availableResult,
      this.upToDateResult,
      this.standardFormResult,
      this.comment,
      this.type});

  int id;
  int supervisionId;
  int facilityId;
  int sourceDocumentId;
  int available;
  int upToDate;
  int standardForm;
  double availableResult;
  double upToDateResult;
  double standardFormResult;
  String comment;
  String type; //entry1.../result. put supervision id when it's result.

  @override
  String toString() {
    return 'EntrySourceDocumentCompleteness: id: $id, supervisionId: $supervisionId, facilityId: $facilityId, sourceDocumentId: $sourceDocumentId, available: $available, availableResult: $availableResult, type: $type';
  }
}
