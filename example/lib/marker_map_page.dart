import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

class MarkerMapPage extends StatefulWidget {
  @override
  _MarkerMapPageState createState() => _MarkerMapPageState();
}

class _MarkerMapPageState extends State<MarkerMapPage> {
  static const MODE_ADD = 0xF1;
  static const MODE_REMOVE = 0xF2;
  static const MODE_NONE = 0xF3;
  int _currentMode = MODE_NONE;

  Completer<NaverMapController> _controller = Completer();
  List<Marker> _markers = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /*
      OverlayImage.fromAssetImage(
        assetName: 'icon/marker.png',
        devicePixelRatio: window.devicePixelRatio,
      )*/

      Uint8List bitmap = await createCustomMarkerBitmap("타이틀", textStyle: TextStyle(fontSize: 30, color: Colors.black));
      OverlayImage overlayImage = OverlayImage.fromBitmap("bitmapCacheKey", bitmap);

      setState(() {
        _markers.add(Marker(
            markerId: 'id',
            position: LatLng(37.563600, 126.962370),
            captionText: "커스텀 아이콘",
            captionColor: Colors.indigo,
            captionTextSize: 20.0,
            alpha: 0.8,
            captionOffset: 30,
            icon: overlayImage,
            anchor: AnchorPoint(0.5, 1),
            width: 45,
            height: 45,
            infoWindow: '인포 윈도우',
            onMarkerTab: _onMarkerTap));
      });
    });

    super.initState();
  }

  Future<Uint8List> createCustomMarkerBitmap(String title,
      {required TextStyle textStyle,
        Color backgroundColor = Colors.blueAccent}) async {
    TextSpan span = TextSpan(
      style: textStyle,
      text: title,
    );
    TextPainter painter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    painter.text = TextSpan(
      text: title.toString(),
      style: textStyle,
    );
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    painter.layout();
    painter.paint(canvas, const Offset(20.0, 10.0));
    int textWidth = painter.width.toInt();
    int textHeight = painter.height.toInt();
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(0, 0, textWidth + 44, textHeight + 24,
            bottomLeft: const Radius.circular(10),
            bottomRight: const Radius.circular(10),
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10)
        ),
        Paint()..color = Colors.black.withAlpha(100)
    );

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(0, 0, textWidth + 40, textHeight + 20,
            bottomLeft: const Radius.circular(10),
            bottomRight: const Radius.circular(10),
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10)
        ),
        Paint()..color = backgroundColor
    );

    var arrowPath2 = Path();
    arrowPath2.moveTo((textWidth + 44) / 2 - 15, textHeight + 24);
    arrowPath2.lineTo((textWidth + 44) / 2, textHeight + 44);
    arrowPath2.lineTo((textWidth + 44) / 2 + 15, textHeight + 24);
    arrowPath2.close();
    canvas.drawPath(arrowPath2, Paint()..color = Colors.black.withAlpha(100));

    var arrowPath = Path();
    arrowPath.moveTo((textWidth + 40) / 2 - 15, textHeight + 20);
    arrowPath.lineTo((textWidth + 40) / 2, textHeight + 40);
    arrowPath.lineTo((textWidth + 40) / 2 + 15, textHeight + 20);
    arrowPath.close();
    canvas.drawPath(arrowPath, Paint()..color = backgroundColor);

    painter.layout();
    painter.paint(canvas, const Offset(20.0, 10.0));
    ui.Picture p = pictureRecorder.endRecording();
    ByteData? pngBytes = await (await p.toImage(
        painter.width.toInt() + 44, painter.height.toInt() + 54))
        .toByteData(format: ui.ImageByteFormat.png);
    return Uint8List.view(pngBytes!.buffer);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: <Widget>[
            _controlPanel(),
            _naverMap(),
          ],
        ),
      ),
    );
  }

  _controlPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 추가
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentMode = MODE_ADD),
              child: Container(
                decoration: BoxDecoration(
                    color:
                        _currentMode == MODE_ADD ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black)),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(right: 8),
                child: Text(
                  '추가',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _currentMode == MODE_ADD ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // 삭제
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentMode = MODE_REMOVE),
              child: Container(
                decoration: BoxDecoration(
                    color: _currentMode == MODE_REMOVE
                        ? Colors.black
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black)),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(right: 8),
                child: Text(
                  '삭제',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentMode == MODE_REMOVE
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // none
          GestureDetector(
            onTap: () => setState(() => _currentMode = MODE_NONE),
            child: Container(
              decoration: BoxDecoration(
                  color:
                      _currentMode == MODE_NONE ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black)),
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.clear,
                color: _currentMode == MODE_NONE ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _naverMap() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          NaverMap(
            onMapCreated: _onMapCreated,
            onMapTap: _onMapTap,
            markers: _markers,
            initLocationTrackingMode: LocationTrackingMode.Follow,
          ),
        ],
      ),
    );
  }

  // ================== method ==========================

  void _onMapCreated(NaverMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTap(LatLng latLng) {
    if (_currentMode == MODE_ADD) {
      _markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: latLng,
        infoWindow: '테스트',
        onMarkerTab: _onMarkerTap,
      ));
      setState(() {});
    }
  }

  void _onMarkerTap(Marker? marker, Map<String, int?> iconSize) {
    int pos = _markers.indexWhere((m) => m.markerId == marker!.markerId);
    setState(() {
      _markers[pos].captionText = '선택됨';
    });
    if (_currentMode == MODE_REMOVE) {
      setState(() {
        _markers.removeWhere((m) => m.markerId == marker!.markerId);
      });
    }
  }
}
