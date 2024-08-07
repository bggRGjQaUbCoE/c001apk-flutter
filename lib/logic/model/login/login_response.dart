class LoginResponse {
  int? status;
  String? message;
  int? uid;
  String? username;
  String? token;

  LoginResponse({
    this.status,
    this.message,
    this.uid,
    this.username,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: (json['status'] as num?)?.toInt(),
      message: json['message'] as String?,
      uid: (json['uid'] as num?)?.toInt(),
      username: json['username'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'uid': uid,
      'username': username,
      'token': token,
    };
  }
}
