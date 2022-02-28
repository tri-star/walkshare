import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/stroll_route.dart';
import 'package:strollog/domain/user.dart';

class RouteRepository {
  Future<void> save(User user, StrollRoute route) async {
    DocumentReference documentRef =
        await FirebaseFirestore.instance.collection('routes').add({
      'uid': user.id,
      'name': route.name,
      'routes': route.routePoints.map((p) {
        return GeoPoint(p.latitude, p.longitude);
      }).toList(),
      'created_at': DateTime.now().toIso8601String(),
    });
    route.setId(documentRef.id);
  }

  Future<void> pushPoints(String routeId, List<Position> positions) async {
    assert(routeId != '');
    await FirebaseFirestore.instance.collection('routes').doc(routeId).update({
      'routes': FieldValue.arrayUnion(positions.map((p) {
        return GeoPoint(p.latitude, p.longitude);
      }).toList())
    });
  }
}
