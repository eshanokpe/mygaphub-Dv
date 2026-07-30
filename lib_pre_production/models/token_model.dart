class Token {
  String token;
  Token(this.token);

  factory Token.fromJSON(dynamic json) {
    return Token(json['data']['access_token'] as String);
  }

  @override
  String toString() {
    return ' { $token } ';
  }
}
