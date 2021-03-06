class Address {
  final String line1;
  final String line2;
  final String city;
  final String prefecture;
  final String postcode;
  final String phoneNumber;

  Address({
    this.line1,
    this.line2,
    this.city,
    this.prefecture,
    this.postcode,
    this.phoneNumber,
  });

  String getAddressText() {
    return line1 + line2;
  }

  Map<String, dynamic> toMap() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'prefecture': prefecture,
      'postcode': postcode,
      'phoneNumber': phoneNumber,
    };
  }

  Address.fromMap(Map<String, dynamic> map)
      : assert(map['line1'] != null),
        assert(map['line2'] != null),
        assert(map['postcode'] != null),
        assert(map['phoneNumber'] != null),
        line1 = map['line1'],
        line2 = map['line2'],
        city = map['city'],
        prefecture = map['prefecture'],
        postcode = map['postcode'],
        phoneNumber = map['phoneNumber'];
}
