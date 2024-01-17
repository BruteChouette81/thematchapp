import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import './utils/tile_servers.dart';
import './utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class MarkersPage extends StatefulWidget {
  const MarkersPage({super.key, required this.tapScreen});

  final void Function(LatLng) tapScreen;

  @override
  MarkersPageState createState() => MarkersPageState();
}

class MarkersPageState extends State<MarkersPage> {
  final controller = MapController(
    location: const LatLng(45.54, -73.55),
    zoom: 8
  );

  var markers = [
   const LatLng(45.54, -73.55),
  ];

  void _gotoDefault() {
    controller.center = const LatLng(45.54, -73.55);
    setState(() {});
  }

  Offset _pointedLocation = const Offset(0.0, 0.0);
  void _tapScreenRaster (MapTransformer transformer, Offset location) {
    widget.tapScreen(transformer.toLatLng(location));
    print(controller.center.longitude.toString());
    print(controller.center.latitude.toString());
    setState(() {
      _pointedLocation = location;
      markers = [transformer.toLatLng(location)];
    });

  }

  void _onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = clamp(controller.zoom + delta, 2, 18);

    transformer.setZoomInPlace(zoom, position);
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  Widget _buildMarkerWidget(Offset pos, Color color,
      [IconData icon = Icons.location_on]) {
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: GestureDetector(
        child: Icon(
          icon,
          color: color,
          size: 48,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              content: Text('You have clicked a marker!'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markers'),
      ),
      body: MapLayout(
        controller: controller,
        builder: (context, transformer) {
          final markerPositions = markers.map(transformer.toOffset).toList();
          //print(transformer.toLatLng(markerPositions[0]).latitude.toString());


          final markerWidgets = markerPositions.map(
            (pos) => _buildMarkerWidget(pos, Colors.red),
          );

          /*final homeLocation = transformer.toOffset(const LatLng(35.68, 51.42));

          final homeMarkerWidget =
              _buildMarkerWidget(homeLocation, Colors.black, Icons.home);

          final centerLocation = Offset(
              transformer.constraints.biggest.width / 2,
              transformer.constraints.biggest.height / 2);

          final centerMarkerWidget =
              _buildMarkerWidget(centerLocation, Colors.purple);
              homeMarkerWidget,
                  ...markerWidgets,
                  centerMarkerWidget,*/

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _tapScreenRaster(transformer, details.localPosition),
            onDoubleTapDown: (details) => _onDoubleTap(
              transformer,
              details.localPosition,
            ),
            onScaleStart: _onScaleStart,
            onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta.dy / -1000.0;
                  final zoom = clamp(controller.zoom + delta, 2, 18);

                  transformer.setZoomInPlace(zoom, event.localPosition);
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  TileLayer(
                    builder: (context, x, y, z) {
                      final tilesInZoom = pow(2.0, z).floor();

                      while (x < 0) {
                        x += tilesInZoom;
                      }
                      while (y < 0) {
                        y += tilesInZoom;
                      }

                      x %= tilesInZoom;
                      y %= tilesInZoom;

                      return CachedNetworkImage(
                        imageUrl: google(z, x, y),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  ...markerWidgets,
                  Text("coords selected: ${_pointedLocation.toString()}")
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoDefault,
        tooltip: 'My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}