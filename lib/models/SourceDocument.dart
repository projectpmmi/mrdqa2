class SourceDocument {
  SourceDocument({this.id, this.name, this.uid, this.isSupervisable=false});

  int id;
  String name;
  String uid;
  bool isSupervisable;

  @override
  String toString() {
    return 'Source document: id: $id, name: $name, uid: $uid';
  }
}