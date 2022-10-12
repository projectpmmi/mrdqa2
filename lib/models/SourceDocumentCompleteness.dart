class SourceDocumentCompleteness{
  SourceDocumentCompleteness({this.id, this.sourceDocumentId, this.number, this.supervisionId});
  final int id;
  final int sourceDocumentId;
  final int number; // 1,2,3...7
  final int supervisionId;

  @override
  String toString() {
    return 'Source document completeness: id: $id, dataElementId: $sourceDocumentId, number: $number, supervisionId: $supervisionId';
  }

  Map<String, int> toJson() => {
    "$number": sourceDocumentId
  };
}