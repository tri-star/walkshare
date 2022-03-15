import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:strollog/domain/map_info.dart';

/// マップ情報は頻繁に更新するわけではなく、ユーザー間で共有する場合も適宜リロードしてもらえば良いので
/// Streamの購読は不要と考える
class MapInfoRepository {
  Future<MapInfo?> fetchMapByName(String name) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('maps')
        .withConverter<MapInfo>(
            fromFirestore: (snapshot, _) =>
                MapInfo.fromJson(snapshot.id, snapshot.data()!),
            toFirestore: (MapInfo mapInfo, _) => mapInfo.toJson())
        .where('name', isEqualTo: name)
        .get();

    if (!snapshot.docs.first.exists) {
      return null;
    }
    return snapshot.docs.first.data();
  }

  Future<void> addPoint(MapInfo map, MapPoint point) async {
    map.points.add(point);
    await FirebaseFirestore.instance.collection('maps').doc(map.id).update({
      'points': FieldValue.arrayUnion([point.toJson()])
    });
  }
}
