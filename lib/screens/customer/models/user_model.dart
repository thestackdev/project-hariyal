class UserModel {
  String name, email, phoneNumber;
  Map<String, dynamic> location;

  UserModel({this.name, this.email, this.phoneNumber, this.location});

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    map['name'] = name;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['location'] = location;
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phoneNumber'],
        location: map['location']);
  }
}
