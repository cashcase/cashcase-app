String? isValidUsername(String value) {
  if (value.isEmpty) return "Username cannot be empty";
  if (!RegExp("^(?=.{5,20}\$)(?![_.])(?!.*[_.]{2})[a-z0-9._]+(?<![_.])\$")
      .hasMatch(value))
    return "Username must be 5-20 alphanumeric chars and only . or _ special chars allowed.";
  return null;
}

String? isValidPassword(String value) {
  if (value.isEmpty) return "Password cannot be empty";
  if (!RegExp("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@\$]).{8,20}\$")
      .hasMatch(value)) {
    return "Password must contain atleast 1 uppercase, 1 lowercase, 1 digit and 1 special char (!@\$) and between 8-20 chars.";
  }
  return null;
}

String? isValidName(String value, {optional = false}) {
  if (!optional && value.isEmpty) return "Field cannot be empty.";
  if (!RegExp("^[a-zA-Z]{${optional ? "0" : "3"},20}\$").hasMatch(value)) {
    return "Field must be 3-20 chars long and must contain only alphabets.";
  }
  return null;
}

String? isValidKey(String value, {optional = false}) {
  RegExp regex = RegExp(r'^\b[a-z]+\b\s+\b[a-z]+\b\s+\b[a-z]+\b\s+\b[a-z]+\b$');
  if (!optional && value.isEmpty) return "Key cannot be empty.";
  if (value.split(" ").length != 4) return "Key must be 4 words long.";
  if (!regex.hasMatch(value))
    return "Key must contain only lower case alphabets.";
  return null;
}
