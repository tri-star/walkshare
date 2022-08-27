import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/map_view.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/spot_edit_page_store.dart';
import 'package:strollog/pages/map/spot_detail_page.dart';
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
      _state!.init();
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
    ImageLoaderPhoto loader =
        Provider.of<ImageLoaderPhoto>(context, listen: false);
    SpotEditPageStore editFormStore =
        Provider.of<SpotEditPageStore>(context, listen: false);
    showModalBottomSheet(
        context: context,
        builder: (context) => MultiProvider(
              providers: [
                ListenableProvider<MapPageStore>.value(value: store),
                ListenableProvider<SpotEditPageStore>.value(
                    value: editFormStore),
                Provider<ImageLoaderPhoto>.value(value: loader)
              ],
              child: SpotDetailPage(store.mapInfo!.spots[spotId]!),
            ));
  }
}
