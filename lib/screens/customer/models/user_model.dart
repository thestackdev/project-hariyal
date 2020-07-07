class UserModel {
  String name,
      email,
      phoneNumber,
      gender,
      alternatePhoneNumber,
      permanentAddress;
  Map<String, dynamic> location;

  UserModel(
      {this.name,
      this.email,
      this.phoneNumber,
      this.gender,
      this.alternatePhoneNumber,
      this.permanentAddress,
      this.location});

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    map['name'] = name;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['gender'] = "default";
    map['alternatePhoneNumber'] = "default";
    map['permanentAddress'] = "default";
    map['location'] = location;
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phoneNumber'],
        gender: map['gender'],
        alternatePhoneNumber: map['alternatePhoneNumber'],
        permanentAddress: map['permanentAddress'],
        location: map['location']);
  }
}
