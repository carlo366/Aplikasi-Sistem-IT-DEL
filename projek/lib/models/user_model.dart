class User {
  int? id;
  String? fullname;
  String? ktp;
  String? nim;
  String? role;
  String? phone;
  String? email;
  String? password;
  String? token;

  User({
    this.id,
    this.fullname,
    this.ktp,
    this.nim,
    this.role,
    this.phone,
    this.email,
    this.password,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      fullname: json['user']['fullname'],
      ktp: json['user']['ktp'],
      nim: json['user']['nim'],
      role: json['user']['role'],
      phone: json['user']['phone'],
      email: json['user']['email'],
      password: json['user']['password'],
      token: json['token'],
    );
  }
}