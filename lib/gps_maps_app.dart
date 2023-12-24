import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
}