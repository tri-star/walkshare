class User {
  final String _id;
  final String _name;
  final String _icon;

  User(this._id, this._name, this._icon);

  String get id => _id;
  String get name => _name;
  String get icon => _icon;
}

class UserNameInfo {
  final String _id;
  final String _nickname;

  UserNameInfo(this._id, this._nickname);

  String get id => _id;
  String get nickname => _nickname;
}
