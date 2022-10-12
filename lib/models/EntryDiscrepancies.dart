class EntryDiscrepancies {
  EntryDiscrepancies({this.id, this.description});

  final int id;
  final String description;

  @override
  String toString() {
    return 'Discrepancy: id: $id, description: $description';
  }
}