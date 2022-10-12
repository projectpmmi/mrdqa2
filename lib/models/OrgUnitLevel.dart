class OrgUnitLevel{
  final String id;
  final String name;
  final String level;

  OrgUnitLevel({this.id, this.name, this.level});

  factory OrgUnitLevel.fromJson(Map<String, dynamic> json) {

    return OrgUnitLevel(id: json['id'], name: json['displayName'], level: json['level']);
  }
  @override
  String toString() {
    return 'OrgUnit Level: id: $id, name: $name, level: $level';
  }
}