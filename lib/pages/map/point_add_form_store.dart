import 'package:flutter/widgets.dart';

class PointAddFormStore extends ChangeNotifier {
  String _title = '';

  String _comment = '';

  String get title => _title;
  String get comment => _comment;

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setComment(String comment) {
    _comment = comment;
    notifyListeners();
  }

  Future<void> save() async {
    print({title, comment});
  }

  bool isValidInput() {
    return _title.length > 0;
  }
}
