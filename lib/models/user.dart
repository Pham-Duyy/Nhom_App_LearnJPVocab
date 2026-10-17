import 'generic_entity.dart';

class User extends GenericEntity<int> {
  final String _passwordHash;

  User({
    required int id,
    required String username,
    required String email,
    required String passwordHash,
  })  : _passwordHash = passwordHash,
        super(id: id, name: username, description: email);

  String get username => name;
  String get email => description;
  String get passwordHash => _passwordHash;

  /// Kiểm tra định dạng email có hợp lệ không.
  /// Đây là validate thuần trên dữ liệu đã có sẵn trong object —
  /// không gọi mạng/DB nên vẫn hợp lệ nằm trong Model.
  bool isValidEmail() {
    final emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return emailPattern.hasMatch(email);
  }

  /// Tên hiển thị trên giao diện — viết hoa chữ cái đầu của username.
  String getDisplayName() {
    if (username.isEmpty) return username;
    return username[0].toUpperCase() + username.substring(1);
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'passwordHash': _passwordHash,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int,
        username: map['username'] as String,
        email: map['email'] as String,
        passwordHash: map['passwordHash'] as String,
      );

  @override
  String toString() => 'User($username, $email)';
}
