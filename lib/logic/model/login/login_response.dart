class LoginResponse {
  int? status;
  String? message;
  dynamic messageStatus;
  int? uid;
  String? username;
  String? token;
  dynamic data;

  LoginResponse({
    this.status,
    this.message,
    this.messageStatus,
    this.uid,
    this.username,
    this.token,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: (json['status'] as num?)?.toInt(),
      message: json['message'] as String?,
      messageStatus: json['messageStatus'],
      uid: (json['uid'] as num?)?.toInt(),
      username: json['username'] as String?,
      token: json['token'] as String?,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'messageStatus': messageStatus,
      'uid': uid,
      'username': username,
      'token': token,
      'data': data,
    };
  }
}
