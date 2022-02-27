class User {
  final String _id;
  final String _name;
  final String _icon;

  User(this._id, this._name, this._icon);

  String get id => _id;
  String get name => _name;
  String get icon => _icon;
}
