class SigninPageData {}

class TokenDetails {
  String refreshToken;
  String token;
  TokenDetails({required this.token, required this.refreshToken});

  static fromJson(dynamic data) {
    return TokenDetails(
      token: data['token'],
      refreshToken: data['refreshToken'],
    );
  }
}
