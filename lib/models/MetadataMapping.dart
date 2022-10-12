class MetadataMapping{
  MetadataMapping({this.id, this.uid, this.code});
  final int id;
  final String uid;
  final String code;

  @override
  String toString() {
    return 'Metadata mapping: id: $id, uid: $uid, code: $code';
  }
}