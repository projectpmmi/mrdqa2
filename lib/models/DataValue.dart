class DataValue{
  String dataElement;
  String value;
  String categoryOpCombo;
  String comment;
  DataValue({this.dataElement, this.categoryOpCombo, this.value, this.comment = ""});
  Map<String, dynamic> toJson() => {
    "dataElement": dataElement,
    "categoryOptionCombo": categoryOpCombo,
    "value": value,
    "comment": comment
  };
  @override
  String toString() {
    return 'Data value: dataElement: $dataElement, categoryOptionCombo: $categoryOpCombo, value: $value';
  }
}