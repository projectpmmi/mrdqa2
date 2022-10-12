class Periods{
  Periods({this.id, this.number, this.description});
  final int id;
  final int number; // 1: January ..
  final String description;

  @override
  String toString() {
    return 'Period: id: $id, number: $number, description: $description';
  }
}