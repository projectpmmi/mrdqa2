class Indicator{
  Indicator({this.id, this.uid, this.name, this.typeId, this.isSupervisable=false, this.isDhisDataElement=true});
  final int id;
  final String uid;
  final String name;
  final int typeId;
  bool isSupervisable;
  bool isDhisDataElement;

  factory Indicator.fromJson(Map<String, dynamic> json) {

    return Indicator(uid: json['id'], name: json['displayName'], typeId: 0);
  }

  @override
  String toString() {
    return 'Indicator: id: $id uid: $uid name: $name supervisable: $isSupervisable';
  }
}