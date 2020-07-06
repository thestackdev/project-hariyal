class UserModel {
  String uid, name, email, phoneNumber, pinCode, state, cityDistrict, country;
  Map<String, double> location;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.phoneNumber,
      this.pinCode,
      this.state,
      this.cityDistrict,
      this.country,
      this.location});

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    map['uid'] = uid;
    map['name'] = name;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['pinCode'] = pinCode;
    map['state'] = state;
    map['cityDistrict'] = cityDistrict;
    map['country'] = country;
    map['location'] = location;
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        uid: map['uid'],
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phoneNumber'],
        pinCode: map['pinCode'],
        state: map['state'],
        cityDistrict: map['cityDistrict'],
        country: map['country'],
        location: map['location']);
  }
}
