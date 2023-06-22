import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MarkerX'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final MapController flutterMapController = MapController();
  List<BaseOverlayImage> overlayImages = [];
  Map<dynamic, LatLng> topL = {};
  Map<dynamic, LatLng> botL = {};
  Map<dynamic, LatLng> botR = {};
  dynamic editPlate = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text("Load Chart Example"),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      getImageSize('VORD02.png');
                    },
                    child: const Text('Load Chart'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: flutterMapController,
              options: MapOptions(
                onTap: null,
                center: LatLng(27.7000, 84.3333),
                zoom: 5,
                minZoom: 5,
                onPositionChanged: ((position, hasGesture) {}),
                interactiveFlags:
                    InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                OverlayImageLayer(
                  overlayImages: overlayImages,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void getImageSize(
    dynamic chartName,
  ) {
    final imageProvider = AssetImage('assets/$chartName');
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    int width = 0;
    int height = 0;
    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      width = info.image.width;
      height = info.image.height;
      print('Overlay image width: $width, height: $height');
      calculateImageCorners(flutterMapController.center, width, height,
          flutterMapController.zoom + 3.14159265, chartName, context);
    }));
  }

  //void calculateImageCorners() {
  void calculateImageCorners(LatLng center, int imageWidth, int imageHeight,
      double mapZoom, dynamic chartName, BuildContext context) {
    final scaleFactor = 1 / (2 * pow(2, mapZoom));
    // print('Zoom Level: $zoomLevel');
    // Calculate half width and half height in latitude and longitude
    final halfWidth = imageWidth * scaleFactor / 2;
    final halfHeight = imageHeight * scaleFactor / 2;
    // Calculate top left corner coordinates
    final topLeftLatitude = center.latitude + halfHeight;
    final topLeftLongitude = center.longitude - halfWidth;
    // Calculate bottom left corner coordinates
    final bottomLeftLatitude = center.latitude - halfHeight;
    final bottomLeftLongitude = center.longitude - halfWidth;
    // Calculate bottom right corner coordinates
    final bottomRightLatitude = center.latitude - halfHeight;
    final bottomRightLongitude = center.longitude + halfWidth;
    // Print the results
    print(chartName);
    LatLng topC = LatLng(topLeftLatitude, topLeftLongitude);
    LatLng botC = LatLng(bottomLeftLatitude, topLeftLongitude);
    LatLng rightC = LatLng(bottomLeftLatitude, bottomRightLongitude);

    addTestRotatedOverLayImageX(chartName, topC, botC, rightC);
    print('Top Left: $topLeftLatitude, $topLeftLongitude');
    print('Bottom Left: $bottomLeftLatitude, $bottomLeftLongitude');
    print('Bottom Right: $bottomRightLatitude, $bottomRightLongitude');
  }

  Future<void> addTestRotatedOverLayImageX(dynamic chartName, LatLng topLeft,
      LatLng botLeft, LatLng botRight) async {
    //initializeChartValues(); // Initialize chart values before usage
    print(chartName);
    dynamic chart = chartName.toString().replaceAll(RegExp(r'.png'), "");
    // editPlate = chart;
    topL[editPlate] = topLeft;
    botL[editPlate] = botLeft;
    botR[editPlate] = botRight;
    final newImage = RotatedOverlayImage(
      topLeftCorner: topLeft,
      bottomLeftCorner: botLeft,
      bottomRightCorner: botRight,
      opacity: 1,
      imageProvider: AssetImage('assets/$chartName'),
    );
    setState(() {
      overlayImages.add(newImage);
    });

    // }
  }
}
