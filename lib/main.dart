import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int viewId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: UiKitView(
          viewType: "plugin.bughub.dev/amap_view",
          creationParams: {
            "apiKey": "此处填入apiKey",
          },
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (_viewId) {
            viewId = _viewId;

            MethodChannel channel = MethodChannel("plugin.bughub.dev/amap_method_$viewId");

            channel.invokeMethod("setMAPinAnnotationStyle", <String, dynamic>{
              "canShowCallout": true,
              "animatesDrop": true,
              "draggable": true,
              "pinColor": "MAPinAnnotationColorPurple"
            });

            channel.invokeMethod("setMAPolylineStyle", <String, dynamic>{
              "lineWidth": 5.0,
              "strokeColor": "#000000",
              "lineJoinType": "kMALineJoinRound",
              "lineCapType": "kMALineCapRound"
            });

            channel.invokeMethod("setMACircleStyle", <String, dynamic>{
              "lineWidth": 5.0,
              "strokeColor": "#000000",
              "fillColor": "#99100000",
            });

            channel.invokeMethod("addAnnotation", <String, dynamic>{
              "coordinate": {"latitude": 39.989631, "longitude": 116.481018},
              "title": "方恒国际",
              "subtitle": "阜通东大街6号"
            });

            channel.invokeMethod("addOverlay", <String, dynamic>{
              "coordinates": [
                {"latitude": 39.832136, "longitude": 116.34095},
                {"latitude": 39.832136, "longitude": 116.42095},
                {"latitude": 39.902136, "longitude": 116.42095},
                {"latitude": 39.902136, "longitude": 116.44095},
              ],
              "overlayType": "MAPolyline",
            });

            channel.invokeMethod("addOverlay", <String, dynamic>{
              "coordinates": [
                {"latitude": 39.952136, "longitude": 116.50095},
              ],
              "radius": 5000,
              "overlayType": "MACircle",
            });

            EventChannel eventChannel = EventChannel("plugin.bughub.dev/amap_event_$viewId");
            eventChannel.receiveBroadcastStream().listen((event) {
              print("event:$event");
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        MethodChannel channel = MethodChannel("plugin.bughub.dev/amap_method_$viewId");
        channel.invokeMethod("search", <String, dynamic>{
          "keywords": "北京大学",
          "city": "北京",
          "types": "高等院校",
          "requireExtension": true,
          "cityLimit": true,
          "requireSubPOIs": true
        });
      }),
    );
  }
}
