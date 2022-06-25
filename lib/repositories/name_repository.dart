import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/domain/user.dart';

class NameRepository {
  Future<void> save(User? user, String mapId, Name name) async {
    var json = {
      'name': name.name,
      'pronounce': name.pronounce,
      'place': name.place,
      'memo': name.memo,
      'created': name.created
    };
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(mapId)
        .collection('names')
        .doc(name.id)
        .set(json);
  }
}
