class UserProfileResponse {
  String id;
  bool status;
  bool isDeleted;
  bool isLocked;
  String username;
  String password;
  String email;
  String createdAt;
  String updatedAt;
  int v;

  UserProfileResponse({
    required this.id,
    required this.status,
    required this.isDeleted,
    required this.isLocked,
    required this.username,
    required this.password,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        id: json["_id"],
        status: json["status"],
        isDeleted: json["isDeleted"],
        isLocked: json["isLocked"],
        username: json["username"],
        password: json["password"],
        email: json["email"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "status": status,
        "isDeleted": isDeleted,
        "isLocked": isLocked,
        "username": username,
        "password": password,
        "email": email,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
      };
}
