class Program {
  //final int id;
  final String uid;
  final String shortName;
  final String displayName;
  final String programType;

  Program({this.uid, this.shortName, this.displayName, this.programType});
  factory Program.fromJson(Map<String, dynamic> json){

    return Program(uid: json['id'], shortName: json['shortName'], displayName: json['displayName'], programType: json['programType']);
  }

  @override
  String toString(){
    return 'Program: uid: $uid, name: $displayName, programType: $programType';
  }
}