class CategoryOptionCombo{
  CategoryOptionCombo({this.uid, this.name, this.code});
  final String uid;
  final String name;
  final String code;

  factory CategoryOptionCombo.fromJson(Map<String, dynamic> json) {

    return CategoryOptionCombo(uid: json['id'], name: json['displayName'], code: json['code']);
  }

  @override
  String toString() {
    return 'CategoryOptionCombo: uid: $uid, name: $name, code: $code';
  }
}