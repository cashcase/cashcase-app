class AccountPageData {}

class User {
  String firstName;
  String lastName;
  String email;
  String id;
  User(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.id});

  static fromJson(dynamic data) {
    return User(
      firstName: data['firstName'],
      lastName: data['lastName'],
      id: data['id'],
      email: data['email'],
    );
  }
}
