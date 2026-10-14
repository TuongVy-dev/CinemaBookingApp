import '../../domain/entities/customer_profile.dart';

class UserInfoDto {
  const UserInfoDto({
    this.userId,
    required this.username,
    this.role,
    this.email,
    this.phone,
    this.dob,
    this.sex,
  });

  final String? userId;
  final String username;
  final String? role;
  final String? email;
  final String? phone;
  final String? dob;
  final String? sex;

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['userId'] ?? json['id'];
    final rawSex = json['sex'];
    String? sexStr;
    if (rawSex is bool) {
      sexStr = rawSex ? 'Nam' : 'Nữ';
    } else if (rawSex is String) {
      sexStr = rawSex;
    }

    return UserInfoDto(
      userId: rawId?.toString(),
      username: json['username'] as String? ?? '',
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      sex: sexStr,
    );
  }

  CustomerProfile toProfile() => CustomerProfile(
    userId: userId,
    username: username,
    email: email,
    phone: phone,
    dob: dob,
    sex: sex,
  );
}

