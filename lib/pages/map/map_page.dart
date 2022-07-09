import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/map_view.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/pages/map/point_info_form.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/services/image_loader.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapPageStore? _state;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(Consumer<MapPageStore>(
        builder: (context, store, child) => _createMapView(store)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_state == null) {
      _state = Provider.of<MapPageStore>(context, listen: false);
      _state!.setMapController(_mapController);
      _state!.init().then((_) {
        if (!_state!.locationRequested) {
          _state!.requestLocationPermission().then((permission) {
            if (permission == LocationPermissionResult.deniedForever) {
              //return const Center(child: Text("位置情報の使用が拒否されています。"));
              return;
            }

            // 位置情報の追跡を行う場合はここで現在地を求めると停止してしまうので、開始場所は別途検討する
            _state!.updateLocation();
          });
        }
      });
    }
  }

  Widget _createMapView(MapPageStore store) {
    if (store.position == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(children: [
      Expanded(
        child: StreamBuilder<Map<String, Spot>>(
          stream: Provider.of<MapInfoRepository>(context, listen: false)
              .subscribeSpotStream(store.mapInfo!),
          builder: (context, snapshot) {
            return MapView(
              _mapController,
              store.position!,
              store.strollRoute,
              store.mapInfo,
              snapshot.data,
              onLongTap: _handleLongTap,
              onPointTap: _handleMapPointTap,
            );
          },
        ),
      ),
    ]);
  }

  Future<void> _handleLongTap(Position position) async {
    Provider.of<RouterState>(context, listen: false)
        .pushRoute(AppLocationSpotCreate(
      mapId: _state!.mapInfo!.id!,
      position: position,
    ));
  }

  void _handleMapPointTap(String spotId) {
    MapPageStore store = Provider.of<MapPageStore>(context, listen: false);
    ImageLoader loader = Provider.of<ImageLoader>(context, listen: false);
    PointEditFormStore editFormStore =
        Provider.of<PointEditFormStore>(context, listen: false);
    showModalBottomSheet(
        context: context,
        builder: (context) => MultiProvider(
              providers: [
                ListenableProvider<MapPageStore>.value(value: store),
                ListenableProvider<PointEditFormStore>.value(
                    value: editFormStore),
                Provider<ImageLoader>.value(value: loader)
              ],
              child: PointInfoForm(spotId),
            ));
  }
}
