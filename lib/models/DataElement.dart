import 'CategoryOptionCombo.dart';

class DataElement{
  DataElement({this.id, this.uid, this.name, this.code, this.categoryOptionCombos, this.isSupervisable=false, this.isDhisDataElement=true});
  final int id;
  final String uid;
  final String name;
  final String code;
  final List<CategoryOptionCombo> categoryOptionCombos;
  bool isSupervisable;
  bool isDhisDataElement; //flag to determine whether this data element is from DHIS2 or else where.

  factory DataElement.fromJson(Map<String, dynamic> json) {
    //print("CategoryOptionCombos");
    //print(json['categoryCombo']['categoryOptionCombos']);
    // List<CategoryOptionCombo> listCombos = [];
    // json['categoryCombo']['categoryOptionCombos'].forEach((v){
    //   CategoryOptionCombo catOptCombo = CategoryOptionCombo(uid: v['id'], name: v['displayName']);
    //   listCombos.add(catOptCombo);
    // });

    // return DataElement(uid: json['id'], name: json['displayName'], categoryOptionCombos: listCombos);
    return DataElement(uid: json['id'], name: json['displayName'], code: json['code']);
  }

  @override
  String toString() {
    return 'Data Element: uid: $uid, name: $name code: $code';
  }
}