class UserModel {
  String name,
      email,
      phoneNumber,
      gender,
      alternatePhoneNumber,
      permanentAddress,
      search_value,
      current_search;
  Map<String, dynamic> location;
  bool isBlocked;

  UserModel(
      {this.name,
      this.email,
      this.phoneNumber,
      this.gender,
      this.alternatePhoneNumber,
      this.permanentAddress,
      this.search_value,
      this.current_search,
      this.location,
      this.isBlocked});

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    map['name'] = name;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['gender'] = "default";
    map['alternatePhoneNumber'] = "default";
    map['permanentAddress'] = "default";
    map['location'] = location;
    map['isBlocked'] = false;
    map['current_search'] = "location.state";
    map['search_value'] = location['state'];
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
        location: map['location'],
        isBlocked: map['isBlocked'],
        current_search: map['current_search'],
        search_value: map['search_value']);
  }
}
