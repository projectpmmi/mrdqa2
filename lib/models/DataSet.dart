import 'package:meta/meta.dart';
import 'package:mrdqa_tool/models/DhisModel.dart';

class DataSet extends DhisModel {
  final String periodType;
  DataSet({String uid, String shortName, String displayName, String code, this.periodType}) :
        super(uid: uid, shortName: shortName, displayName: displayName, code: code);

  factory DataSet.fromJson(Map<String, dynamic> json){
    print("***** dataset");
    print(json);
    print("-----");
    return DataSet(uid: json['id'], shortName: json['shortName'], displayName: json['displayName'], code: json['code'], periodType: json['periodType']);
  }

  @override
  String toString(){
    return 'Dataset uid: $uid, name: $displayName, code: $code, periodType: $periodType';
  }
}