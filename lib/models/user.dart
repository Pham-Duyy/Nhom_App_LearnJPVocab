class User {
  final int _id;
  final String _username;
  final String _email;
  final String _passwordHash;

  User({
    required int id,
    required String username,
    required String email,
    required String passwordHash,
  })  : _id = id,
        _username = username,
        _email = email,
        _passwordHash = passwordHash;

  int get id => _id;
  String get username => _username;
  String get email => _email;
  String get passwordHash => _passwordHash;

  /// Kiểm tra định dạng email có hợp lệ không.
  /// Đây là validate thuần trên dữ liệu đã có sẵn trong object —
  /// không gọi mạng/DB nên vẫn hợp lệ nằm trong Model.
  bool isValidEmail() {
    final emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return emailPattern.hasMatch(_email);
  }

  /// Tên hiển thị trên giao diện — viết hoa chữ cái đầu của username.
  String getDisplayName() {
    if (_username.isEmpty) return _username;
    return _username[0].toUpperCase() + _username.substring(1);
  }

  Map<String, dynamic> toMap() => {
        'id': _id,
        'username': _username,
        'email': _email,
        'passwordHash': _passwordHash,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int,
        username: map['username'] as String,
        email: map['email'] as String,
        passwordHash: map['passwordHash'] as String,
      );

  @override
  String toString() => 'User($_username, $_email)';
}