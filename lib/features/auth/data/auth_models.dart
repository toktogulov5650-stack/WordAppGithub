import '../../../core/language/language_provider.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.preferredLanguage,
  });

  final int id;
  final String email;
  final String name;
  final String preferredLanguage;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      preferredLanguage:
          normalizeLanguageCode(json['preferredLanguage'] as String?) ??
          defaultLanguageCode,
    );
  }

  UserModel copyWith({String? preferredLanguage}) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'preferredLanguage': preferredLanguage,
    };
  }
}

class AuthResponse {
  const AuthResponse({required this.accessToken, required this.user});

  final String accessToken;
  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final authData = json['auth'];
    final authMap = authData is Map<String, dynamic> ? authData : null;
    final tokenData = json['token'];
    final tokenMap = tokenData is Map<String, dynamic> ? tokenData : null;

    return AuthResponse(
      accessToken:
          _readToken(json) ??
          (authMap == null ? null : _readToken(authMap)) ??
          (tokenMap == null ? null : _readToken(tokenMap)) ??
          '',
      user: UserModel.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  static String? _readToken(Map<String, dynamic> json) {
    for (final key in [
      'accessToken',
      'access_token',
      'token',
      'jwt',
      'bearerToken',
    ]) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.preferredLanguage,
  });

  final String name;
  final String email;
  final String password;
  final String preferredLanguage;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'preferredLanguage': preferredLanguage,
    };
  }
}

class GoogleLoginRequest {
  const GoogleLoginRequest({
    required this.idToken,
    required this.preferredLanguage,
  });

  final String idToken;
  final String preferredLanguage;

  Map<String, dynamic> toJson() {
    return {'idToken': idToken, 'preferredLanguage': preferredLanguage};
  }
}
