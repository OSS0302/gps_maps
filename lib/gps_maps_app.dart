import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GpsMapsApp extends StatefulWidget {
  const GpsMapsApp({super.key});

  @override
  State<GpsMapsApp> createState() => GpsMapsAppState();
}

class GpsMapsAppState extends State<GpsMapsApp> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // 어떤 위치를  위도 경도 를 통해서  나타낸다.
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  CameraPosition? _initialCameraPostion;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final position = await _determinePosition();

    _initialCameraPostion = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 15);
    setState(() {});

    const locationSettings = LocationSettings();
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
          _moveTheCamera(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //구글맵
      body: _initialCameraPostion == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              //형태 하이브리드
              mapType: MapType.hybrid,
              initialCameraPosition: _initialCameraPostion!,
              //구글 본사 위치 정보 나온다. 구글맵을 컨트롤하는 컨트롤러 를 통해서 맵을 조작한다.
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      // _goToTheLake 함수 호출
    );
  }

  // 화면 움직이는  줌 되는  로직
  Future<void> _moveTheCamera(Position position) async {
    final GoogleMapController controller = await _controller.future;
    final cameraPosition = CameraPosition(
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: 16,
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  // 현재 위치 정보를 접근 할때  꼭해야하는 코드
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    // 핸드폰에 위치정보가 켜져있는지 확인 하는 코드 없으면 오류난다.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
    // checkPermission 통해서 위치정보 동의를 얻을때 동의 구하면 오류
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
