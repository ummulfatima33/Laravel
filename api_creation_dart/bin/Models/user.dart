class User {
  String UserId;
  String UserName;
  String UserEmail;
  String UserPassword;
  int   UserAge;

  User({
    required this.UserId,
    required this.UserName,
    required this.UserEmail,
    required this.UserPassword,
    required this.UserAge,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      UserId: json['UserId'].toString(), // 🔥 FORCE STRING
      UserName: json['UserName'] ?? '',
      UserEmail: json['UserEmail'] ?? '',
      UserPassword: json['UserPassword'] ?? '',
      UserAge: json['UserAge'] is int
          ? json['UserAge']
          : int.parse(json['UserAge'].toString()),
    );

    
  }

  Map<String, dynamic> toJson() {
    return {
      "UserId": UserId,
      "UserName": UserName,
      "UserEmail": UserEmail,
      "UserPassword": UserPassword,
      "UserAge": UserAge,
    };
  }
}
