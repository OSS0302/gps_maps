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

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> init() async{
  final position = await _determinePosition();
  // 출려학하기
  // print(position.longitude);
  // print(position.latitude);
  print(position.toString());

  }
  // 다른 위치 정보 위도 경도
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //구글맵
      body: GoogleMap(
        //형태 하이브리드
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        //구글 본사 위치 정보 나온다. 구글맵을 컨트롤하는 컨트롤러 를 통해서 맵을 조작한다.
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      // _goToTheLake 함수 호출
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
  // 화면 돌아가는 줌되는 애니메이션
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

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
