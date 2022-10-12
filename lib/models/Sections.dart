class Sections{
  Sections({this.id, this.number, this.description});
  final int id;
  final int number;
  final String description;

  @override
  String toString() {
    return 'Section: id: $id, number: $number, description: $description';
  }
}