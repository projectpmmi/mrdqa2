class Facility {
  Facility(
      {this.id,
      this.uid,
      this.name,
      this.countryId,
      this.townVillage,
      this.district,
      this.region,
      this.facilityTypeId,
      this.phone,
      this.email,
      this.isSupervisable = false,
      this.isDhisFacility = true});

  final int id;
  final String uid;
  final String name;
  final String countryId; // a reference to Country
  final String townVillage;
  final String district; // District and Region may be a reference later as well let's discuss more
  final String region;
  final int facilityTypeId; // a reference to type
  final String phone;
  final String email;
  bool isSupervisable;
  bool isDhisFacility;

  /// This flag specifies if a facility can be supervised.

  factory Facility.fromJson(Map<String, dynamic> json, {bool remote = false}) {
    String name;
    if (remote) {
      name = "${json['displayName']}";
    } else {
      // This is needed to differentiate facilities with the same name but with
      // different parents
      name = "${json['displayName']} (${json['parent']['displayName']})";
    }
    return Facility(uid: json['id'], name: name);
  }

  factory Facility.fromJsonPackage(Map<String, dynamic> json, {bool dhis = true}) {
    return Facility(uid: json['id'], name: json['displayName'], isDhisFacility: dhis);
  }

  @override
  String toString() {
    return 'Facility: id: $id, uid: $uid, name: $name, supervisable: $isSupervisable';
  }
}
