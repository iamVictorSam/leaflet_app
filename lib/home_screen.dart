import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/tile_builder_example';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool darkMode = false;
  bool loadingTime = false;
  bool showCoordinates = false;
  bool grid = false;
  int panBuffer = 0;
  double _rotation = 0;

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // mix of [coordinateDebugTileBuilder] and [loadingTimeDebugTileBuilder] from tile_builder.dart
  Widget tileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    final coords = tile.coordinates;

    return Container(
      decoration: BoxDecoration(
        border: grid ? Border.all() : null,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          tileWidget,
          if (loadingTime || showCoordinates)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showCoordinates)
                  Text(
                    '${coords.x.floor()} : ${coords.y.floor()} : ${coords.z.floor()}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                if (loadingTime)
                  Text(
                    tile.loadFinishedAt == null
                        ? 'Loading'
                        // sometimes result is negative which shouldn't happen, abs() corrects it
                        : '${(tile.loadFinishedAt!.millisecond - tile.loadStarted!.millisecond).abs()} ms',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Tile builder')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'grid',
            label: Text(
              grid ? 'Hide grid' : 'Show grid',
              textAlign: TextAlign.center,
            ),
            icon: Icon(grid ? Icons.grid_off : Icons.grid_on),
            onPressed: () => setState(() => grid = !grid),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'coords',
            label: Text(
              showCoordinates ? 'Hide coords' : 'Show coords',
              textAlign: TextAlign.center,
            ),
            icon: Icon(showCoordinates ? Icons.unarchive : Icons.bug_report),
            onPressed: () => setState(() => showCoordinates = !showCoordinates),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'ms',
            label: Text(
              loadingTime ? 'Hide loading time' : 'Show loading time',
              textAlign: TextAlign.center,
            ),
            icon: Icon(loadingTime ? Icons.timer_off : Icons.timer),
            onPressed: () => setState(() => loadingTime = !loadingTime),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'dark-light',
            label: Text(
              darkMode ? 'Light mode' : 'Dark mode',
              textAlign: TextAlign.center,
            ),
            icon: Icon(darkMode ? Icons.brightness_high : Icons.brightness_2),
            onPressed: () => setState(() => darkMode = !darkMode),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'panBuffer',
            label: Text(
              panBuffer == 0 ? 'panBuffer off' : 'panBuffer on',
              textAlign: TextAlign.center,
            ),
            icon: Icon(grid ? Icons.grid_off : Icons.grid_on),
            onPressed: () => setState(() {
              panBuffer = panBuffer == 0 ? 1 : 0;
            }),
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: const LatLng(51.5, -0.09),
            zoom: 5,
          ),
          nonRotatedChildren: const [
            // FlutterMapZoomButtons(
            //   minZoom: 4,
            //   maxZoom: 19,
            //   mini: true,
            //   padding: 10,
            //   alignment: Alignment.bottomRight,
            // ),
          ],
          children: [
            _darkModeContainerIfEnabled(
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                tileBuilder: tileBuilder,
                panBuffer: panBuffer,
              ),
            ),
            MarkerLayer(
              markers: <Marker>[
                Marker(
                  width: 80,
                  height: 80,
                  point: const LatLng(51.5, -0.09),
                  builder: (ctx) => const FlutterLogo(
                    key: ObjectKey(Colors.blue),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 70,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Search Location '),
                    ),
                  )),
            ),
            SizedBox(
              width: 300,
              child: Slider(
                value: _rotation,
                min: 0,
                max: 360,
                onChanged: (degree) {
                  setState(() {
                    _rotation = degree;
                  });
                  _mapController.rotate(degree);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _darkModeContainerIfEnabled(Widget child) {
    if (!darkMode) return child;

    return darkModeTilesContainerBuilder(context, child);
  }
}
