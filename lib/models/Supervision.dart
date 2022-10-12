class Supervision{
  Supervision({this.id, this.description, this.period, this.countryId, this.usePackage, this.uid});
  int id;
  String description;
  DateTime period;
  String countryId;
  bool usePackage;
  String uid;

  setId(int id){
    this.id = id;
  }

  setDescription(String description){
   this.description = description;
  }

  setPeriod(DateTime period){
    this.period = period;
  }

  setUsePackage(bool usePackage) {
    this.usePackage = usePackage;
  }

  setUid(String uid) {
    this.uid = uid;
  }

  @override
  String toString() {
    return 'Supervision: id: $id, description: $description, period: $period, uid: $uid';
  }
}