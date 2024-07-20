class HeatMapPageData {}

class User {
  String firstName;
  String lastName;
  String? email;
  String username;
  User(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.username});

  String getInitials() {
    return "${firstName[0].toUpperCase()}"
        "${lastName.isNotEmpty ? lastName[0].toUpperCase() : ""}";
  }

  static fromJson(dynamic data) {
    return User(
      firstName: data['firstName'],
      lastName: data['lastName'] ?? "",
      username: data['username'] ?? data['id'],
      email: data['email'],
    );
  }

  toJson() {
    return {
      "username": this.username,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "email": this.email
    };
  }
}

class ProfileModel {
  User details;
  List<User> connections;
  List<User> sent;
  List<User> received;
  ProfileModel({
    required this.details,
    required this.connections,
    required this.sent,
    required this.received,
  });

  static fromJson(dynamic data) {
    return ProfileModel(
      details: User.fromJson(data['details']),
      connections: ((data['connections'] ?? []) as List)
          .map<User>((e) => User.fromJson(e))
          .toList(),
      sent: ((data['sent'] ?? []) as List)
          .map<User>((e) => User.fromJson(e))
          .toList(),
      received: ((data['received'] ?? []) as List)
          .map<User>((e) => User.fromJson(e))
          .toList(),
    );
  }
}
