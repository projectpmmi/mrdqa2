import 'package:mrdqa_tool/models/DataValue.dart';

class Payload {
  String dataset; /// DS_490350 or aLpVgfXiz0f
  String orgUnit; /// at6UHUQatSo
  String period;
  String attOpCombo;
  String completedDate; //format "2013-05-18",
  List<DataValue> dataValue;
  //String _eventDate; // format "2013-05-17",
  ///String _status = "COMPLETED";
  ///String _storedBy; //Username example "admin",

  Payload({this.dataset, this.orgUnit, this.period, this.attOpCombo, this.completedDate, this.dataValue});

  Map<String, dynamic> toJson() => {
    "dataset": dataset,
    "orgUnit": orgUnit,
    "period": period,
    "completeDate": completedDate,
    "attributeOptionCombo": attOpCombo,
    "dataValues": dataValue
  };
}