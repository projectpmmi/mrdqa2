class Planning{
  Planning({this.id, this.name, this.period});
  final int id;
  final String name; // 1: January ..
  final DateTime period;

  @override
  String toString() {
    return 'Planning: id: $id, name: $name, period: $period';
  }
}