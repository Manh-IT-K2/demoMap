import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override

  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;

  // Coordinates of locations
  final LatLng daNang = const LatLng(16.0544, 108.2022);
  final LatLng nhaTrang = const LatLng(12.2388, 109.1967);
  final LatLng dongNai = const LatLng(10.9480, 106.8149);
  final LatLng hoChiMinh = const LatLng(10.8231, 106.6297);

  final List<LatLng> routeCoordinates = const [
    LatLng(16.0544, 108.2022),
    LatLng(12.2388, 109.1967),
    LatLng(10.9480, 106.8149),
    LatLng(10.8231, 106.6297),
  ];
  //
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? currentLocation;
  String? distanceInfo;
  String? km;
  String? selectedLocation;

  //
  double calculateDistance(LatLng start, LatLng end) {
    const double radius = 6371;
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;
    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;
    double a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  //
  void showDistanceDialog(BuildContext context, String message, String km) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Thông tin khoảng cách"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(message, style: const TextStyle(fontSize: 16)),
                Text(km, style: const TextStyle(fontSize: 18, color: Colors.red)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Đóng"),
              ),
            ],
          );
        },
      );
    });
  }

  //
  void updateLocation(LatLng newLocation, String selectedLocation) {
    setState(() {
      currentLocation = newLocation;
      this.selectedLocation = selectedLocation;
      markers = {
        for (int i = 0; i < routeCoordinates.length; i++)
          Marker(
            markerId: MarkerId("point$i"),
            position: routeCoordinates[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              selectedLocation == getLocationName(i)
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueRed,
            ),
          ),
      };
      if (selectedLocation == "Da Nang") {
        distanceInfo =
            "Khoảng cách từ Đà Nẵng đến Hồ Chí Minh là";
            km =" ${calculateDistance(daNang, hoChiMinh).toStringAsFixed(2)} km.";
      } else if (selectedLocation == "Nha Trang") {
        distanceInfo =
            "Khoảng cách từ Nha Trang đến Đồng Nai là ${calculateDistance(nhaTrang, dongNai).toStringAsFixed(2)} km.\nKhoảng cách từ Nha Trang đến Hồ Chí Minh là ${calculateDistance(nhaTrang, hoChiMinh).toStringAsFixed(2)} km.";
            km = "";
      } else if (selectedLocation == "Dong Nai") {
        distanceInfo =
            "Khoảng cách từ Đồng Nai đến Hồ Chí Minh là ";
            km = "${calculateDistance(dongNai, hoChiMinh).toStringAsFixed(2)} km.";
      } else {
        distanceInfo = "Đã đến Hồ Chí Minh!";
        km = "";
      }
      showDistanceDialog(context, distanceInfo!, km!);
    });
  }

//
  String getLocationName(int index) {
    switch (index) {
      case 0:
        return "Da Nang";
      case 1:
        return "Nha Trang";
      case 2:
        return "Dong Nai";
      case 3:
        return "Ho Chi Minh";
      default:
        return "";
    }
  }

  //
  void _loadMapData() {
    setState(() {
      markers = {
        for (int i = 0; i < routeCoordinates.length; i++)
          Marker(
            markerId: MarkerId("point$i"),
            position: routeCoordinates[i],
            icon: BitmapDescriptor.defaultMarker,
          ),
      };
      polylines.add(Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.green,
        width: 5,
        points: routeCoordinates,
      ));
    });
  }

  //
  void setMapController(GoogleMapController controller) {
    mapController = controller;
    setState(() {});
  }

  //
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (currentLocation == null) {
      _loadMapData();
    }
  }

  //
  void showLocationSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Đà Nẵng"),
                leading: Radio<String>(
                  value: "Da Nang",
                  groupValue: selectedLocation,
                  onChanged: (String? value) {
                    if (value != null) {
                      updateLocation(daNang, value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text("Nha Trang"),
                leading: Radio<String>(
                  value: "Nha Trang",
                  groupValue: selectedLocation,
                  onChanged: (String? value) {
                    if (value != null) {
                      updateLocation(nhaTrang, value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text("Đồng Nai"),
                leading: Radio<String>(
                  value: "Dong Nai",
                  groupValue: selectedLocation,
                  onChanged: (String? value) {
                    if (value != null) {
                      updateLocation(dongNai, value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text("Hồ Chí Minh"),
                leading: Radio<String>(
                  value: "Ho Chi Minh",
                  groupValue: selectedLocation,
                  onChanged: (String? value) {
                    if (value != null) {
                      updateLocation(hoChiMinh, value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps")),
      body: Column(
        children: [
          if (currentLocation != null && distanceInfo != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(distanceInfo!),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.0583, 108.2772), // Center of Vietnam
                zoom: 6.0,
              ),
              onMapCreated: setMapController,
              markers: markers,
              polylines: polylines,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showLocationSelection();
        },
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
