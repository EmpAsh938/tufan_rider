class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }

  // Add copyWith method to LoginResponse class
  LoginResponse copyWith({
    String? token,
    User? user,
  }) {
    return LoginResponse(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class User {
  final int id;
  final dynamic currentLocation;
  final String name;
  final String? email;
  final String? managerAddress;
  final String mobileNo;
  final String? imageName;
  final String? otp;
  final dynamic balance; // Can be double or null
  final String? branchName;
  final String modes;
  final String? dateOfBirth;
  final dynamic mode; // Can be String or null
  final List<Role> roles;
  final dynamic vehicles; // Can be List or null

  User({
    required this.id,
    this.currentLocation,
    required this.name,
    this.email,
    this.managerAddress,
    required this.mobileNo,
    required this.imageName,
    required this.otp,
    this.balance,
    required this.branchName,
    required this.modes,
    required this.dateOfBirth,
    this.mode,
    required this.roles,
    this.vehicles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      currentLocation: json['currentLocation'],
      name: json['name'],
      email: json['email'] != null ? json['email'] as String : null,
      managerAddress: json['managerAddress'],
      mobileNo: json['mobileNo'],
      imageName: json['imageName'],
      otp: json['otp'],
      balance: json['balance'],
      branchName: json['branch_Name'],
      modes: json['modes'],
      dateOfBirth: json['date_of_Birth'],
      mode: json['mode'],
      roles: (json['roles'] as List).map((e) => Role.fromJson(e)).toList(),
      vehicles: json['vehicles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentLocation': currentLocation,
      'name': name,
      'email': email,
      'managerAddress': managerAddress,
      'mobileNo': mobileNo,
      'imageName': imageName,
      'otp': otp,
      'balance': balance,
      'branch_Name': branchName,
      'modes': modes,
      'date_of_Birth': dateOfBirth,
      'mode': mode,
      'roles': roles.map((e) => e.toJson()).toList(),
      'vehicles': vehicles,
    };
  }

  // Add copyWith method to User class
  User copyWith({
    int? id,
    dynamic currentLocation,
    String? name,
    String? email,
    String? managerAddress,
    String? mobileNo,
    String? imageName,
    String? otp,
    dynamic balance,
    String? branchName,
    String? modes,
    String? dateOfBirth,
    dynamic mode,
    List<Role>? roles,
    dynamic vehicles,
  }) {
    return User(
      id: id ?? this.id,
      currentLocation: currentLocation ?? this.currentLocation,
      name: name ?? this.name,
      email: email ?? this.email,
      managerAddress: managerAddress ?? this.managerAddress,
      mobileNo: mobileNo ?? this.mobileNo,
      imageName: imageName ?? this.imageName,
      otp: otp ?? this.otp,
      balance: balance ?? this.balance,
      branchName: branchName ?? this.branchName,
      modes: modes ?? this.modes,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      mode: mode ?? this.mode,
      roles: roles ?? this.roles,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
